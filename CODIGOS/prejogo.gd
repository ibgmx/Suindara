extends CanvasLayer

@onready var texto: Label = $Fundo/Texto
@onready var botao_pular: Button = $Fundo/BotaoPular

var escalas_originais := {}
var introducao_pulada := false

var textos_por_fase := {
	1: [
		"Lembra-se, eles não são reais.",
		"Eles não sentem dor.",
		"Você pode fazer isso."
	],
	2: [
		"Lembra-se... nada é real.",
		"Eles não vão machucar nínguem.",
		"Você precisa fazer isso"
	],
	3: [
		"Eles... não são reais.",
		"Está tudo bem, eles não sentem dor.",
		"Você deve fazer isso."
	],
	4: [
		"Não são reais...",
		"Eles... sentem dor?",
		"Porque eu tenho que fazer isso?"
	],
	5: [
		"Eles realmente não são reais!?",
		"Eles podem me machucar também?",
		"Eu preciso fazer isso?"
	],
	6: [
		"Ele é real.",
		"Eu vou sentir dor.",
		"Eu consigo fazer isso...?"
	]
}

@export var tempo_fade_in := 1.0
@export var tempo_visivel := 2.0
@export var tempo_fade_out := 1.0
@export var intervalo_entre_textos := 0.8


func _ready() -> void:
	layer = 2

	texto.visible = true
	texto.self_modulate = Color(1, 1, 1, 0)

	botao_pular.visible = true
	botao_pular.disabled = true
	botao_pular.self_modulate = Color(1, 1, 1, 0)

	# Conecta somente o clique aqui.
	# O mouse_entered e mouse_exited são conectados dentro de configurar_hover().
	botao_pular.pressed.connect(pular_introducao)

	configurar_hover()

	var fase := Gerenciadorfases.fase_selecionada

	if not textos_por_fase.has(fase):
		print("ERRO: não existem textos para a fase ", fase)
		return

	await apresentar_textos(textos_por_fase[fase])

	if introducao_pulada:
		return

	iniciar_fase(fase)


func configurar_hover() -> void:
	escalas_originais[botao_pular] = botao_pular.scale

	# Faz o botão crescer pelo centro.
	botao_pular.pivot_offset = botao_pular.size / 2.0

	botao_pular.mouse_entered.connect(_mouse_entrou)
	botao_pular.mouse_exited.connect(_mouse_saiu)


func _mouse_entrou() -> void:
	if botao_pular.disabled:
		return

	var escala_original: Vector2 = escalas_originais[botao_pular]

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.set_parallel(true)

	tween.tween_property(
		botao_pular,
		"scale",
		escala_original * 1.08,
		0.12
	)

	tween.tween_property(
		botao_pular,
		"self_modulate:a",
		1.0,
		0.12
	)


func _mouse_saiu() -> void:
	if not escalas_originais.has(botao_pular):
		return

	var escala_original: Vector2 = escalas_originais[botao_pular]

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.set_parallel(true)

	tween.tween_property(
		botao_pular,
		"scale",
		escala_original,
		0.12
	)

	tween.tween_property(
		botao_pular,
		"self_modulate:a",
		0.55,
		0.12
	)


func apresentar_textos(lista_textos: Array) -> void:
	for i in range(lista_textos.size()):
		if introducao_pulada:
			return

		var frase: String = lista_textos[i]

		texto.text = frase
		texto.self_modulate = Color(1, 1, 1, 0)

		# O botão aparece junto com o primeiro texto.
		if i == 0:
			botao_pular.disabled = false

			var fade_botao := create_tween()
			fade_botao.set_trans(Tween.TRANS_SINE)
			fade_botao.set_ease(Tween.EASE_IN_OUT)
			fade_botao.tween_property(
				botao_pular,
				"self_modulate:a",
				0.55,
				1.0
			)

		var tempo_fade_atual := tempo_fade_in

		if i == 0:
			tempo_fade_atual += 0.5

		var fade_in := create_tween()
		fade_in.set_trans(Tween.TRANS_SINE)
		fade_in.set_ease(Tween.EASE_IN_OUT)
		fade_in.tween_property(
			texto,
			"self_modulate:a",
			1.0,
			tempo_fade_atual
		)

		await fade_in.finished

		if introducao_pulada:
			return

		await get_tree().create_timer(tempo_visivel).timeout

		if introducao_pulada:
			return

		var fade_out := create_tween()
		fade_out.set_trans(Tween.TRANS_SINE)
		fade_out.set_ease(Tween.EASE_IN_OUT)
		fade_out.tween_property(
			texto,
			"self_modulate:a",
			0.0,
			tempo_fade_out
		)

		await fade_out.finished

		if introducao_pulada:
			return

		await get_tree().create_timer(intervalo_entre_textos).timeout


func pular_introducao() -> void:
	if introducao_pulada:
		return

	introducao_pulada = true

	botao_pular.disabled = true
	texto.visible = false

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		botao_pular,
		"self_modulate:a",
		0.0,
		0.25
	)

	var fase := Gerenciadorfases.fase_selecionada
	iniciar_fase(fase)


func iniciar_fase(fase: int) -> void:
	match fase:
		1:
			get_tree().change_scene_to_file("res://PESADELOS/pesadelo-1.tscn")

		2:
			get_tree().change_scene_to_file("res://PESADELOS/pesadelo-2.tscn")

		3:
			get_tree().change_scene_to_file("res://PESADELOS/pesadelo-3.tscn")

		4:
			get_tree().change_scene_to_file("res://PESADELOS/pesadelo-4.tscn")

		5:
			get_tree().change_scene_to_file("res://PESADELOS/pesadelo-5.tscn")

		6:
			get_tree().change_scene_to_file("res://PESADELOS/pesadelo-6.tscn")
