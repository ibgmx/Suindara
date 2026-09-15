extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var material_shader: ShaderMaterial = color_rect.material

var abrindo := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	color_rect.visible = false
	material_shader.set_shader_parameter("progresso", 0.0)

	# Verifica as trocas de cena.
	get_tree().scene_changed.connect(_quando_cena_mudar)


func _quando_cena_mudar() -> void:
	var cena_atual := get_tree().current_scene

	if cena_atual == null:
		return

	if cena_atual.scene_file_path.begins_with("res://PESADELOS/"):
		if not abrindo:
			abrindo = true
			await abrir()
			abrindo = false


func fechar() -> void:
	color_rect.visible = true
	material_shader.set_shader_parameter("progresso", 0.0)

	var tween := create_tween()

	tween.tween_method(
		func(valor):
			material_shader.set_shader_parameter("progresso", valor),
		0.0,
		1.0,
		0.8
	)

	await tween.finished


func abrir() -> void:
	color_rect.visible = true
	material_shader.set_shader_parameter("progresso", 1.0)

	var tween := create_tween()

	tween.tween_method(
		func(valor):
			material_shader.set_shader_parameter("progresso", valor),
		1.0,
		0.0,
		0.8
	)

	await tween.finished

	color_rect.visible = false
