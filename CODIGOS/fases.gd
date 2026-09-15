extends Control


@onready var botao_fase1: Button = $BotaoFase1
@onready var botao_fase2: Button = $BotaoFase2
@onready var botao_fase3: Button = $BotaoFase3
@onready var botao_fase4: Button = $BotaoFase4
@onready var botao_fase5: Button = $BotaoFase5
@onready var botao_fase6: Button = $BotaoFase6

@onready var fade_entrada: ColorRect = $ColorRectFadeEntrada

var escalas_originais := {}


func _ready() -> void:
	fade_entrada.color = Color(0, 0, 0, 1)

	await get_tree().process_frame

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		fade_entrada,
		"color:a",
		0.0,
		1.0
	)

	atualizar_botoes()
	configurar_hovers()


func atualizar_botoes() -> void:
	botao_fase1.disabled = false
	botao_fase2.disabled = not controles.fase_desbloqueada(2)
	botao_fase3.disabled = not controles.fase_desbloqueada(3)
	botao_fase4.disabled = not controles.fase_desbloqueada(4)
	botao_fase5.disabled = not controles.fase_desbloqueada(5)
	botao_fase6.disabled = not controles.fase_desbloqueada(6)


func configurar_hovers() -> void:
	registrar_hover(botao_fase1)
	registrar_hover(botao_fase2)
	registrar_hover(botao_fase3)
	registrar_hover(botao_fase4)
	registrar_hover(botao_fase5)
	registrar_hover(botao_fase6)


func registrar_hover(botao: Button) -> void:
	if botao == null:
		return

	escalas_originais[botao] = botao.scale

	# Faz o aumento acontecer pelo centro.
	botao.pivot_offset = botao.size / 2.0

	botao.mouse_entered.connect(_mouse_entrou.bind(botao))
	botao.mouse_exited.connect(_mouse_saiu.bind(botao))


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


func _on_botao_fase_1_pressed() -> void:
	SomMenu.stop()
	Gerenciadorfases.fase_selecionada = 1

	get_tree().change_scene_to_file(
		"res://CENAS/entradafase.tscn"
	)


func _on_botao_fase_2_pressed() -> void:
	Gerenciadorfases.fase_selecionada = 2

	get_tree().change_scene_to_file(
		"res://CENAS/entradafase.tscn"
	)


func _on_botao_fase_3_pressed() -> void:
	Gerenciadorfases.fase_selecionada = 3

	get_tree().change_scene_to_file(
		"res://CENAS/entradafase.tscn"
	)


func _on_botao_fase_4_pressed() -> void:
	Gerenciadorfases.fase_selecionada = 4

	get_tree().change_scene_to_file(
		"res://CENAS/entradafase.tscn"
	)


func _on_botao_fase_5_pressed() -> void:
	Gerenciadorfases.fase_selecionada = 5

	get_tree().change_scene_to_file(
		"res://CENAS/entradafase.tscn"
	)


func _on_botao_fase_6_pressed() -> void:
	Gerenciadorfases.fase_selecionada = 6

	get_tree().change_scene_to_file(
		"res://CENAS/entradafase.tscn"
	)


func _on_button_pressed() -> void:
	fade_entrada.color = Color(0, 0, 0, 1)

	await get_tree().process_frame

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		fade_entrada,
		"color:a",
		0.0,
		1.0
	)

	get_tree().change_scene_to_file(
		"res://PESADELOS/pesadelo-1.tscn"
	)
