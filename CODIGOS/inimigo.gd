
extends CharacterBody2D

@export var velocidade := 40.0
@export var area_perseguicao := 300.0
@export var velocidade_retorno := 80.0
@export var tempo_recuo_dano := 2.5
@export var distancia_recuo_dano := 32.0
@export var tempo_respawn := 20.0

# Ataque especial
@export_range(0.1, 1.0, 0.05) var proporcao_area_ataque := 0.3
@export var tempo_carregamento := 3.5
@export var tremor_inimigo := 0.5
@export var tremor_camera_maximo := 2.0

enum Estado {
	ESPERANDO,
	PERSEGUINDO,
	PREPARANDO_ATAQUE,
	CARREGANDO_ATAQUE,
	RECUANDO,
	VOLTANDO,
	ESPERANDO_NOVO_ATAQUE,
	MORTO,
	INDARA_MORTA
}

var estado := Estado.ESPERANDO

var jogador: Node2D = null
var camera: Camera2D = null
var som_ataque: Node = null

@onready var sprite: AnimatedSprite2D = $Observador
@onready var area_dano: Area2D = $AreaDano
@onready var colisao: CollisionShape2D = $CollisionShape2D

var posicao_nascimento := Vector2.ZERO
var tempo_recuo := 0.0
var posicao_recuo := Vector2.ZERO

var camada_area_dano := 0
var mascara_area_dano := 0

var tempo_ataque := 0.0
var tempo_tremor := 0.0
var ultimo_frame := 0
var ciclos_animacao := 0
var espera_apos_ataque := false

var posicao_sprite_original := Vector2.ZERO
var offset_camera_original := Vector2.ZERO
var camera_capturada := false


func _ready():
	add_to_group("inimigo")

	posicao_nascimento = global_position
	posicao_sprite_original = sprite.position

	jogador = get_tree().current_scene.get_node_or_null(
		"Suindara/Indara"
	)

	if jogador == null:
		jogador = get_tree().get_first_node_in_group("player")

	if jogador == null:
		push_error("Inimigo: não foi possível encontrar a Indara.")
		set_physics_process(false)
		return

	som_ataque = get_node_or_null("SomAtaque")

	camera = jogador.get_node_or_null("Camera2D")

	if camera == null:
		camera = jogador.find_child("Camera2D", true, false)

	if camera != null:
		offset_camera_original = camera.offset

	if sprite.sprite_frames == null:
		push_error("Inimigo: Observador não possui Sprite Frames.")
		set_physics_process(false)
		return

	if not sprite.sprite_frames.has_animation("Padrão"):
		push_error("Inimigo: a animação Padrão não existe.")
		set_physics_process(false)
		return

	if sprite.sprite_frames.get_frame_count("Padrão") < 6:
		push_error("Inimigo: Padrão precisa ter pelo menos 6 frames.")
		set_physics_process(false)
		return

	sprite.sprite_frames.set_animation_loop("Padrão", true)

	camada_area_dano = area_dano.collision_layer
	mascara_area_dano = area_dano.collision_mask

	ultimo_frame = sprite.frame

	if not sprite.frame_changed.is_connected(
		_on_sprite_frame_changed
	):
		sprite.frame_changed.connect(
			_on_sprite_frame_changed
		)

	sprite.play("Padrão")


# ==================================================
# MORTE DA INDARA
# ==================================================

func indara_morreu() -> bool:
	if not is_instance_valid(jogador):
		return false

	return jogador.get("derrota_iniciada") == true


func parar_apos_morte():
	if estado == Estado.INDARA_MORTA:
		return

	restaurar_efeitos_ataque()

	if is_instance_valid(som_ataque) and som_ataque.has_method("stop"):
		som_ataque.stop()

	velocity = Vector2.ZERO
	estado = Estado.INDARA_MORTA

	# O inimigo fica parado, mas as asas continuam animadas.
	sprite.play("Padrão")
	ultimo_frame = sprite.frame


# ==================================================
# PROCESSAMENTO FÍSICO
# ==================================================

func _physics_process(delta):
	if not is_instance_valid(jogador):
		velocity = Vector2.ZERO
		return

	if estado == Estado.MORTO:
		velocity = Vector2.ZERO
		return

	if indara_morreu():
		parar_apos_morte()
		return

	if estado == Estado.INDARA_MORTA:
		velocity = Vector2.ZERO
		return

	match estado:
		Estado.ESPERANDO:
			estado_esperando()

		Estado.PERSEGUINDO:
			estado_perseguindo()

		Estado.PREPARANDO_ATAQUE:
			estado_preparando_ataque()

		Estado.CARREGANDO_ATAQUE:
			estado_carregando_ataque(delta)

		Estado.RECUANDO:
			estado_recuando(delta)

		Estado.VOLTANDO:
			estado_voltando()

		Estado.ESPERANDO_NOVO_ATAQUE:
			velocity = Vector2.ZERO

		Estado.MORTO, Estado.INDARA_MORTA:
			velocity = Vector2.ZERO


