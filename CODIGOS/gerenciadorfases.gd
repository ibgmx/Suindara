extends Node

var fase_selecionada := 1


func obter_tempo_fase(fase: int) -> int:
	match fase:
		1:
			return 180
		2:
			return 150
		3:
			return 120
		4:
			return 120
		5:
			return 120
		6:
			return 120

	return 180
