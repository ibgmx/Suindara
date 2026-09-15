extends CharacterBody2D

@export var velocidade := 550
@export var distancia_maxima_pulo := 350.0

# =========================
# CÂMERA / INTRODUÇÃO
# =========================

@export var zoom_inicial_camera := 4.5
@export var zoom_final_camera := 1.9
@export var duracao_zoom_camera := 3

@export var zoom_camera_arco := 2.15
@export var duracao_zoom_arco := 0.3
@export var duracao_retorno_zoom_arco := 0.3

@onready var camera: Camera2D = $Camera2D
@onready var cronometro: Label = get_tree().current_scene.get_node("HUD/Cronometro")
@onready var particulas_pulo: GPUParticles2D = $ParticulasPulo
@onready var coracao1: AnimatedSprite2D = get_tree().current_scene.get_node("HUD/Vidas/Coracao1")
@onready var coracao2: AnimatedSprite2D = get_tree().current_scene.get_node("HUD/Vidas/Coracao2")
@onready var coracao3: AnimatedSprite2D = get_tree().current_scene.get_node("HUD/Vidas/Coracao3")

#--------------------------------------
#sons 
#--------------------------------------

@onready var som_dash: AudioStreamPlayer = $Sons/Dash
@onready var som_carregar_arco: AudioStreamPlayer = $Sons/CarregarArco
@onready var som_flecha: AudioStreamPlayer = $Sons/Flecha
@onready var som_risada: AudioStreamPlayer = $Sons/Risada
@onready var som_dano: AudioStreamPlayer = $Sons/Dano

var controles_bloqueados := true
var introducao_terminada := false

var zoom_antes_arco := Vector2.ONE
var tween_zoom_arco: Tween = null
var posicao_original_camera := Vector2.ZERO
@export var intensidade_tremor_arco := 0.8

# =========================
# SAÍDA PELO ESC
# =========================

@export var zoom_limite_esc := 1.0
@export var duracao_distanciamento_esc := 1.2
var esc_distanciando := false
var tween_zoom_esc: Tween = null

# =========================
# NÓS
# =========================

@onready var ponto_flecha: Marker2D = $Arco/PontoFlecha
@onready var arco: AnimatedSprite2D = $Arco/arco
@onready var sprite: AnimatedSprite2D = $perso
@onready var pulo_parede: AnimatedSprite2D = $pulo_parede

@onready var pivo_seta_pulo: Node2D = $pivo_seta_pulo
@onready var seta_pulo_disponivel: Sprite2D = $pivo_seta_pulo/seta_pulo_disponivel
@onready var seta_pulo_indisponivel: Sprite2D = $pivo_seta_pulo/seta_pulo_indisponivel

# =========================
# FLECHA
# =========================

var cena_flecha = preload("res://CENAS/flecha.tscn")

var cena_pausa = preload("res://CENAS/pausa.tscn")
var menu_pausa: CanvasLayer = null
var jogo_pausado := false

# =========================
# MOVIMENTO
# =========================

var em_movimento := false
var parado_no_meio := false
var pode_dar_stop := false
var direcao := Vector2.ZERO
var esta_na_parede := false

# Superfície virtual usada depois do dano.
var superficie_virtual := false

# =========================
# ARCO
# =========================

var carregando_arco := false
var arco_carregado := false
var flechas_disparadas := 0

# =========================
# VIDAS
# =========================

@export var vidas_maximas := 3

var vidas := 3
var derrota_iniciada := false

# =========================
# ANIMAÇÃO DE DERROTA
# =========================

@export var duracao_animacao_derrota := 1.2
@export var escala_final_derrota := 0.15
@export var opacidade_final_derrota := 0.0
@export var voltas_derrota := 1.0

var tween_derrota: Tween = null

# =========================
# DANO
# =========================

var parada_por_dano := false
var dash_pos_dano_ativo := false
var distancia_dash_virtual_restante: float = 0.0

# =========================
# LENTIDÃO DOS INIMIGOS
# =========================

const FATOR_LENTIDAO_INIMIGOS := 0.1

# =========================
# PULO ENTRE SUPERFÍCIES
# =========================

var pulando_entre_superficies := false
var normal_parede := Vector2.UP
var rotacao_superficie := 0.0
var posicao_original_arco := Vector2.ZERO
var posicao_original_pivo_seta := Vector2.ZERO
var rotacao_pulo := 0.0
var flip_pulo := false

# =========================
# SETA DE PULO
# =========================

var direcao_pulo := Vector2.UP
var ponto_destino_pulo := Vector2.ZERO
var pulo_disponivel := false

@export var angulo_maximo_pulo := 60.0
@export var angulo_desaparecer_seta := 90.0

# =========================
# CONSTANTES
# =========================

const MAX_FLECHAS := 2
const ULTIMO_FRAME := 4
const CORRECAO_ARCO := deg_to_rad(45.0)

# =========================
# PARTÍCULAS
# =========================

func soltar_particulas_pulo():
	particulas_pulo.restart()

# =========================
# READY
# =========================

