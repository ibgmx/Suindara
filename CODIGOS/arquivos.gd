extends Control

var hover_timers := {}
var texturas_normais := {}


func _ready() -> void:
	configurar_quadro($Quadro1)
	configurar_quadro($Quadro2)
	configurar_quadro($Quadro3)
	configurar_quadro($Quadro4)
	configurar_quadro($Quadro5)
	configurar_quadro($Quadro6)


func configurar_quadro(botao: TextureButton) -> void:
	texturas_normais[botao] = botao.texture_normal
	hover_timers[botao] = null

	botao.mouse_entered.connect(_mouse_entrou.bind(botao))
	botao.mouse_exited.connect(_mouse_saiu.bind(botao))


func _mouse_entrou(botao: TextureButton) -> void:
	# Cancela o contador anterior.
	hover_timers[botao] = null

	# Mantém a imagem de hover.
	botao.texture_normal = botao.texture_hover


func _mouse_saiu(botao: TextureButton) -> void:
	# Começa os 2 segundos.
	var timer := get_tree().create_timer(1.0)
	hover_timers[botao] = timer

	await timer.timeout

	# Só volta ao normal se o mouse não tiver voltado
	# para o botão durante os 2 segundos.
	if hover_timers.get(botao) == timer:
		botao.texture_normal = texturas_normais[botao]
		hover_timers[botao] = null


func _on_quadro_1_pressed() -> void:
	controles.arquivo_selecionado = 1
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")


func _on_quadro_2_pressed() -> void:
	controles.arquivo_selecionado = 2
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")


func _on_quadro_3_pressed() -> void:
	controles.arquivo_selecionado = 3
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")


func _on_quadro_4_pressed() -> void:
	controles.arquivo_selecionado = 4
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")


func _on_quadro_5_pressed() -> void:
	controles.arquivo_selecionado = 5
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")


func _on_quadro_6_pressed() -> void:
	controles.arquivo_selecionado = 6
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")
