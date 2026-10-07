extends PointLight2D

@export var intensidade_minima: float = 0.7
@export var intensidade_maxima: float = 1.0
@export var reducao_tamanho: float = 0.92
@export var velocidade: float = 1.5

var tempo: float = 0.0
var escala_original: Vector2


func _ready() -> void:
	escala_original = scale


func _process(delta: float) -> void:
	tempo += delta * velocidade

	var valor: float = (sin(tempo) + 1.0) / 2.0

	energy = intensidade_minima + (intensidade_maxima - intensidade_minima) * valor

	var tamanho: float = reducao_tamanho + (1.0 - reducao_tamanho) * valor
	scale = escala_original * tamanho