func _ready():

	$TransicaoDerrota/EfeitoEscuridao.visible = false
	sprite.sprite_frames.set_animation_loop("default", true)
	sprite.play("default")

	Estatisticas.iniciar_tentativa()

	vidas = vidas_maximas
	preparar_coracoes()

	posicao_original_arco = $Arco.position
	posicao_original_pivo_seta = pivo_seta_pulo.position
	posicao_original_camera = camera.position

	arco.visible = false
	arco.stop()
	arco.frame = 0

	pulo_parede.visible = false
	pulo_parede.stop()

	seta_pulo_disponivel.visible = false
	seta_pulo_indisponivel.visible = false

	atualizar_orientacao()
	iniciar_intro_camera()

# =========================
# PROCESS
# =========================

func _process(_delta):

	if carregando_arco:
		desacelerar_inimigos()
	else:
		acelerar_inimigos()

	var posicao_mouse = get_global_mouse_position()
	var direcao_mouse = posicao_mouse - global_position

	if direcao_mouse.length_squared() < 0.001:
		return

	# ==================================================
	# indara FORA DE SUPERFÍCIE
	# ==================================================

	if not esta_na_parede:

		rotacao_superficie = 0.0

		atualizar_posicao_pivo_seta()

		if not pulando_entre_superficies or parado_no_meio:

			sprite.rotation = 0.0

			if direcao_mouse.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false

		var posicao_arco = posicao_original_arco

		if direcao_mouse.x < 0:
			posicao_arco.x = -posicao_original_arco.x

		$Arco.position = posicao_arco
		$Arco.rotation = 0.0

		arco.rotation = (
			direcao_mouse.angle()
			+ CORRECAO_ARCO
		)

		esconder_setas()

	# ==================================================
	# indara EM SUPERFÍCIE
	# ==================================================

	else:

		atualizar_orientacao_parede()
		atualizar_posicao_pivo_seta()

		var direcao_local = (
			direcao_mouse.rotated(-rotacao_superficie)
		)

		# ==================================================
		# SUPERFÍCIE VIRTUAL
		# ==================================================
		#
		# Depois de dano, a indara deve ficar visualmente
		# sempre em pé.
		#
		# A rotação da superfície continua existindo
		# internamente para a lógica do pulo, mas NÃO
		# gira o sprite.
		# ==================================================

		if superficie_virtual:

			sprite.rotation = 0.0

		else:

			sprite.rotation = rotacao_superficie

		# Espelhamento acompanha a direção LOCAL da superfície.
		if direcao_local.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

		var posicao_arco = posicao_original_arco

		if direcao_local.x < 0:
			posicao_arco.x = -posicao_original_arco.x

		$Arco.position = (
			posicao_arco.rotated(rotacao_superficie)
		)

		$Arco.rotation = rotacao_superficie

		arco.rotation = (
			direcao_mouse.angle()
			- rotacao_superficie
			+ CORRECAO_ARCO
		)

		# ==================================================
		# SETA
		# ==================================================

		if not Input.is_action_pressed("acao_arco") and not Input.is_action_pressed("acao_parar"):

			atualizar_seta_pulo(direcao_mouse)

		else:

			esconder_setas()
			pulo_disponivel = false

	# =========================
	# ARCO TOTALMENTE CARREGADO
	# =========================

	if carregando_arco and not arco_carregado:
		som_carregar_arco.play()

		if arco.frame >= ULTIMO_FRAME:

			arco.frame = ULTIMO_FRAME
			arco.pause()

			arco_carregado = true

			if tween_zoom_arco != null:

				tween_zoom_arco.kill()
				tween_zoom_arco = null

			camera.zoom = Vector2(
				zoom_camera_arco,
				zoom_camera_arco
			)

	# Tremor bem leve enquanto o arco está totalmente carregado.
	if carregando_arco and arco_carregado:
		camera.position = posicao_original_camera + Vector2(
			randf_range(-intensidade_tremor_arco, intensidade_tremor_arco),
			randf_range(-intensidade_tremor_arco, intensidade_tremor_arco)
		)
	else:
		camera.position = posicao_original_camera

	# =========================
	# ANIMAÇÃO DO PULO
	# =========================

	if pulando_entre_superficies:

		pulo_parede.rotation = rotacao_pulo
		pulo_parede.flip_h = flip_pulo

# =========================
# PHYSICS PROCESS
# =========================

