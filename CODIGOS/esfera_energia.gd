extends Area2D

@export var tempo_antes_da_vitoria := 6.0
@export var altura := 4.0
@export var velocidade := 3.0

@export var duracao_movimento_camera := 1.5

# Alcance máximo do tremor da esfera.
@export var alcance_tremor := 4.0

# Quanto menor, mais rápido muda de direção.
@export var intervalo_tremor := 0.04

# Arquivo que esta esfera desbloqueia.
@export_range(1, 6) var numero_arquivo := 1

# Fase correspondente a esta esfera.
@export_range(1, 6) var numero_fase := 1

var posicao_inicial := Vector2.ZERO
var tempo := 0.0
var sequencia_iniciada := false
var tremendo := false
var tempo_tremor := 0.0

var deslocamento_tremor := Vector2.ZERO
var novo_deslocamento_tremor := Vector2.ZERO

@onready var indara = get_tree().current_scene.get_node("Suindara/Indara")
@onready var cronometro: Label = get_tree().current_scene.get_node("HUD/Cronometro")

@onready var camera_vitoria: Camera2D = $CameraVitoria
@onready var efeito_raios: ColorRect = $TransicaoVitoria/EfeitoRaios
@onready var som_explosao: AudioStreamPlayer = $Explosao


func _ready():

	$Esfera.sprite_frames.set_animation_loop("padrão", true)
	$Esfera.play("padrão")

	posicao_inicial = position

	camera_vitoria.enabled = false
	camera_vitoria.top_level = true

	camera_vitoria.limit_enabled = false
	camera_vitoria.position_smoothing_enabled = false
	camera_vitoria.drag_horizontal_enabled = false
	camera_vitoria.drag_vertical_enabled = false
	camera_vitoria.offset = Vector2.ZERO

	efeito_raios.visible = false


func _process(delta):

	# ==========================================
	# ESFERA FLUTUANDO NORMALMENTE
	# ==========================================

	if not sequencia_iniciada:

		tempo += delta

		position.y = posicao_inicial.y + sin(
			tempo * velocidade
		) * altura

		return


	# ==========================================
	# TREMOR CAÓTICO
	# ==========================================

	if tremendo:

		tempo_tremor += delta

		if tempo_tremor >= intervalo_tremor:

			tempo_tremor = 0.0

			novo_deslocamento_tremor = Vector2(
				randf_range(
					-alcance_tremor,
					alcance_tremor
				),
				randf_range(
					-alcance_tremor,
					alcance_tremor
				)
			)

		deslocamento_tremor = deslocamento_tremor.lerp(
			novo_deslocamento_tremor,
			0.8
		)

		position = posicao_inicial + deslocamento_tremor


func morrer():

	if sequencia_iniciada:
		return

	sequencia_iniciada = true

	position = posicao_inicial
	tempo = 0.0

	deslocamento_tremor = Vector2.ZERO
	novo_deslocamento_tremor = Vector2.ZERO
	tempo_tremor = 0.0

	var vidas = get_tree().current_scene.get_node("HUD/Vidas")
	vidas.visible = false

	print("================================")
	print("ESFERA ATINGIDA!")
	print("FASE ATUAL: ", numero_fase)
	print("ARQUIVO DA FASE: ", numero_arquivo)

	# ==========================================
	# DESBLOQUEAR ARQUIVO
	# ==========================================

	if controles != null:

		controles.desbloquear_arquivo(
			numero_arquivo
		)

		print(
			"ARQUIVO ",
			numero_arquivo,
			" FOI DESBLOQUEADO!"
		)

		# ==========================================
		# DESBLOQUEAR PRÓXIMA FASE
		# ==========================================

		if numero_fase < 6:

			var proxima_fase := numero_fase + 1

			controles.desbloquear_fase(
				proxima_fase
			)

			print(
				"FASE ",
				proxima_fase,
				" FOI DESBLOQUEADA!"
			)

	else:

		push_error(
			"ERRO: o Autoload 'controles' não foi encontrado!"
		)

	print("================================")

	iniciar_sequencia_vitoria()


func iniciar_sequencia_vitoria():

	# ==========================================
	# 1. PARAR O JOGO
	# ==========================================

	cronometro.parar()
	Estatisticas.finalizar_fase()

	indara.controles_bloqueados = true
	indara.em_movimento = false
	indara.parado_no_meio = false
	indara.pode_dar_stop = false
	indara.velocity = Vector2.ZERO

	indara.carregando_arco = false
	indara.arco_carregado = false
	indara.arco.visible = false
	indara.arco.stop()
	indara.arco.frame = 0

	indara.esconder_setas()
	indara.pulo_disponivel = false


	# ==========================================
	# 2. POSIÇÃO REAL ATUAL DA CÂMERA
	# ==========================================

	var camera_indara: Camera2D = indara.get_node("Camera2D")

	var posicao_camera_inicial: Vector2 = (
		camera_indara.get_screen_center_position()
	)


	# ==========================================
	# 3. POSIÇÃO DA ESFERA
	# ==========================================

	var posicao_camera_final: Vector2 = global_position


	# ==========================================
	# 4. DESLIGAR CÂMERA DA INDARA
	# ==========================================

	camera_indara.enabled = false


	# ==========================================
	# 5. PREPARAR CÂMERA DE VITÓRIA
	# ==========================================

	camera_vitoria.top_level = true
	camera_vitoria.limit_enabled = false
	camera_vitoria.position_smoothing_enabled = false

	camera_vitoria.drag_horizontal_enabled = false
	camera_vitoria.drag_vertical_enabled = false

	camera_vitoria.offset = Vector2.ZERO

	camera_vitoria.global_position = posicao_camera_inicial

	camera_vitoria.enabled = true
	camera_vitoria.make_current()


	# ==========================================
	# 6. VIAJAR ATÉ A ESFERA
	# ==========================================

	var tween_camera := create_tween()

	tween_camera.set_trans(Tween.TRANS_SINE)
	tween_camera.set_ease(Tween.EASE_IN_OUT)

	tween_camera.tween_property(
		camera_vitoria,
		"global_position",
		posicao_camera_final,
		duracao_movimento_camera
	)

	await tween_camera.finished

	camera_vitoria.global_position = posicao_camera_final


	# ==========================================
	# 7. COMEÇAR TRANSIÇÃO
	# ==========================================

	som_explosao.play()

	efeito_raios.visible = true

	var material := efeito_raios.material as ShaderMaterial

	material.set_shader_parameter(
		"progresso",
		0.0
	)

	tremendo = true

	tempo_tremor = 0.0
	deslocamento_tremor = Vector2.ZERO
	novo_deslocamento_tremor = Vector2.ZERO


	# ==========================================
	# 8. RAIOS + TREMOR DURANTE 5 SEGUNDOS
	# ==========================================

	var tempo_transicao := 0.0

	while tempo_transicao < 5.0:

		await get_tree().process_frame

		tempo_transicao += get_process_delta_time()

		var progresso := tempo_transicao / 5.0

		material.set_shader_parameter(
			"progresso",
			progresso
		)


	# ==========================================
	# 9. TERMINAR TREMOR
	# ==========================================

	tremendo = false
	position = posicao_inicial


	# ==========================================
	# 10. IR PARA TELA DE VITÓRIA
	# ==========================================

	remove_child(som_explosao)
	get_tree().root.add_child(som_explosao)

	get_tree().change_scene_to_file(
		"res://cenas/telavitoria.tscn"
	)
