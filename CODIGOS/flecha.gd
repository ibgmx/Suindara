extends Area2D

@export var velocidade := 600.0

var direcao := Vector2.ZERO
var dono = null
var ricochete_usado := false

var tempo_voo := 0.0
var contando_velocidade := false


func iniciar_velocidade():
	tempo_voo = 0.0
	contando_velocidade = true


func _physics_process(delta):

	if contando_velocidade:
		tempo_voo += delta

	var velocidade_atual := velocidade

	if tempo_voo < 0.0:
		velocidade_atual = velocidade

	elif tempo_voo < 0.5:
		velocidade_atual = velocidade * 0.1

	else:
		velocidade_atual = velocidade

	var distancia: float = velocidade_atual * delta

	var inicio: Vector2 = global_position
	var fim: Vector2 = global_position + direcao * distancia

	var query := PhysicsRayQueryParameters2D.create(
		inicio,
		fim
	)

	query.exclude = [self, dono]

	query.collide_with_bodies = true
	query.collide_with_areas = true

	var resultado := get_world_2d().direct_space_state.intersect_ray(query)

	if resultado:

		var objeto = resultado.collider

		print("FLECHA ACERTOU: ", objeto)
		print("TIPO: ", objeto.get_class())
		print("NOME: ", objeto.name)
		print("CAMINHO: ", objeto.get_path())


		# ==========================================
		# AREA DE DANO DO INIMIGO
		# ==========================================

		if objeto is Area2D and objeto.name == "AreaDano":

			# O AreaDano pertence ao inimigo.
			var inimigo = objeto.get_parent()

			if inimigo != null and inimigo.has_method("morrer"):

				inimigo.morrer()

				queue_free()

				return

			# Se por algum motivo não encontrar o inimigo,
			# a flecha continua normalmente.
			global_position = fim
			return


		# ==========================================
		# CORPO DO INIMIGO
		# ==========================================

		if objeto.has_method("morrer"):

			objeto.morrer()

			queue_free()

			return


		# ==========================================
		# RICOCHETE
		# ==========================================

		if not ricochete_usado:

			ricochete_usado = true

			global_position = (
				resultado.position - direcao * 2.0
			)

			direcao = direcao.bounce(
				resultado.normal
			).normalized()

			rotation = direcao.angle()

		else:

			queue_free()

	else:

		global_position = fim
