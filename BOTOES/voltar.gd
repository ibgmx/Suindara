extends Button

func _on_pressed() -> void:
	Estatisticas.reiniciar_contador_tentativas()
		
	get_tree().change_scene_to_file("res://CENAS/inicio.tscn")
