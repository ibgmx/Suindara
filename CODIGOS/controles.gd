extends Node

signal controles_alterados

const ACAO_ARCO := "acao_arco"
const ACAO_PARAR := "acao_parar"
const CAMINHO_CONFIG := "user://controles.cfg"

const TECLA_ARCO_PADRAO := KEY_A
const TECLA_PARAR_PADRAO := KEY_S

var tecla_arco: Key = TECLA_ARCO_PADRAO
var tecla_parar: Key = TECLA_PARAR_PADRAO

var volume_musica: float = 100.0
var volume_efeitos: float = 100.0

var arquivo_selecionado: int = 1

var arquivos_desbloqueados: Array[bool] = [
	false,
	false,
	false,
	false,
	false,
	false
]

var fases_desbloqueadas: Array[bool] = [
	true,
	false,
	false,
	false,
	false,
	false
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	garantir_acoes()
	carregar_controles()

	aplicar_volume_bus("Musica", volume_musica)
	aplicar_volume_bus("Efeitos", volume_efeitos)


func garantir_acoes() -> void:
	if not InputMap.has_action(ACAO_ARCO):
		InputMap.add_action(ACAO_ARCO)

	if not InputMap.has_action(ACAO_PARAR):
		InputMap.add_action(ACAO_PARAR)

	atualizar_inputmap()


func atualizar_inputmap() -> void:
	InputMap.action_erase_events(ACAO_ARCO)
	InputMap.action_erase_events(ACAO_PARAR)

	var evento_arco := InputEventKey.new()
	evento_arco.keycode = tecla_arco
	InputMap.action_add_event(ACAO_ARCO, evento_arco)

	var evento_parar := InputEventKey.new()
	evento_parar.keycode = tecla_parar
	InputMap.action_add_event(ACAO_PARAR, evento_parar)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var tecla_evento := event as InputEventKey

	if not tecla_evento.pressed:
		return

	if tecla_evento.echo:
		return

	if tecla_evento.keycode != KEY_F4:
		return

	var cena_atual := get_tree().current_scene

	if cena_atual != null:
		var nome_cena := cena_atual.name.to_lower()

		if nome_cena.begins_with("pesadelo"):
			var indara = cena_atual.get_node_or_null("Suindara/Indara")

			if indara != null:
				if indara.has_method("abrir_pausa"):
					indara.abrir_pausa()
				elif indara.has_method("pausar"):
					indara.pausar()

	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_MINIMIZED
	)

	get_viewport().set_input_as_handled()


func tentar_definir(acao: String, nova_tecla: Key) -> bool:
	if nova_tecla == KEY_NONE:
		return false

	# Esc e F4 são teclas reservadas.
	if nova_tecla == KEY_ESCAPE or nova_tecla == KEY_F4:
		return false

	if acao == ACAO_ARCO:
		if nova_tecla == tecla_parar:
			return false

		tecla_arco = nova_tecla

	elif acao == ACAO_PARAR:
		if nova_tecla == tecla_arco:
			return false

		tecla_parar = nova_tecla

	else:
		return false

	atualizar_inputmap()
	salvar_controles()
	controles_alterados.emit()

	return true


func obter_nome_tecla(acao: String) -> String:
	var tecla: Key

	if acao == ACAO_ARCO:
		tecla = tecla_arco

	elif acao == ACAO_PARAR:
		tecla = tecla_parar

	else:
		return ""

	return OS.get_keycode_string(tecla)


func aplicar_volume_bus(nome_bus: String, volume: float) -> void:
	var indice := AudioServer.get_bus_index(nome_bus)

	if indice == -1:
		return

	if volume <= 0.0:
		AudioServer.set_bus_mute(indice, true)
		AudioServer.set_bus_volume_db(indice, -80.0)
	else:
		AudioServer.set_bus_mute(indice, false)
		AudioServer.set_bus_volume_db(
			indice,
			linear_to_db(volume / 100.0)
		)


func salvar_controles() -> void:
	var config := ConfigFile.new()

	config.set_value(
		"controles",
		"tecla_arco",
		tecla_arco
	)

	config.set_value(
		"controles",
		"tecla_parar",
		tecla_parar
	)

	config.set_value(
		"audio",
		"volume_musica",
		volume_musica
	)

	config.set_value(
		"audio",
		"volume_efeitos",
		volume_efeitos
	)

	config.set_value(
		"arquivo",
		"arquivo_selecionado",
		arquivo_selecionado
	)

	config.set_value(
		"desbloqueios",
		"arquivos",
		arquivos_desbloqueados
	)

	config.set_value(
		"desbloqueios",
		"fases",
		fases_desbloqueadas
	)

	config.save(CAMINHO_CONFIG)


func carregar_controles() -> void:
	var config := ConfigFile.new()

	if config.load(CAMINHO_CONFIG) != OK:
		tecla_arco = TECLA_ARCO_PADRAO
		tecla_parar = TECLA_PARAR_PADRAO

		volume_musica = 100.0
		volume_efeitos = 100.0

		arquivo_selecionado = 1

		arquivos_desbloqueados = [
			false,
			false,
			false,
			false,
			false,
			false
		]

		fases_desbloqueadas = [
			true,
			false,
			false,
			false,
			false,
			false
		]

		salvar_controles()
		atualizar_inputmap()

		return

	tecla_arco = config.get_value(
		"controles",
		"tecla_arco",
		TECLA_ARCO_PADRAO
	)

	tecla_parar = config.get_value(
		"controles",
		"tecla_parar",
		TECLA_PARAR_PADRAO
	)

	volume_musica = config.get_value(
		"audio",
		"volume_musica",
		100.0
	)

	volume_efeitos = config.get_value(
		"audio",
		"volume_efeitos",
		100.0
	)

	arquivo_selecionado = config.get_value(
		"arquivo",
		"arquivo_selecionado",
		1
	)

	var arquivos_carregados = config.get_value(
		"desbloqueios",
		"arquivos",
		[
			false,
			false,
			false,
			false,
			false,
			false
		]
	)

	arquivos_desbloqueados = []

	for valor in arquivos_carregados:
		arquivos_desbloqueados.append(
			bool(valor)
		)

	var fases_carregadas = config.get_value(
		"desbloqueios",
		"fases",
		[
			true,
			false,
			false,
			false,
			false,
			false
		]
	)

	fases_desbloqueadas = []

	for valor in fases_carregadas:
		fases_desbloqueadas.append(
			bool(valor)
		)

	atualizar_inputmap()


func selecionar_arquivo(numero: int) -> void:
	if numero < 1 or numero > 6:
		return

	if not arquivo_desbloqueado(numero):
		return

	arquivo_selecionado = numero
	salvar_controles()


func arquivo_desbloqueado(numero: int) -> bool:
	if numero < 1 or numero > arquivos_desbloqueados.size():
		return false

	return arquivos_desbloqueados[numero - 1]


func desbloquear_arquivo(numero: int) -> void:
	if numero < 1 or numero > arquivos_desbloqueados.size():
		return

	arquivos_desbloqueados[numero - 1] = true
	salvar_controles()


func fase_desbloqueada(numero: int) -> bool:
	if numero < 1 or numero > fases_desbloqueadas.size():
		return false

	return fases_desbloqueadas[numero - 1]


func desbloquear_fase(numero: int) -> void:
	if numero < 1 or numero > fases_desbloqueadas.size():
		return

	fases_desbloqueadas[numero - 1] = true
	salvar_controles()