func _physics_process(_delta):

	if controles_bloqueados:

		velocity = Vector2.ZERO
		return

	# =========================
	# DASH
	# =========================

	if em_movimento and not parado_no_meio:

		velocity = direcao * velocidade
		move_and_slide()

		if get_slide_collision_count() > 0:

			var colisao = get_slide_collision(0)
			var objeto = colisao.get_collider()

			# =========================
			# COLISÃO COM INIMIGO
			# =========================

			if objeto != null and objeto.is_in_group("inimigo"):

				receber_dano(
					objeto.global_position
				)

				return

			# =========================
			# COLISÃO COM SUPERFÍCIE
			# =========================

			normal_parede = colisao.get_normal()
			superficie_virtual = false
			dash_pos_dano_ativo = false
			distancia_dash_virtual_restante = 0.0

			soltar_particulas_pulo()

			em_movimento = false
			parado_no_meio = false
			pode_dar_stop = false

			esta_na_parede = true

			velocity = Vector2.ZERO

			flechas_disparadas = 0
			carregando_arco = false
			arco_carregado = false

			restaurar_zoom_camera()

			arco.visible = false
			arco.stop()
			arco.frame = 0

			if pulando_entre_superficies:

				pulando_entre_superficies = false

				pulo_parede.stop()
				pulo_parede.visible = false

				sprite.visible = true
				sprite.play("default")

			atualizar_orientacao_parede()
			atualizar_posicao_pivo_seta()

			if not Input.is_action_pressed("acao_arco") and not Input.is_action_pressed("acao_parar"):
				atualizar_seta_pulo(
					get_global_mouse_position()
					- global_position
				)

			else:

				esconder_setas()
				pulo_disponivel = false

	# =========================
	# INÍCIO DO DASH
	# =========================

	if Input.is_action_just_pressed("mouse_left"):

		if not em_movimento and not parado_no_meio:

			# =========================
			# SUPERFÍCIE FÍSICA
			# =========================

			if esta_na_parede and not superficie_virtual:

				# A + clique = arco.
				if Input.is_action_pressed("acao_arco"):
					return

			# =========================
			# QUALQUER SUPERFÍCIE
			# =========================

			if esta_na_parede:

				atualizar_seta_pulo(
					get_global_mouse_position()
					- global_position
				)

				if not pulo_disponivel:
					return

				direcao = direcao_pulo

			else:

				var posicao_mouse = get_global_mouse_position()

				var direcao_mouse = (
					posicao_mouse - global_position
				).normalized()

				if direcao_mouse == Vector2.ZERO:
					return

				direcao = direcao_mouse

			if direcao != Vector2.ZERO:

				var estava_em_superficie := esta_na_parede

				em_movimento = true
				som_dash.play()
				parada_por_dano = false

				Estatisticas.registrar_dash()

				pode_dar_stop = true

				esta_na_parede = false

				if estava_em_superficie:

					soltar_particulas_pulo()

					pulando_entre_superficies = true

					rotacao_pulo = rotacao_superficie

					var direcao_local_pulo = (
						direcao.rotated(-rotacao_superficie)
					)

					flip_pulo = (
						direcao_local_pulo.x < 0
					)

					pulo_parede.rotation = rotacao_pulo
					pulo_parede.flip_h = flip_pulo

					sprite.visible = false

					pulo_parede.visible = true
					pulo_parede.frame = 0
					pulo_parede.play("pulo_parede")

					esconder_setas()

				else:

					sprite.visible = false

				carregando_arco = false
				arco_carregado = false

				restaurar_zoom_camera()

				arco.visible = false
				arco.stop()
				arco.frame = 0

# =========================
# INPUT
# =========================

func _input(event):

	# ESC abre o menu de pausa e congela a fase.
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:
			abrir_pausa()
			return

	if controles_bloqueados:
		return

	# =========================
	# TECLADO
	# =========================

	if event is InputEventKey:

		if event.is_action("acao_parar"):

			# =========================
			# APERTOU S
			# =========================

			if event.pressed and not event.echo:

				# S durante dash.
				if em_movimento and pode_dar_stop:

					parado_no_meio = true
					pode_dar_stop = false

					velocity = Vector2.ZERO

					flechas_disparadas = 0

					carregando_arco = false
					arco_carregado = false

					restaurar_zoom_camera()

					arco.visible = false

					if pulando_entre_superficies:

						pulo_parede.pause()
						pulo_parede.visible = false

						sprite.visible = true
						sprite.rotation = 0.0
						sprite.play("default")

						if get_global_mouse_position().x < global_position.x:
							sprite.flip_h = true
						else:
							sprite.flip_h = false

						esconder_setas()

				# S depois de dano.
				elif parada_por_dano:

					parado_no_meio = true

					velocity = Vector2.ZERO

					flechas_disparadas = 0

					carregando_arco = false
					arco_carregado = false

					restaurar_zoom_camera()

					arco.visible = false

					esconder_setas()
					pulo_disponivel = false

			# =========================
			# SOLTOU S
			# =========================

			elif not event.pressed:

				if parado_no_meio:

					# =========================
					# ESTADO DE DANO
					# =========================

					if parada_por_dano:

						parado_no_meio = false
						em_movimento = false
						pode_dar_stop = true

						carregando_arco = false
						arco_carregado = false

						restaurar_zoom_camera()

						arco.visible = false
						arco.stop()
						arco.frame = 0

						return

					# =========================
					# PARADA NORMAL
					# =========================

					parado_no_meio = false
					em_movimento = true

					carregando_arco = false
					arco_carregado = false

					restaurar_zoom_camera()

					arco.visible = false
					arco.stop()
					arco.frame = 0

					if pulando_entre_superficies:

						sprite.visible = false

						pulo_parede.visible = true
						pulo_parede.rotation = rotacao_pulo
						pulo_parede.flip_h = flip_pulo

						pulo_parede.play()

	# =========================
	# MOUSE
	# =========================

	if event is InputEventMouseButton:

		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		# =========================
		# APERTOU
		# =========================

		if event.pressed:

			var pode_carregar := false

			# Depois de dano:
			# S + clique.
			if parado_no_meio:

				pode_carregar = true

			# Parede física:
			# A + clique.
			elif esta_na_parede and not superficie_virtual:

				if Input.is_action_pressed("acao_arco"):

					pode_carregar = true

			if pode_carregar:

				if flechas_disparadas < MAX_FLECHAS:

					if not carregando_arco:

						carregando_arco = true
						arco_carregado = false

						zoom_antes_arco = camera.zoom

						iniciar_zoom_arco()

						arco.visible = true
						arco.stop()
						arco.frame = 0
						arco.play("default")

						sprite.pause()

		# =========================
		# SOLTOU
		# =========================

		else:

			if not carregando_arco:
				return

			# =========================
			# CANCELAMENTO
			# =========================

			if not arco_carregado:

				carregando_arco = false
				arco_carregado = false

				restaurar_zoom_camera()

				arco.stop()
				arco.play("parado")

				sprite.play("default")

				return

			# =========================
			# DISPARO
			# =========================

			atirar_flecha()

			flechas_disparadas += 1

			Estatisticas.registrar_flecha()

			carregando_arco = false
			arco_carregado = false

			# Retorno suave.
			restaurar_zoom_camera()

			sprite.play("default")

			if flechas_disparadas >= MAX_FLECHAS:

				arco.visible = false
				arco.stop()
				arco.frame = 0

			else:

				arco.stop()
				arco.play("parado")

