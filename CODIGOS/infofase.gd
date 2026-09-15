extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer
@onready var nome_fase: Label = $NomeFase
@onready var descricao: Label = $Descricao
@onready var tempo: Label = $Tempo
@onready var fade: ColorRect = $ColorRectFade

@onready var botao_iniciar: Button = $IniciarFase
@onready var botao_voltar: Button = $VoltarFases

var escalas_originais := {}


func _ready() -> void:
	var fase = Gerenciadorfases.fase_selecionada

	if fase == 1:
		nome_fase.text = "FASE 1"
		descricao.text = "Não se esqueça daquilo que é importante para você."
		tempo.text = "TEMPO: 03:00"

	elif fase == 2:
		nome_fase.text = "FASE 2"
		descricao.text = "O sonho começa a se desfazer."
		tempo.text = "TEMPO: 02:30"

	elif fase == 3:
		nome_fase.text = "FASE 3"
		descricao.text = "Chegue ao núcleo antes que seja tarde."
		tempo.text = "TEMPO: 02:00"

	elif fase == 4:
		nome_fase.text = "FASE 4"
		descricao.text = "Chegue ao núcleo antes que seja tarde."
		tempo.text = "TEMPO: 02:00"

	elif fase == 5:
		nome_fase.text = "FASE 5"
		descricao.text = "Chegue ao núcleo antes que seja tarde."
		tempo.text = "TEMPO: 02:00"

	elif fase == 6:
		nome_fase.text = "FASE 6"
		descricao.text = "Chegue ao núcleo antes que seja tarde."
		tempo.text = "TEMPO: 02:00"

	configurar_hover(botao_iniciar)
	configurar_hover(botao_voltar)


func configurar_hover(botao: Button) -> void:
	escalas_originais[botao] = botao.scale

	# Faz o botão crescer pelo centro.
	botao.pivot_offset = botao.size / 2.0

	botao.mouse_entered.connect(_mouse_entrou.bind(botao))
	botao.mouse_exited.connect(_mouse_saiu.bind(botao))


func _mouse_entrou(botao: Button) -> void:
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


func _on_iniciar_fase_pressed() -> void:
	await Efeito.fechar()
	get_tree().change_scene_to_file("res://CENAS/prejogo.tscn")


func _on_voltar_fases_pressed() -> void:
	fade.color = Color(0.0, 0.0, 0.0, 0.0)

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		fade,
		"color:a",
		1.0,
		1.0
	)

	await tween.finished

	get_tree().change_scene_to_file("res://CENAS/fases.tscn")
