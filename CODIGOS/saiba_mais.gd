extends RichTextLabel


func _ready():
	# Impede o RichTextLabel de tentar usar o cursor nativo
	mouse_default_cursor_shape = Control.CURSOR_ARROW

	# Detecta os links
	meta_clicked.connect(_on_meta_clicked)
	meta_hover_started.connect(_on_meta_hover_started)
	meta_hover_ended.connect(_on_meta_hover_ended)


func _on_meta_clicked(meta):
	OS.shell_open(str(meta))


func _on_meta_hover_started(_meta):
	set_meta("mouse_sobre_link", true)


func _on_meta_hover_ended(_meta):
	set_meta("mouse_sobre_link", false)