# =========================
# ZOOM DO ARCO
# =========================

func iniciar_zoom_arco():

	if tween_zoom_arco != null:

		tween_zoom_arco.kill()

	tween_zoom_arco = create_tween()

	tween_zoom_arco.set_trans(Tween.TRANS_SINE)
	tween_zoom_arco.set_ease(Tween.EASE_OUT)

	tween_zoom_arco.tween_property(
		camera,
		"zoom",
		Vector2(
			zoom_camera_arco,
			zoom_camera_arco
		),
		duracao_zoom_arco
	)

# =========================
# RESTAURAR ZOOM
# =========================

func restaurar_zoom_camera():

	if derrota_iniciada:
		return

	if not introducao_terminada:
		return

	if tween_zoom_arco != null:

		tween_zoom_arco.kill()
		tween_zoom_arco = null

	var zoom_retorno := zoom_antes_arco

	if zoom_retorno == Vector2.ONE:

		zoom_retorno = Vector2(
			zoom_final_camera,
			zoom_final_camera
		)

	tween_zoom_arco = create_tween()

	tween_zoom_arco.set_trans(Tween.TRANS_SINE)
	tween_zoom_arco.set_ease(Tween.EASE_OUT)

	tween_zoom_arco.tween_property(
		camera,
		"zoom",
		zoom_retorno,
		duracao_retorno_zoom_arco
	)

# =========================
# DESACELERAR INIMIGOS
# =========================

func desacelerar_inimigos():

	for inimigo in get_tree().get_nodes_in_group("inimigo"):

		if inimigo == null:
			continue

		var velocidade_inimigo = inimigo.get("velocidade")

		if velocidade_inimigo != null:

			if not inimigo.has_meta(
				"velocidade_original_s"
			):

				inimigo.set_meta(
					"velocidade_original_s",
					velocidade_inimigo
				)

			inimigo.set(
				"velocidade",
				inimigo.get_meta(
					"velocidade_original_s"
				)
				* FATOR_LENTIDAO_INIMIGOS
			)

		var velocidade_retorno = inimigo.get(
			"velocidade_retorno"
		)

		if velocidade_retorno != null:

			if not inimigo.has_meta(
				"velocidade_retorno_original_s"
			):

				inimigo.set_meta(
					"velocidade_retorno_original_s",
					velocidade_retorno
				)

			inimigo.set(
				"velocidade_retorno",
				inimigo.get_meta(
					"velocidade_retorno_original_s"
				)
				* FATOR_LENTIDAO_INIMIGOS
			)

# =========================
# ACELERAR INIMIGOS
# =========================

func acelerar_inimigos():

	for inimigo in get_tree().get_nodes_in_group("inimigo"):

		if inimigo == null:
			continue

		if inimigo.has_meta(
			"velocidade_original_s"
		):

			inimigo.set(
				"velocidade",
				inimigo.get_meta(
					"velocidade_original_s"
				)
			)

		if inimigo.has_meta(
			"velocidade_retorno_original_s"
		):

			inimigo.set(
				"velocidade_retorno",
				inimigo.get_meta(
					"velocidade_retorno_original_s"
				)
			)

# =========================
# ATIRAR FLECHA
# =========================