# ==================================================
# ÁREA E DIREÇÃO
# ==================================================

func indara_na_area() -> bool:
	return jogador.global_position.distance_to(
		posicao_nascimento
	) <= area_perseguicao


func distancia_da_indara() -> float:
	return global_position.distance_to(
		jogador.global_position
	)


func distancia_ataque() -> float:
	return area_perseguicao * proporcao_area_ataque


func atualizar_direcao():
	# O sprite original olha para a esquerda.
	sprite.flip_h = (
		jogador.global_position.x > global_position.x
	)


func mover_ate_jogador():
	var direcao := global_position.direction_to(
		jogador.global_position
	)

	velocity = direcao * velocidade
	move_and_slide()


# ==================================================
# ESPERANDO E PERSEGUINDO
# ==================================================

func estado_esperando():
	velocity = Vector2.ZERO

	if indara_na_area():
		estado = Estado.PERSEGUINDO


func estado_perseguindo():
	if not indara_na_area():
		estado = Estado.VOLTANDO
		velocity = Vector2.ZERO
		return

	atualizar_direcao()

	if distancia_da_indara() <= distancia_ataque():
		iniciar_preparacao_ataque()
		return

	mover_ate_jogador()


# ==================================================
# PREPARAÇÃO DO ATAQUE
# ==================================================

func iniciar_preparacao_ataque():
	estado = Estado.PREPARANDO_ATAQUE
	ciclos_animacao = 0
	velocity = Vector2.ZERO
	atualizar_direcao()

	if sprite.animation != "Padrão" or not sprite.is_playing():
		sprite.play("Padrão")

	ultimo_frame = sprite.frame


func estado_preparando_ataque():
	# A preparação não é cancelada pela distância.
	# Se Indara estiver perto, o Observador fica parado para não
	# atravessá-la. Se ela se afastar, ele a persegue sem reiniciar
	# a contagem das duas animações.
	atualizar_direcao()

	if distancia_da_indara() > distancia_ataque():
		mover_ate_jogador()
	else:
		velocity = Vector2.ZERO


func _on_sprite_frame_changed():
	if estado == Estado.MORTO:
		return

	if estado == Estado.INDARA_MORTA:
		ultimo_frame = sprite.frame
		return

	if sprite.animation != "Padrão":
		ultimo_frame = sprite.frame
		return

	var frame_atual := sprite.frame
	var quantidade := sprite.sprite_frames.get_frame_count("Padrão")

	# Conta ciclos completos durante a preparação e durante a pausa
	# posterior ao ataque.
	if (
		(estado == Estado.PREPARANDO_ATAQUE
		or estado == Estado.ESPERANDO_NOVO_ATAQUE)
		and ultimo_frame == quantidade - 1
		and frame_atual == 0
	):
		ciclos_animacao += 1

		if ciclos_animacao >= 2:
			if estado == Estado.PREPARANDO_ATAQUE:
				# O ataque inicial está comprometido. A distância não
				# impede o carregamento após as duas animações.
				iniciar_carregamento()

			elif estado == Estado.ESPERANDO_NOVO_ATAQUE:
				# A pausa terminou. Decide o próximo comportamento pela posição
				# atual da Indara, sem exigir que ela saia e entre novamente.
				ciclos_animacao = 0
				velocity = Vector2.ZERO

				if not indara_na_area():
					estado = Estado.VOLTANDO
				elif distancia_da_indara() <= distancia_ataque():
					# Continua o ciclo: mais duas animações e depois carrega.
					iniciar_preparacao_ataque()
				else:
					# Ainda está na área de perseguição, mas fora do alcance de ataque.
					estado = Estado.PERSEGUINDO

	ultimo_frame = frame_atual


# ==================================================
# CARREGAMENTO DO ATAQUE
# ==================================================

func iniciar_carregamento():
	if estado != Estado.PREPARANDO_ATAQUE:
		return

	if indara_morreu():
		parar_apos_morte()
		return

	estado = Estado.CARREGANDO_ATAQUE
	velocity = Vector2.ZERO

	tempo_ataque = 0.0
	tempo_tremor = 0.0

	# Para a animação no frame 0 durante a carga.
	sprite.stop()
	sprite.frame = 0
	ultimo_frame = 0

	posicao_sprite_original = sprite.position

	camera = get_viewport().get_camera_2d()
	camera_capturada = camera != null

	if camera_capturada:
		offset_camera_original = camera.offset

	# Som começa exatamente no início da carga.
	if is_instance_valid(som_ataque) and som_ataque.has_method("play"):
		if som_ataque.has_method("stop"):
			som_ataque.stop()
		som_ataque.play()


