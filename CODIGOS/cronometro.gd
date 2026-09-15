extends Label

# Quanto menor o número, mais afastada fica a câmera.
@export var zoom_derrota := 1.5

# Tempo do afastamento da câmera.
@export var duracao_afastamento := 3

# Tempo parada antes de mudar para a tela de derrota.
@export var tempo_antes_da_derrota := 2


var tempo_da_fase := 180
var tempo_restante := 0.0
var ativo := false
var derrota_iniciada := false


func _ready():
	tempo_da_fase = Gerenciadorfases.obter_tempo_fase(
		Gerenciadorfases.fase_selecionada
	)

	tempo_restante = tempo_da_fase

	atualizar_texto()


func iniciar():
	tempo_da_fase = Gerenciadorfases.obter_tempo_fase(
		Gerenciadorfases.fase_selecionada
	)

	tempo_restante = tempo_da_fase
	ativo = true
	derrota_iniciada = false

	atualizar_texto()


func parar():
	ativo = false


func _process(delta):
	if not ativo:
		return

	tempo_restante -= delta

	if tempo_restante <= 0.0:
		tempo_restante = 0.0
		ativo = false

		atualizar_texto()

		tempo_esgotado()

		return

	atualizar_texto()


func atualizar_texto():
	var segundos: int = int(ceil(tempo_restante))

	var minutos: int = segundos / 60
	var segundos_restantes: int = segundos % 60

	text = "%02d:%02d" % [
		minutos,
		segundos_restantes
	]


# ==========================================
# TEMPO ESGOTADO
# ==========================================

func tempo_esgotado():
	var indara = get_tree().current_scene.get_node("Suindara/Indara")

	Estatisticas.finalizar_derrota()

	if indara.has_method("iniciar_derrota"):
		indara.iniciar_derrota()


# ==========================================
# SEQUÊNCIA DE DERROTA
# ==========================================

func iniciar_derrota():

	# ------------------------------------------
	# PEGA O INDARA
	# ------------------------------------------

	var indara = get_tree().current_scene.get_node("indara/indara")

	var camera: Camera2D = indara.get_node("Camera2D")


	# ------------------------------------------
	# CONGELA O INDARA
	# ------------------------------------------

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


	# ------------------------------------------
	# AFASTA A CÂMERA
	# ------------------------------------------

	var tween_camera := create_tween()

	tween_camera.set_trans(Tween.TRANS_SINE)
	tween_camera.set_ease(Tween.EASE_OUT)

	tween_camera.tween_property(
		camera,
		"zoom",
		Vector2(zoom_derrota, zoom_derrota),
		duracao_afastamento
	)

	await tween_camera.finished


	# ------------------------------------------
	# PEQUENA PAUSA
	# ------------------------------------------

	await get_tree().create_timer(
		tempo_antes_da_derrota
	).timeout


	# ------------------------------------------
	# TELA DE DERROTA
	# ------------------------------------------

	get_tree().change_scene_to_file(
		"res://cenas/teladerrota.tscn"
	)


# ==========================================
# OBTER TEMPO GASTO
# ==========================================

func obter_tempo_gasto() -> float:
	return tempo_da_fase - tempo_restante