func atirar_flecha():

	var flecha = cena_flecha.instantiate()

	get_tree().current_scene.add_child(flecha)

	flecha.global_position = (
		ponto_flecha.global_position
	)

	flecha.dono = self

	var direcao_flecha = (
		get_global_mouse_position()
		- ponto_flecha.global_position
	).normalized()

	flecha.direcao = direcao_flecha

	flecha.rotation = direcao_flecha.angle()

	flecha.iniciar_velocidade()
	await get_tree().create_timer(0.5).timeout
	som_flecha.play()

# =========================
# SETA DE PULO
# =========================

func atualizar_seta_pulo(direcao_mouse: Vector2):
	if controles_bloqueados:
		esconder_setas()
		pulo_disponivel = false
		return

	if not esta_na_parede:

		esconder_setas()
		pulo_disponivel = false
		return

	if direcao_mouse.length_squared() < 0.001:

		esconder_setas()
		pulo_disponivel = false
		return

	var mouse_normalizado = (
		direcao_mouse.normalized()
	)

	# ==================================================
	# SUPERFÍCIE VIRTUAL — PÓS-DANO
	# ==================================================
	#
	# Aqui não existe mais limite angular.
	#
	# O jogador pode mirar:
	# ↑
	# ↗
	# →
	# ↘
	# ↓
	# ↙
	# ←
	# ↖
	#
	# A única restrição é a distância máxima.
	# ==================================================

	if superficie_virtual:

		var direcao_seta = mouse_normalizado

		pivo_seta_pulo.rotation = (
			direcao_seta.angle()
			+ PI / 2.0
		)

		# Depois do dano, a direção é livre em 360 graus,
		# mas ainda é obrigatório existir uma parede no caminho
		# dentro do limite máximo de 350 px.
		var ponto_maximo = (
			global_position
			+ direcao_seta * distancia_maxima_pulo
		)

		var query_virtual = PhysicsRayQueryParameters2D.create(
			global_position,
			ponto_maximo
		)

		query_virtual.exclude = [self]
		query_virtual.collision_mask = 1

		var resultado_virtual = (
			get_world_2d()
			.direct_space_state
			.intersect_ray(query_virtual)
		)

		if resultado_virtual.is_empty():

			pulo_disponivel = false
			ponto_destino_pulo = ponto_maximo
			direcao_pulo = direcao_seta

			seta_pulo_disponivel.visible = false
			seta_pulo_indisponivel.visible = true
			return

		pulo_disponivel = true
		ponto_destino_pulo = resultado_virtual.position
		direcao_pulo = direcao_seta

		seta_pulo_disponivel.visible = true
		seta_pulo_indisponivel.visible = false

		return

	# ==================================================
	# SUPERFÍCIE FÍSICA NORMAL
	# ==================================================

	var direcao_frente = (
		Vector2.UP.rotated(rotacao_superficie)
	).normalized()

	var angulo = (
		direcao_frente.angle_to(mouse_normalizado)
	)

	var angulo_graus = rad_to_deg(angulo)

	var angulo_absoluto = abs(angulo_graus)

	# =========================
	# FORA DO ÂNGULO
	# =========================

	if angulo_absoluto > angulo_desaparecer_seta:

		pulo_disponivel = false

		esconder_setas()

		return

	var direcao_seta = (
		direcao_frente.rotated(angulo)
	).normalized()

	pivo_seta_pulo.rotation = (
		direcao_seta.angle()
		+ PI / 2.0
	)

	# =========================
	# ÂNGULO PERMITIDO
	# =========================

	if angulo_absoluto <= angulo_maximo_pulo:

		var ponto_maximo = (
			global_position
			+ direcao_seta * distancia_maxima_pulo
		)

		var query = PhysicsRayQueryParameters2D.create(
			global_position,
			ponto_maximo
		)

		query.exclude = [self]

		# Apenas superfícies.
		query.collision_mask = 1

		var resultado = (
			get_world_2d()
			.direct_space_state
			.intersect_ray(query)
		)

		if resultado.is_empty():

			pulo_disponivel = false

			ponto_destino_pulo = ponto_maximo

			seta_pulo_disponivel.visible = false
			seta_pulo_indisponivel.visible = true

			return

		pulo_disponivel = true

		ponto_destino_pulo = resultado.position

		direcao_pulo = direcao_seta

		seta_pulo_disponivel.visible = true
		seta_pulo_indisponivel.visible = false

		return

	# =========================
	# ÂNGULO NÃO PERMITIDO
	# =========================

	pulo_disponivel = false

	seta_pulo_disponivel.visible = false
	seta_pulo_indisponivel.visible = true

# =========================
# ESCONDER SETAS
# =========================

func esconder_setas():

	seta_pulo_disponivel.visible = false
	seta_pulo_indisponivel.visible = false

# =========================
# PREPARAR SUPERFÍCIE INICIAL
# =========================