func estado_carregando_ataque(delta: float):
	if indara_morreu():
		parar_apos_morte()
		return

	velocity = Vector2.ZERO

	tempo_ataque += delta
	tempo_tremor += delta

	atualizar_direcao()

	# Tremor discreto do próprio inimigo.
	sprite.position = posicao_sprite_original + Vector2(
		sin(tempo_tremor * 30.0) * tremor_inimigo,
		cos(tempo_tremor * 26.0) * tremor_inimigo
	)

	# Recupera a câmera ativa, se necessário.
	if not is_instance_valid(camera):
		camera = get_viewport().get_camera_2d()

		if camera != null and not camera_capturada:
			offset_camera_original = camera.offset
			camera_capturada = true

	# Tremor gradual da câmera.
	if camera_capturada and is_instance_valid(camera):
		var progresso := clampf(
			tempo_ataque / tempo_carregamento,
			0.0,
			1.0
		)

		var amplitude := tremor_camera_maximo * progresso

		camera.offset = offset_camera_original + Vector2(
			sin(tempo_tremor * 24.0) * amplitude,
			cos(tempo_tremor * 27.0) * amplitude
		)

	if tempo_ataque >= tempo_carregamento:
		finalizar_ataque()


func finalizar_ataque():
	if estado != Estado.CARREGANDO_ATAQUE:
		return

	restaurar_efeitos_ataque()

	if is_instance_valid(jogador):
		if jogador.has_method("receber_dano"):
			jogador.receber_dano(global_position)

	if indara_morreu():
		parar_apos_morte()
		return

	# Depois do golpe, o Observador fica inativo por dois ciclos.
	# Não persegue nem carrega outro ataque durante essa pausa.
	estado = Estado.ESPERANDO_NOVO_ATAQUE
	ciclos_animacao = 0
	espera_apos_ataque = false
	velocity = Vector2.ZERO

	sprite.play("Padrão")
	ultimo_frame = sprite.frame


func restaurar_efeitos_ataque():
	if sprite != null:
		sprite.position = posicao_sprite_original

	if camera_capturada and is_instance_valid(camera):
		camera.offset = offset_camera_original

	camera_capturada = false
	tempo_ataque = 0.0
	tempo_tremor = 0.0


# ==================================================
# RECUO
# ==================================================

func estado_recuando(delta: float):
	tempo_recuo -= delta

	var distancia := global_position.distance_to(
		posicao_recuo
	)

	if distancia > 1.0:
		var direcao := global_position.direction_to(
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


# ==================================================
# DANO POR CHAMADA EXTERNA
# ==================================================

func causar_dano():
	if estado == Estado.MORTO:
		return

	if estado == Estado.INDARA_MORTA:
		return

	if estado == Estado.RECUANDO:
		return

	if not is_instance_valid(jogador):
		return

	if not jogador.has_method("receber_dano"):
		return

	jogador.receber_dano(global_position)

	if indara_morreu():
		parar_apos_morte()
		return

	var direcao_longe := global_position.direction_to(
		jogador.global_position
	)

	if direcao_longe.length() > 0.0:
		posicao_recuo = global_position - (
			direcao_longe * distancia_recuo_dano
		)
	else:
		posicao_recuo = global_position

	tempo_recuo = tempo_recuo_dano
	estado = Estado.RECUANDO


# ==================================================
# RETORNO AO NASCIMENTO
# ==================================================

func estado_voltando():
	if indara_na_area():
		estado = Estado.PERSEGUINDO
		return

	var distancia := global_position.distance_to(
		posicao_nascimento
	)

	if distancia <= 5.0:
		global_position = posicao_nascimento
		velocity = Vector2.ZERO
		estado = Estado.ESPERANDO
		return

	var direcao := global_position.direction_to(
		posicao_nascimento
	)

	velocity = direcao * velocidade_retorno
	move_and_slide()


# ==================================================
# MORTE E RESPAWN DO INIMIGO
# ==================================================

func morrer():
	if estado == Estado.MORTO:
		return

	estado = Estado.MORTO

	restaurar_efeitos_ataque()

	if is_instance_valid(som_ataque) and som_ataque.has_method("stop"):
		som_ataque.stop()

	print("INIMIGO ATINGIDO!")

	Estatisticas.registrar_inimigo()

	velocity = Vector2.ZERO
	sprite.stop()
	visible = false

	colisao.set_deferred("disabled", true)

	area_dano.set_deferred("monitoring", false)
	area_dano.set_deferred("monitorable", false)

	area_dano.collision_layer = 0
	area_dano.collision_mask = 0

	await get_tree().create_timer(tempo_respawn).timeout

	if not is_inside_tree():
		return

	global_position = posicao_nascimento
	velocity = Vector2.ZERO

	colisao.set_deferred("disabled", false)

	area_dano.collision_layer = camada_area_dano
	area_dano.collision_mask = mascara_area_dano

	area_dano.set_deferred("monitoring", true)
	area_dano.set_deferred("monitorable", true)

	visible = true

	sprite.position = posicao_sprite_original
	sprite.play("Padrão")
	ultimo_frame = sprite.frame
	ciclos_animacao = 0
	espera_apos_ataque = false

	if indara_morreu():
		estado = Estado.INDARA_MORTA
		velocity = Vector2.ZERO
		return

	estado = Estado.ESPERANDO
