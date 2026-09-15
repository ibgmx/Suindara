extends Control

@onready var tempo: Label = $Tempo
@onready var dashs: Label = $Dashs
@onready var flechas: Label = $Flechas
@onready var inimigos: Label = $Inimigos
@onready var tentativas_label: Label = $Tentativas

var escalas_originais := {}


func _ready() -> void:
	# Prepara as estatísticas
	tempo.text = "TEMPO: " + Estatisticas.obter_tempo_formatado()
	dashs.text = "DASHs: " + str(Estatisticas.obter_dashs())
	flechas.text = "FLECHAS: " + str(Estatisticas.obter_flechas())
	inimigos.text = "INIMIGOS DERROTADOS: " + str(Estatisticas.obter_inimigos())
	tentativas_label.text = "TENTATIVAS: " + str(Estatisticas.obter_tentativa())

	# Esconde as estatísticas
	tempo.visible = false
	dashs.visible = false
	flechas.visible = false
	inimigos.visible = false
	tentativas_label.visible = false

	# Esconde os botões e configura o hover
	for filho in get_children():
		if filho is Button:
			filho.visible = false

			escalas_originais[filho] = filho.scale
			filho.pivot_offset = filho.size / 2.0

			filho.mouse_entered.connect(_mouse_entrou.bind(filho))
			filho.mouse_exited.connect(_mouse_saiu.bind(filho))

	iniciar_estatisticas()


func iniciar_estatisticas() -> void:
	var estatisticas = [
		tempo,
		dashs,
		flechas,
		inimigos,
		tentativas_label
	]

	for estatistica in estatisticas:
		estatistica.visible = true

		await get_tree().create_timer(0.7).timeout

	# Mostra os botões somente depois de tudo
	for filho in get_children():
		if filho is Button:
			filho.visible = true


func _mouse_entrou(botao: Button) -> void:
	if botao.disabled:
		return

	var escala_original: Vector2 = escalas_originais[botao]

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		botao,
		"scale",
		escala_original * 1.08,
		0.12
	)


func _mouse_saiu(botao: Button) -> void:
	if not escalas_originais.has(botao):
		return

	var escala_original: Vector2 = escalas_originais[botao]

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		botao,
		"scale",
		escala_original,
		0.12
	)


func _on_reiniciar_pressed() -> void:
	var fase = Gerenciadorfases.fase_selecionada

	if fase == 1:
		get_tree().change_scene_to_file("res://PESADELOS/pesadelo-1.tscn")

	elif fase == 2:
		get_tree().change_scene_to_file("res://PESADELOS/pesadelo-2.tscn")

	elif fase == 3:
		get_tree().change_scene_to_file("res://PESADELOS/pesadelo-3.tscn")

	elif fase == 4:
		get_tree().change_scene_to_file("res://PESADELOS/pesadelo-4.tscn")

	elif fase == 5:
		get_tree().change_scene_to_file("res://PESADELOS/pesadelo-5.tscn")

	elif fase == 6:
		get_tree().change_scene_to_file("res://PESADELOS/pesadelo-6.tscn")