func preparar_superficie_inicial():

	esta_na_parede = true
	superficie_virtual = false

	normal_parede = Vector2.UP

	var resultado = detectar_superficie_proxima()

	if not resultado.is_empty():

		normal_parede = resultado.normal
		superficie_virtual = false

	else:

		normal_parede = Vector2.UP
		superficie_virtual = true

	atualizar_orientacao_parede()
	atualizar_posicao_pivo_seta()

	var direcao_mouse := (
		get_global_mouse_position()
		- global_position
	)

	if not Input.is_action_pressed("acao_arco"):

		atualizar_seta_pulo(
			direcao_mouse
		)

	else:

		esconder_setas()
		pulo_disponivel = false

# =========================
# DETECTAR SUPERFÍCIE PRÓXIMA
# =========================

func detectar_superficie_proxima() -> Dictionary:

	var espaco = (
		get_world_2d().direct_space_state
	)

	var direcoes = [
		Vector2.DOWN,
		Vector2.UP,
		Vector2.LEFT,
		Vector2.RIGHT
	]

	var melhor_resultado: Dictionary = {}

	var menor_distancia := INF

	for direcao_raio in direcoes:

		var inicio = global_position

		var fim = (
			global_position
			+ direcao_raio * 20.0
		)

		var query = PhysicsRayQueryParameters2D.create(
			inicio,
			fim
		)

		query.exclude = [self]
		query.collision_mask = 1

		var resultado = (
			espaco.intersect_ray(query)
		)

		if not resultado.is_empty():

			var distancia = (
				global_position.distance_to(
					resultado.position
				)
			)

			if distancia < menor_distancia:

				menor_distancia = distancia

				melhor_resultado = resultado

	return melhor_resultado

# =========================
# FINALIZAR PULO
# =========================

func finalizar_pulo():

	pulando_entre_superficies = false

	pulo_parede.stop()
	pulo_parede.visible = false

	sprite.visible = true
	sprite.play("default")

	if superficie_virtual:

		sprite.rotation = 0.0

	else:

		atualizar_orientacao_parede()

	atualizar_posicao_pivo_seta()

	if not Input.is_action_pressed("acao_arco"):

		atualizar_seta_pulo(
			get_global_mouse_position()
			- global_position
		)

	else:

		esconder_setas()
		pulo_disponivel = false

# =========================
# ORIENTAÇÃO NORMAL
# =========================

func atualizar_orientacao():

	rotacao_superficie = 0.0

	sprite.rotation = 0.0
	sprite.flip_h = false
	sprite.visible = true
	sprite.play("default")

	pulo_parede.rotation = 0.0
	pulo_parede.flip_h = false
	pulo_parede.visible = false
	pulo_parede.stop()

	pivo_seta_pulo.rotation = 0.0

	atualizar_posicao_pivo_seta()

	esconder_setas()

	$Arco.rotation = 0.0
	$Arco.position = posicao_original_arco

	arco.rotation = 0.0

# =========================
# ORIENTAÇÃO DA SUPERFÍCIE
# =========================

func atualizar_orientacao_parede():

	if normal_parede.y < -0.7:

		rotacao_superficie = 0.0

	elif normal_parede.y > 0.7:

		rotacao_superficie = PI

	elif normal_parede.x > 0.7:

		rotacao_superficie = PI / 2.0

	elif normal_parede.x < -0.7:

		rotacao_superficie = -PI / 2.0

# =========================
# POSIÇÃO DO PIVÔ DA SETA
# =========================

func atualizar_posicao_pivo_seta():

	pivo_seta_pulo.position = (
		posicao_original_pivo_seta
		.rotated(rotacao_superficie)
	)

# =========================
# CORAÇÕES
# =========================

func preparar_coracoes():
	coracao1.visible = false
	coracao2.visible = false
	coracao3.visible = false

	coracao1.modulate.a = 1.0
	coracao2.modulate.a = 1.0
	coracao3.modulate.a = 1.0

	coracao1.stop()
	coracao2.stop()
	coracao3.stop()

	coracao1.play("cheio")
	coracao2.play("cheio")
	coracao3.play("cheio")


func mostrar_coracoes():
	coracao1.visible = true
	coracao2.visible = true
	coracao3.visible = true

	coracao1.modulate.a = 1.0
	coracao2.modulate.a = 1.0
	coracao3.modulate.a = 1.0

	coracao1.play("cheio")
	coracao2.play("cheio")
	coracao3.play("cheio")


func atualizar_coracao_dano():
	if vidas == 2:
		animar_coracao_dano(coracao3)

	elif vidas == 1:
		animar_coracao_dano(coracao2)

	elif vidas <= 0:
		animar_coracao_dano(coracao1)


