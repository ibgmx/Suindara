extends AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().scene_changed.connect(verificar_cena)

	await get_tree().process_frame
	verificar_cena()


func verificar_cena() -> void:
	var cena_atual := get_tree().current_scene

	if cena_atual == null:
		return

	var caminho := cena_atual.scene_file_path

	if caminho.begins_with("res://PESADELOS/"):
		if not playing:
			play()
	else:
		if playing:
			stop()
