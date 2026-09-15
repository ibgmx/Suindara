extends Control

func _on_quadro_1_pressed():
	controles.arquivo_selecionado = 1
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")

func _on_quadro_2_pressed():
	controles.arquivo_selecionado = 2
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")

func _on_quadro_3_pressed():
	controles.arquivo_selecionado = 3
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")

func _on_quadro_4_pressed():
	controles.arquivo_selecionado = 4
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")

func _on_quadro_5_pressed():
	controles.arquivo_selecionado = 5
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")

func _on_quadro_6_pressed():
	controles.arquivo_selecionado = 6
	get_tree().change_scene_to_file("res://CENAS/relatorio.tscn")
