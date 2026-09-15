
extends Control

@onready var botao_jogar: Button = $IniciarJogar
@onready var botao_creditos: Button = $Créditos
@onready var botao_configuracoes: Button = $Configurações
@onready var botao_arquivos: Button = $Arquivos

@onready var seta_direita: TextureRect = $SetaDireita

var escalas_originais := {}

var botao_hover_atual: Button = null
var hover_ja_iniciado := false

var tween_seta: Tween = null
var escala_original_seta := Vector2.ONE


func _ready() -> void:
	if not SomMenu.playing:
		SomMenu.play()

	registrar_botao(botao_jogar)
	registrar_botao(botao_creditos)
	registrar_botao(botao_configuracoes)
	registrar_botao(botao_arquivos)

	escala_original_seta = seta_direita.scale
	seta_direita.pivot_offset = seta_direita.size / 2.0

	seta_direita.visible = false


func registrar_botao(botao: Button) -> void:
	escalas_originais[botao] = botao.scale

	# O aumento acontece exatamente pelo centro.
	botao.pivot_offset = botao.size / 2.0

	botao.mouse_entered.connect(_mouse_entrou.bind(botao))
	botao.mouse_exited.connect(_mouse_saiu.bind(botao))


func _mouse_entrou(botao: Button) -> void:
	botao_hover_atual = botao
	hover_ja_iniciado = true

	var escala_original: Vector2 = escalas_originais[botao]

	# =====================================================
	# HOVER DO BOTÃO
	# =====================================================

	var tween_botao := create_tween()

	tween_botao.set_trans(Tween.TRANS_SINE)
	tween_botao.set_ease(Tween.EASE_OUT)

	tween_botao.tween_property(
		botao,
		"scale",
		escala_original * 1.08,
		0.12
	)

	# =====================================================
	# POSIÇÃO DA SETA
	# =====================================================

	if tween_seta != null:
		tween_seta.kill()

	seta_direita.visible = true
	seta_direita.modulate.a = 1.0

	# A seta fica sempre a mesma distância da borda
	# real do botão.
	var retangulo := botao.get_global_rect()

	var distancia := 8.0

	var posicao_seta := Vector2(
		retangulo.end.x + distancia,
		retangulo.position.y
		+ (retangulo.size.y / 2.0)
		- (seta_direita.size.y / 2.0)
	)

	seta_direita.global_position = posicao_seta

	# =====================================================
	# MINI HOVER DA SETA
	# =====================================================

	tween_seta = create_tween()

	tween_seta.set_trans(Tween.TRANS_SINE)
	tween_seta.set_ease(Tween.EASE_OUT)

	tween_seta.tween_property(
		seta_direita,
		"scale",
		escala_original_seta * 1.08,
		0.12
	)


func _mouse_saiu(botao: Button) -> void:
	var escala_original: Vector2 = escalas_originais[botao]

	# =====================================================
	# VOLTA DO BOTÃO
	# =====================================================

	var tween_botao := create_tween()

	tween_botao.set_trans(Tween.TRANS_SINE)
	tween_botao.set_ease(Tween.EASE_OUT)

	tween_botao.tween_property(
		botao,
		"scale",
		escala_original,
		0.12
	)

	await get_tree().process_frame

	if botao_hover_atual == botao:
		botao_hover_atual = null

	# =====================================================
	# VOLTA DA SETA
	# =====================================================

	if tween_seta != null:
		tween_seta.kill()

	tween_seta = create_tween()

	tween_seta.set_trans(Tween.TRANS_SINE)
	tween_seta.set_ease(Tween.EASE_OUT)

	tween_seta.tween_property(
		seta_direita,
		"scale",
		escala_original_seta,
		0.12
	)

	# =====================================================
	# CURSOR FORA DOS BOTÕES
	# =====================================================

	if botao_hover_atual == null:
		iniciar_piscar_seta()


func iniciar_piscar_seta() -> void:
	if not hover_ja_iniciado:
		return

	if tween_seta != null:
		tween_seta.kill()

	seta_direita.visible = true
	seta_direita.modulate.a = 1.0
	seta_direita.scale = escala_original_seta

	tween_seta = create_tween()

	tween_seta.set_loops()
	tween_seta.set_trans(Tween.TRANS_SINE)
	tween_seta.set_ease(Tween.EASE_IN_OUT)

	tween_seta.tween_property(
		seta_direita,
		"modulate:a",
		0.15,
		0.65
	)

	tween_seta.tween_property(
		seta_direita,
		"modulate:a",
		1.0,
		0.65
	)


func _on_iniciar_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://CENAS/fases.tscn")


func _on_créditos_pressed() -> void:
	get_tree().change_scene_to_file("res://CENAS/creditos.tscn")


func _on_configurações_pressed() -> void:
	get_tree().change_scene_to_file("res://CENAS/configuracoes.tscn")


func _on_arquivos_pressed() -> void:
	get_tree().change_scene_to_file("res://CENAS/arquivos.tscn")
