extends Control

@onready var nome = $Nome
@onready var idade = $Idade
@onready var funcao = $Funcao
@onready var descricao = $Descricao

func _ready():

	var id = controles.arquivo_selecionado

	if not controles.arquivo_desbloqueado(id):

		nome.text = "???"
		idade.text = "???"
		funcao.text = "???"
		descricao.text = "ARQUIVO BLOQUEADO"

		return


	match id:

		1:
			nome.text = "Cleiton"
			idade.text = "42"
			funcao.text = "Médico"
			descricao.text = "Descrição do arquivo 1"

		2:
			nome.text = "Amanda"
			idade.text = "21"
			funcao.text = "Cantora"
			descricao.text = "Descrição do arquivo 2"

		3:
			nome.text = "Pedro"
			idade.text = "32"
			funcao.text = "Mecânico"
			descricao.text = "Descrição do arquivo 3"

		4:
			nome.text = "Rebeca"
			idade.text = "26"
			funcao.text = "Pesquisador"
			descricao.text = "Descrição do arquivo 4"

		5:
			nome.text = "Jorge"
			idade.text = "40"
			funcao.text = "Trouxa"
			descricao.text = "Descrição do arquivo 5"

		6:
			nome.text = "Suindara"
			idade.text = "29"
			funcao.text = "Guardiã"
			descricao.text = "Descrição do arquivo 6"


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://CENAS/arquivos.tscn")