func animar_coracao_dano(coracao: AnimatedSprite2D):
	if coracao == null:
		return

	coracao.visible = true
	coracao.modulate.a = 1.0

	# A animação de dano toca apenas uma vez.
	coracao.sprite_frames.set_animation_loop("dano", false)
	coracao.play("dano")

	var quantidade_frames := coracao.sprite_frames.get_frame_count("dano")
	var velocidade_animacao := coracao.sprite_frames.get_animation_speed("dano")

	if quantidade_frames > 0 and velocidade_animacao > 0:
		await get_tree().create_timer(
			float(quantidade_frames) / velocidade_animacao
		).timeout

	# Congela exatamente no último frame:
	# o coração permanece quebrado enquanto desaparece.
	coracao.frame = quantidade_frames - 1
	coracao.pause()

	# Desaparecimento um pouco mais lento e suave.
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(
		coracao,
		"modulate:a",
		0.0,
		0.65
	)

	await tween.finished

	coracao.visible = false


# =========================
# RECEBER DANO
# =========================

func receber_dano(posicao_inimigo: Vector2): 

	if derrota_iniciada:
		return

	vidas -= 1
	som_dano.play()

	atualizar_coracao_dano()

	print("indara PERDEU UMA VIDA!")
	print("VIDAS RESTANTES: ", vidas)

	if vidas <= 0:

		iniciar_derrota()
		return

	# =========================
	# PARAR MOVIMENTO
	# =========================

	em_movimento = false
	parado_no_meio = false
	pode_dar_stop = true

	velocity = Vector2.ZERO

	parada_por_dano = true

	# =========================
	# RESET DA ANIMAÇÃO
	# =========================

	pulando_entre_superficies = false

	pulo_parede.stop()
	pulo_parede.visible = false

	sprite.visible = true

	# Sempre virada para cima.
	sprite.rotation = 0.0
	sprite.play("default")

	# Sempre espelha de acordo com o cursor.
	if get_global_mouse_position().x < global_position.x:

		sprite.flip_h = true

	else:

		sprite.flip_h = false

	# =========================
	# EMPURRÃO
	# =========================

	var direcao_empurrao: Vector2 = (
		posicao_inimigo.direction_to(
			global_position
		)
	).normalized()

	var movimento_empurrao: Vector2 = Vector2.ZERO

	if direcao_empurrao.length_squared() > 0.001:

		movimento_empurrao = (
			direcao_empurrao * 10.0
		)

	elif direcao.length_squared() > 0.001:

		movimento_empurrao = (
			-direcao.normalized() * 10.0
		)

	else:

		movimento_empurrao = Vector2.UP * 10.0

	# Testa com a área/corpo real da indara.
	# Isso impede que o empurrão atravesse a parede.
	if not test_move(
		global_transform,
		movimento_empurrao
	):

		global_position += movimento_empurrao

	else:

		# Se estiver encostada na parede na direção
		# do empurrão, tenta um dos dois lados.
		var lateral_direita: Vector2 = Vector2(
			-movimento_empurrao.y,
			movimento_empurrao.x
		).normalized() * 10.0

		var lateral_esquerda: Vector2 = (
			-lateral_direita
		)

		if not test_move(
			global_transform,
			lateral_direita
		):

			global_position += lateral_direita

		elif not test_move(
			global_transform,
			lateral_esquerda
		):

			global_position += lateral_esquerda

	# =========================
	# SUPERFÍCIE VIRTUAL
	# =========================

	esta_na_parede = true
	superficie_virtual = true
	dash_pos_dano_ativo = true
	distancia_dash_virtual_restante = 0.0

	# IMPORTANTE:
	# A direção do empurrão NÃO determina mais
	# a direção permitida do próximo dash.
	#
	# O jogador poderá mirar livremente em 360°.
	normal_parede = Vector2.UP

	rotacao_superficie = 0.0

	atualizar_posicao_pivo_seta()

	# =========================
	# LIMPAR ARCO
	# =========================

	flechas_disparadas = 0

	carregando_arco = false
	arco_carregado = false

	restaurar_zoom_camera()

	arco.visible = false
	arco.stop()
	arco.frame = 0

	# =========================
	# SETA LIVRE APÓS DANO
	# =========================

	atualizar_seta_pulo(
		get_global_mouse_position()
		- global_position
	)

	print(
		"indara PODE DAR UM NOVO DASH EM QUALQUER DIREÇÃO DENTRO DOS ",
		distancia_maxima_pulo,
		" PX."
	)

# =========================
# SAÍDA PELO ESC
# =========================

func abrir_pausa():
	if jogo_pausado or derrota_iniciada:
		return

	jogo_pausado = true

	# Instancia a cena da pausa por cima da fase.
	menu_pausa = cena_pausa.instantiate()
	menu_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(menu_pausa)

	# Congela absolutamente tudo da fase.
	get_tree().paused = true


func fechar_pausa():
	get_tree().paused = false
	jogo_pausado = false

	if is_instance_valid(menu_pausa):
		menu_pausa.queue_free()

	menu_pausa = null


