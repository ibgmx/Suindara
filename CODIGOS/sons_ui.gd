extends Node

@onready var clique: AudioStreamPlayer = $Clique


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().node_added.connect(_quando_no_adicionado)

	await get_tree().process_frame
	_conectar_botoes_existentes()


func _conectar_botoes_existentes() -> void:
	for no in get_tree().get_nodes_in_group("botoes"):
		if no is Button:
			_conectar_botao(no)


func _quando_no_adicionado(no: Node) -> void:
	if no is Button:
		await get_tree().process_frame

		if no.is_in_group("botoes"):
			_conectar_botao(no)


func _conectar_botao(botao: Button) -> void:
	if not botao.pressed.is_connected(tocar_clique):
		botao.pressed.connect(tocar_clique)


func tocar_clique() -> void:
	clique.stop()
	clique.play()
