extends CanvasLayer


func _on_configuracoes_pressed() -> void:
	navegacao.fase_atual = "res://PESADELOS/pesadelo-1.tscn"
	navegacao.voltar_para_pausa = true

	get_tree().change_scene_to_file("res://CENAS/configuracoes.tscn")
