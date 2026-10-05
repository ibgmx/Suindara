extends Node

var cursor_normal = preload("res://ARTES/cursor/cursor.png")
var cursor_dedo = preload("res://ARTES/cursor/cursor dedinho.png")
var cursor_mira = preload("res://ARTES/cursor/cursor mira.png")

var cursor_atual := ""
var cursor_ativo := false
var cena_anterior := ""


func _ready():
	cursor_normal = aumentar_cursor(cursor_normal, 2.5)
	cursor_dedo = aumentar_cursor(cursor_dedo, 2.5)
	cursor_mira = aumentar_cursor(cursor_mira, 2.5)

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor_ativo = false
	definir_cursor("normal")


func aumentar_cursor(textura: Texture2D, escala: float) -> Texture2D:
	var imagem := textura.get_image()

	imagem.resize(
		int(imagem.get_width() * escala),
		int(imagem.get_height() * escala),
		Image.INTERPOLATE_NEAREST
	)

	return ImageTexture.create_from_image(imagem)


func _process(_delta):
	var cena_atual = get_tree().current_scene

	if cena_atual != null:
		var nome_cena = cena_atual.name

		if nome_cena != cena_anterior:
			cena_anterior = nome_cena

			if nome_cena == "Abertura":
				cursor_ativo = false
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				definir_cursor("normal")

	if cursor_ativo:
		atualizar_cursor()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _input(event):
	if event is InputEventMouseMotion:
		cursor_ativo = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		atualizar_cursor()


func definir_cursor(tipo: String):
	if cursor_atual == tipo:
		return

	cursor_atual = tipo

	match tipo:
		"normal":
			Input.set_custom_mouse_cursor(cursor_normal)

		"dedo":
			Input.set_custom_mouse_cursor(cursor_dedo)

		"mira":
			Input.set_custom_mouse_cursor(cursor_mira)


func atualizar_cursor():

	var viewport = get_viewport()

	# ==================================================
	# BOTÕES DA INTERFACE
	# ==================================================

	var controle = viewport.gui_get_hovered_control()

	if controle != null:

		var controle_atual: Node = controle

		while controle_atual != null:

			if controle_atual is BaseButton:
				definir_cursor("dedo")
				return

			controle_atual = controle_atual.get_parent()


	# ==================================================
	# POSIÇÃO DO MOUSE NO MUNDO
	# ==================================================

	var camera = viewport.get_camera_2d()

	if camera == null:
		definir_cursor("normal")
		return

	var mouse_global = camera.get_global_mouse_position()


	# ==================================================
	# INIMIGO
	# ==================================================

	var cena_atual = get_tree().current_scene

	if cena_atual == null:
		definir_cursor("normal")
		return

	var espaco = cena_atual.get_world_2d().direct_space_state

	var query_inimigo = PhysicsPointQueryParameters2D.new()

	query_inimigo.position = mouse_global
	query_inimigo.collide_with_areas = true
	query_inimigo.collide_with_bodies = true

	var resultados = espaco.intersect_point(query_inimigo)

	for resultado in resultados:

		var objeto = resultado.collider

		if objeto == null:
			continue

		if objeto.is_in_group("inimigo") or objeto.has_method("morrer"):
			definir_cursor("mira")
			return


	# ==================================================
	# A / S PRESSIONADOS
	# ==================================================

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_S):
		definir_cursor("normal")
		return


	# ==================================================
	# INDARA
	# ==================================================

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		definir_cursor("normal")
		return


	# ==================================================
	# SETAS
	# ==================================================

	var seta_disponivel = player.get_node_or_null(
		"pivo_seta_pulo/seta_pulo_disponivel"
	)

	var seta_indisponivel = player.get_node_or_null(
		"pivo_seta_pulo/seta_pulo_indisponivel"
	)


	if seta_disponivel == null:
		seta_disponivel = encontrar_no_por_nome(
			player,
			"seta_pulo_disponivel"
		)


	if seta_indisponivel == null:
		seta_indisponivel = encontrar_no_por_nome(
			player,
			"seta_pulo_indisponivel"
		)


	if seta_disponivel != null and seta_disponivel.visible:
		definir_cursor("dedo")
		return


	if seta_indisponivel != null and seta_indisponivel.visible:
		definir_cursor("normal")
		return


	definir_cursor("normal")


func encontrar_no_por_nome(no: Node, nome: String) -> Node:

	if no.name == nome:
		return no

	for filho in no.get_children():

		var encontrado = encontrar_no_por_nome(
			filho,
			nome
		)

		if encontrado != null:
			return encontrado

	return null
