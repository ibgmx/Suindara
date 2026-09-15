extends CanvasLayer

var cena_configuracoes = preload("res://CENAS/configuracoes.tscn")
var tela_configuracoes: Control = null

var escalas_originais := {}


@onready var botao_configuracoes: Button = $Configuraçoes
@onready var botao_continuar: Button = $Continuar
@onready var botao_reiniciar: Button = $Reiniciar
@onready var botao_inicio: Button = $Inicio
@onready var botao_fases: Button = $Fases


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	registrar_hover(botao_configuracoes)
	registrar_hover(botao_continuar)
	registrar_hover(botao_reiniciar)
	registrar_hover(botao_inicio)
	registrar_hover(botao_fases)


func registrar_hover(botao: Button) -> void:
	escalas_originais[botao] = botao.scale

	# Faz o aumento acontecer pelo centro do botão.
	botao.pivot_offset = botao.size / 2.0

	botao.mouse_entered.connect(_mouse_entrou.bind(botao))
	botao.mouse_exited.connect(_mouse_saiu.bind(botao))


func _mouse_entrou(botao: Button) -> void:
	var escala_original: Vector2 = escalas_originais[botao]

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		botao,
		"scale",
		escala_original * 1.08,
		0.12
	)


func _mouse_saiu(botao: Button) -> void:
	var escala_original: Vector2 = escalas_originais[botao]

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		botao,
		"scale",
		escala_original,
		0.12
	)


func continuar() -> void:
	var indara = get_tree().current_scene.get_node_or_null("Suindara/Indara")

	if indara != null and indara.has_method("fechar_pausa"):
		indara.fechar_pausa()
		return

	get_tree().paused = false
	queue_free()


func reiniciar() -> void:
	var indara = get_tree().current_scene.get_node_or_null("Suindara/Indara")

	if indara != null and indara.has_method("reiniciar_fase"):
		queue_free()
		indara.reiniciar_fase()
		return

	get_tree().paused = false
	get_tree().reload_current_scene()


func abrir_configuracoes() -> void:
	if tela_configuracoes != null:
		return

	tela_configuracoes = cena_configuracoes.instantiate()
	tela_configuracoes.process_mode = Node.PROCESS_MODE_ALWAYS

	tela_configuracoes.menu_anterior = self

	add_child(tela_configuracoes)


func fechar_configuracoes() -> void:
	if tela_configuracoes != null:
		tela_configuracoes.queue_free()
		tela_configuracoes = null


func inicio() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://CENAS/inicio.tscn")


func fases() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://CENAS/fases.tscn")


func _on_configuraçoes_pressed() -> void:
	abrir_configuracoes()


func _on_continuar_pressed() -> void:
	continuar()


func _on_reiniciar_pressed() -> void:
	reiniciar()


func _on_inicio_pressed() -> void:
	inicio()


func _on_fases_pressed() -> void:
	fases()
