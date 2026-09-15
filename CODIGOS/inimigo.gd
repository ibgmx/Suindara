extends CharacterBody2D

@export var velocidade := 50.0
@export var area_perseguicao := 300.0
@export var velocidade_retorno := 100.0
@export var tempo_recuo_dano := 2.5
@export var distancia_recuo_dano := 32.0
@export var tempo_respawn := 20.0

enum Estado {
	ESPERANDO,
	PERSEGUINDO,
	RECUANDO,
	VOLTANDO,
	MORTO
}

var estado := Estado.ESPERANDO

var jogador: Node2D = null

@onready var area_dano: Area2D = $AreaDano
@onready var colisao: CollisionShape2D = $CollisionShape2D

var posicao_nascimento := Vector2.ZERO
var tempo_recuo := 0.0
var posicao_recuo := Vector2.ZERO

var camada_area_dano := 0
var mascara_area_dano := 0


func _ready():

	add_to_group("inimigo")

	posicao_nascimento = global_position

	jogador = get_tree().current_scene.get_node_or_null("Suindara/Indara")

	if jogador == null:
		print("ERRO: não encontrei a Indara em Suindara/Indara")
		return

	# Guarda as configurações originais da AreaDano
	camada_area_dano = area_dano.collision_layer
	mascara_area_dano = area_dano.collision_mask

	area_dano.body_entered.connect(_on_area_dano_body_entered)


func _physics_process(delta):

	if jogador == null:
		return

	match estado:

		Estado.ESPERANDO:
			estado_esperando()

		Estado.PERSEGUINDO:
			estado_perseguindo()

		Estado.RECUANDO:
			estado_recuando(delta)

		Estado.VOLTANDO:
			estado_voltando()

		Estado.MORTO:
			return


func indara_na_area() -> bool:

	return jogador.global_position.distance_to(
		posicao_nascimento
	) <= area_perseguicao


func estado_esperando():

	velocity = Vector2.ZERO

	if indara_na_area():
		estado = Estado.PERSEGUINDO


func estado_perseguindo():

	if not indara_na_area():

		estado = Estado.VOLTANDO
		velocity = Vector2.ZERO

		return

	var direcao: Vector2 = global_position.direction_to(
		jogador.global_position
	)

	velocity = direcao * velocidade

	move_and_slide()


func estado_recuando(delta):

	tempo_recuo -= delta

	var distancia: float = global_position.distance_to(
		posicao_recuo
	)

	if distancia > 1.0:

		var direcao: Vector2 = global_position.direction_to(
			posicao_recuo
		)

		velocity = direcao * velocidade_retorno

		move_and_slide()

	else:

		global_position = posicao_recuo
		velocity = Vector2.ZERO

	if tempo_recuo <= 0.0:

		velocity = Vector2.ZERO

		if indara_na_area():
			estado = Estado.PERSEGUINDO
		else:
			estado = Estado.VOLTANDO


func estado_voltando():

	if indara_na_area():

		estado = Estado.PERSEGUINDO

		return

	var distancia: float = global_position.distance_to(
		posicao_nascimento
	)

	if distancia <= 5.0:

		global_position = posicao_nascimento
		velocity = Vector2.ZERO
		estado = Estado.ESPERANDO

		return

	var direcao: Vector2 = global_position.direction_to(
		posicao_nascimento
	)

	velocity = direcao * velocidade_retorno

	move_and_slide()


func _on_area_dano_body_entered(body):

	if estado == Estado.MORTO:
		return

	if body != jogador:
		return

	causar_dano()


func causar_dano():

	if estado == Estado.RECUANDO:
		return

	if not jogador.has_method("receber_dano"):
		return

	jogador.receber_dano(global_position)

	var direcao_longe: Vector2 = global_position.direction_to(
		jogador.global_position
	)

	if direcao_longe.length() > 0.0:

		posicao_recuo = global_position + (
			direcao_longe * -distancia_recuo_dano
		)

	else:

		posicao_recuo = global_position

	tempo_recuo = tempo_recuo_dano

	estado = Estado.RECUANDO


func morrer():

	if estado == Estado.MORTO:
		return

	estado = Estado.MORTO

	print("INIMIGO ATINGIDO!")

	Estatisticas.registrar_inimigo()

	velocity = Vector2.ZERO

	# Esconde o inimigo
	visible = false

	# Desativa o corpo físico
	colisao.set_deferred("disabled", true)

	# Desativa completamente a AreaDano
	area_dano.set_deferred("monitoring", false)
	area_dano.set_deferred("monitorable", false)

	# IMPORTANTE:
	# tira a AreaDano das consultas físicas da flecha
	area_dano.collision_layer = 0
	area_dano.collision_mask = 0

	# Espera o tempo de respawn
	await get_tree().create_timer(tempo_respawn).timeout

	# Volta para o ponto original
	global_position = posicao_nascimento

	velocity = Vector2.ZERO

	# Reativa o corpo
	colisao.set_deferred("disabled", false)

	# Restaura a AreaDano
	area_dano.collision_layer = camada_area_dano
	area_dano.collision_mask = mascara_area_dano

	area_dano.set_deferred("monitoring", true)
	area_dano.set_deferred("monitorable", true)

	visible = true

	estado = Estado.ESPERANDO
