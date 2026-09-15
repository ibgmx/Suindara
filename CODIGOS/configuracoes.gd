extends Control

@onready var botao_a: Button = $BotaoA
@onready var botao_s: Button = $BotaoS

@onready var tecla_a: Label = $TeclaA
@onready var tecla_s: Label = $TeclaS

@onready var voltar: Button = $Voltar

@onready var efeitos: HSlider = $Efeitos
@onready var musica: HSlider = $Musicas

var aguardando_controle := ""
var controles
var menu_anterior: Node = null

var escalas_originais := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	controles = get_node_or_null("/root/controles")

	if controles == null:
		push_error("ERRO: o Autoload 'controles' não foi encontrado.")
		return

	botao_a.pressed.connect(escolher_tecla_a)
	botao_s.pressed.connect(escolher_tecla_s)
	voltar.pressed.connect(voltar_para_anterior)

	configurar_hover(botao_a)
	configurar_hover(botao_s)
	configurar_hover(voltar)

	efeitos.min_value = 0.0
	efeitos.max_value = 100.0
	efeitos.value = controles.volume_efeitos

	musica.min_value = 0.0
	musica.max_value = 100.0
	musica.value = controles.volume_musica

	efeitos.value_changed.connect(_on_efeitos_changed)
	musica.value_changed.connect(_on_musica_changed)

	atualizar_textos()


func configurar_hover(botao: Button) -> void:
	escalas_originais[botao] = botao.scale

	# Faz o botão crescer pelo centro.
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


func escolher_tecla_a() -> void:
	aguardando_controle = controles.ACAO_ARCO
	tecla_a.text = "PRESSIONE UMA TECLA"


func escolher_tecla_s() -> void:
	aguardando_controle = controles.ACAO_PARAR
	tecla_s.text = "PRESSIONE UMA TECLA"


func _input(event: InputEvent) -> void:
	if aguardando_controle == "":
		return

	if not event is InputEventKey:
		return

	var tecla_evento := event as InputEventKey

	if not tecla_evento.pressed:
		return

	if tecla_evento.echo:
		return

	var nova_tecla: Key = tecla_evento.keycode

	if nova_tecla == KEY_NONE:
		return

	# Esc e F4 são teclas reservadas e não podem ser configuradas.
	if nova_tecla == KEY_ESCAPE or nova_tecla == KEY_F4:
		if aguardando_controle == controles.ACAO_ARCO:
			tecla_a.text = "TECLA NÃO PERMITIDA"
		else:
			tecla_s.text = "TECLA NÃO PERMITIDA"

		get_viewport().set_input_as_handled()
		return

	var conseguiu: bool = controles.tentar_definir(
		aguardando_controle,
		nova_tecla
	)

	if conseguiu:
		aguardando_controle = ""
		atualizar_textos()
	else:
		if aguardando_controle == controles.ACAO_ARCO:
			tecla_a.text = "TECLA JÁ EM USO"
		else:
			tecla_s.text = "TECLA JÁ EM USO"

	get_viewport().set_input_as_handled()


func atualizar_textos() -> void:
	if controles == null:
		return

	tecla_a.text = controles.obter_nome_tecla(
		controles.ACAO_ARCO
	)

	tecla_s.text = controles.obter_nome_tecla(
		controles.ACAO_PARAR
	)


func _on_efeitos_changed(valor: float) -> void:
	controles.volume_efeitos = valor
	controles.aplicar_volume_bus("Efeitos", valor)
	controles.salvar_controles()


func _on_musica_changed(valor: float) -> void:
	controles.volume_musica = valor
	controles.aplicar_volume_bus("Musica", valor)
	controles.salvar_controles()


func voltar_para_anterior() -> void:
	if menu_anterior != null:
		if menu_anterior.has_method("fechar_configuracoes"):
			menu_anterior.fechar_configuracoes()
			return

	get_tree().change_scene_to_file(
		"res://CENAS/inicio.tscn"
	)