func iniciar_derrota():

	if derrota_iniciada:
		$TransicaoDerrota/EfeitoEscuridao.visible = true
		return

	som_risada.play()

	# resto da função...

	derrota_iniciada = true

	Estatisticas.finalizar_derrota()

	print("indara MORREU!")

	controles_bloqueados = true

	em_movimento = false
	parado_no_meio = false
	pode_dar_stop = false

	velocity = Vector2.ZERO

	carregando_arco = false
	arco_carregado = false

	if tween_zoom_arco != null:
		tween_zoom_arco.kill()
		tween_zoom_arco = null

	arco.visible = false
	arco.stop()
	arco.frame = 0

	esconder_setas()

	pulo_parede.stop()
	pulo_parede.visible = false

	sprite.visible = true
	sprite.rotation = 0.0
	sprite.play("default")


	# =========================
	# SHADER DE DERROTA
	# =========================

	var efeito_escuridao: ColorRect = $TransicaoDerrota/EfeitoEscuridao

	efeito_escuridao.visible = true

	var material: ShaderMaterial = efeito_escuridao.material as ShaderMaterial

	material.set_shader_parameter(
		"progresso",
		0.0
	)

	var tween_shader := create_tween()

	tween_shader.set_trans(Tween.TRANS_SINE)
	tween_shader.set_ease(Tween.EASE_IN)

	tween_shader.tween_method(
		func(valor):
			material.set_shader_parameter(
				"progresso",
				valor
			),
		0.0,
		1.0,
		duracao_animacao_derrota
	)


	# =========================
	# DESCARGA / DESAPARECIMENTO
	# =========================
	#
	# A indara gira 360° enquanto diminui
	# e fica cada vez mais transparente.
	# =========================

	if tween_derrota != null:
		tween_derrota.kill()

	sprite.modulate.a = 1.0
	sprite.scale = Vector2.ONE

	tween_derrota = create_tween()
	tween_derrota.set_parallel(true)
	tween_derrota.set_trans(Tween.TRANS_SINE)
	tween_derrota.set_ease(Tween.EASE_IN)

	tween_derrota.tween_property(
		sprite,
		"rotation",
		TAU * voltas_derrota,
		duracao_animacao_derrota
	)

	tween_derrota.tween_property(
		sprite,
		"scale",
		Vector2(
			escala_final_derrota,
			escala_final_derrota
		),
		duracao_animacao_derrota
	)

	tween_derrota.tween_property(
		sprite,
		"modulate:a",
		opacidade_final_derrota,
		duracao_animacao_derrota
	)

	cronometro.parar()

	if not esc_distanciando:
		var tween_camera := create_tween()

		tween_camera.set_trans(Tween.TRANS_SINE)
		tween_camera.set_ease(Tween.EASE_OUT)

		tween_camera.tween_property(
			camera,
			"zoom",
			Vector2(1.4, 1.4),
			1.2
		)

		await tween_camera.finished

	await get_tree().create_timer(
	duracao_animacao_derrota + 0.5
).timeout

	get_tree().change_scene_to_file(
		"res://cenas/teladerrota.tscn"
	)

	# =========================
	# DESCARGA / DESAPARECIMENTO
	# =========================
	#
	# A indara gira 360° enquanto diminui
	# e fica cada vez mais transparente.
	# =========================

	if tween_derrota != null:
		tween_derrota.kill()

	sprite.modulate.a = 1.0
	sprite.scale = Vector2.ONE

	tween_derrota = create_tween()
	tween_derrota.set_parallel(true)
	tween_derrota.set_trans(Tween.TRANS_SINE)
	tween_derrota.set_ease(Tween.EASE_IN)

	tween_derrota.tween_property(
		sprite,
		"rotation",
		TAU * voltas_derrota,
		duracao_animacao_derrota
	)

	tween_derrota.tween_property(
		sprite,
		"scale",
		Vector2(
			escala_final_derrota,
			escala_final_derrota
		),
		duracao_animacao_derrota
	)

	tween_derrota.tween_property(
		sprite,
		"modulate:a",
		opacidade_final_derrota,
		duracao_animacao_derrota
	)

	cronometro.parar()

	if not esc_distanciando:
		var tween_camera := create_tween()

		tween_camera.set_trans(Tween.TRANS_SINE)
		tween_camera.set_ease(Tween.EASE_OUT)

		tween_camera.tween_property(
			camera,
			"zoom",
			Vector2(1.4, 1.4),
			1.2
		)

		await tween_camera.finished

	await get_tree().create_timer(
		duracao_animacao_derrota + 0.5
	).timeout

	get_tree().change_scene_to_file(
		"res://cenas/teladerrota.tscn"
	)

# =========================
# INTRODUÇÃO DA CÂMERA
# =========================

func iniciar_intro_camera():

	controles_bloqueados = true
	introducao_terminada = false

	em_movimento = false
	parado_no_meio = false
	pode_dar_stop = false

	velocity = Vector2.ZERO

	camera.zoom = Vector2(
		zoom_inicial_camera,
		zoom_inicial_camera
	)

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		camera,
		"zoom",
		Vector2(
			zoom_final_camera,
			zoom_final_camera
		),
		duracao_zoom_camera
	)

	await tween.finished

	introducao_terminada = true
	controles_bloqueados = false

	preparar_superficie_inicial()

	Estatisticas.iniciar_tempo()
	cronometro.iniciar()
	mostrar_coracoes()
