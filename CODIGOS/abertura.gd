extends Control

@onready var texto: Label = $Texto
@onready var indara: TextureRect = $Indara
@onready var botao_pular: Button = $BotaoPular
@onready var perspectiva: TextureRect = $Perspectiva
@onready var audio: AudioStreamPlayer = $Audio

var abertura_encerrada := false


func _ready() -> void:
	# ==================================================
	# TEXTO
	# ==================================================

	texto.visible = true
	texto.text = ""
	texto.modulate = Color(1, 1, 1, 0)


	# ==================================================
	# LOGO INDARA
	# ==================================================

	indara.visible = true
	indara.modulate = Color(1, 1, 1, 0)


	# ==================================================
	# LOGO PERSPECTIVA
	# ==================================================

	perspectiva.visible = true
	perspectiva.modulate = Color(1, 1, 1, 0)


	# ==================================================
	# BOTÃO PULAR
	# ==================================================

	botao_pular.visible = true

	if not botao_pular.pressed.is_connected(_pular_abertura):
		botao_pular.pressed.connect(_pular_abertura)


	# ==================================================
	# FADE IN DO BOTÃO
	# ==================================================

	var transparencia_original := botao_pular.modulate.a

	botao_pular.modulate.a = 0.0

	var fade_in_botao := create_tween()
	fade_in_botao.set_trans(Tween.TRANS_SINE)
	fade_in_botao.set_ease(Tween.EASE_IN_OUT)
	fade_in_botao.tween_property(
		botao_pular,
		"modulate:a",
		transparencia_original,
		0.8
	)


	# ==================================================
	# FADE OUT DO BOTÃO
	# ==================================================

	await fade_in_botao.finished

	if abertura_encerrada:
		return

	await get_tree().create_timer(1.2).timeout

	if abertura_encerrada:
		return

	var fade_out_botao := create_tween()
	fade_out_botao.set_trans(Tween.TRANS_SINE)
	fade_out_botao.set_ease(Tween.EASE_IN_OUT)
	fade_out_botao.tween_property(
		botao_pular,
		"modulate:a",
		0.0,
		1.0
	)


	# ==================================================
	# ÁUDIO
	# ==================================================

	await get_tree().process_frame

	await get_tree().create_timer(1.0).timeout

	if abertura_encerrada:
		return

	audio.play()

	await apresentar_abertura()


func apresentar_abertura() -> void:
	# =========================
	# INDARA
	# =========================

	if abertura_encerrada:
		return

	indara.visible = true
	indara.modulate = Color(1, 1, 1, 0)

	var fade_in_indara := create_tween()
	fade_in_indara.set_trans(Tween.TRANS_SINE)
	fade_in_indara.set_ease(Tween.EASE_IN_OUT)
	fade_in_indara.tween_property(
		indara,
		"modulate:a",
		1.0,
		2.2
	)

	await fade_in_indara.finished

	if abertura_encerrada:
		return

	await get_tree().create_timer(0.7).timeout

	if abertura_encerrada:
		return

	var fade_out_indara := create_tween()
	fade_out_indara.set_trans(Tween.TRANS_SINE)
	fade_out_indara.set_ease(Tween.EASE_IN_OUT)
	fade_out_indara.tween_property(
		indara,
		"modulate:a",
		0.0,
		1.2
	)

	await fade_out_indara.finished

	if abertura_encerrada:
		return


	# =========================
	# CRÉDITO
	# =========================

	await get_tree().create_timer(0.4).timeout

	if abertura_encerrada:
		return

	texto.text = "Um jogo por:\nBryan Machado"
	texto.modulate = Color(1, 1, 1, 0)

	var fade_in_credito := create_tween()
	fade_in_credito.set_trans(Tween.TRANS_SINE)
	fade_in_credito.set_ease(Tween.EASE_IN_OUT)
	fade_in_credito.tween_property(
		texto,
		"modulate:a",
		1.0,
		1.5
	)

	await fade_in_credito.finished

	if abertura_encerrada:
		return

	await get_tree().create_timer(1.5).timeout

	if abertura_encerrada:
		return

	var fade_out_credito := create_tween()
	fade_out_credito.set_trans(Tween.TRANS_SINE)
	fade_out_credito.set_ease(Tween.EASE_IN_OUT)
	fade_out_credito.tween_property(
		texto,
		"modulate:a",
		0.0,
		1.5
	)

	await fade_out_credito.finished

	if abertura_encerrada:
		return


	# =========================
	# LOGO PERSPECTIVA
	# =========================

	await get_tree().create_timer(0.4).timeout

	if abertura_encerrada:
		return

	perspectiva.modulate = Color(1, 1, 1, 0)

	var fade_in_logo := create_tween()
	fade_in_logo.set_trans(Tween.TRANS_SINE)
	fade_in_logo.set_ease(Tween.EASE_IN_OUT)
	fade_in_logo.tween_property(
		perspectiva,
		"modulate:a",
		1.0,
		1.8
	)

	await fade_in_logo.finished

	if abertura_encerrada:
		return

	await get_tree().create_timer(1.5).timeout

	if abertura_encerrada:
		return

	var fade_out_logo := create_tween()
	fade_out_logo.set_trans(Tween.TRANS_SINE)
	fade_out_logo.set_ease(Tween.EASE_IN_OUT)
	fade_out_logo.tween_property(
		perspectiva,
		"modulate:a",
		0.0,
		1.8
	)

	await fade_out_logo.finished

	if abertura_encerrada:
		return

	_pular_abertura()


func _pular_abertura() -> void:
	if abertura_encerrada:
		return

	abertura_encerrada = true

	audio.stop()

	ir_para_inicio()


func ir_para_inicio() -> void:
	if not is_inside_tree():
		return

	get_tree().set_meta("fazer_fade_menu", true)
	get_tree().change_scene_to_file("res://CENAS/inicio.tscn")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			_pular_abertura()
