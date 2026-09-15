extends CanvasLayer

@onready var texto: Label = $Fundo/Texto

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

	var fase := Gerenciadorfases.fase_selecionada

	if not textos_por_fase.has(fase):
		print("ERRO: não existem textos para a fase ", fase)
		return

	await apresentar_textos(textos_por_fase[fase])
	iniciar_fase(fase)

func apresentar_textos(lista_textos: Array) -> void:
	for i in range(lista_textos.size()):
		var frase: String = lista_textos[i]

		texto.text = frase
		texto.self_modulate = Color(1, 1, 1, 0)

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

		await get_tree().create_timer(tempo_visivel).timeout

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

		await get_tree().create_timer(intervalo_entre_textos).timeout

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
