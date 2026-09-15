shader_type canvas_item;

uniform float progresso : hint_range(0.0, 1.0) = 0.0;


// ==================================================
// RAIO
// ==================================================

float raio(
	vec2 pos,
	float centro,
	float largura,
	float comprimento
) {
	float angulo = atan(pos.y, pos.x);

	float distancia_angular = abs(
		atan(
			sin(angulo - centro),
			cos(angulo - centro)
		)
	);

	float forma = 1.0 - smoothstep(
		largura,
		largura + 0.012,
		distancia_angular
	);

	vec2 direcao = vec2(
		cos(centro),
		sin(centro)
	);

	float frente = dot(pos, direcao);

	// O raio só existe para um lado do centro
	if (frente <= 0.0) {
		return 0.0;
	}

	// Limite do comprimento
	if (frente > comprimento) {
		return 0.0;
	}

	return forma;
}


// ==================================================
// ALEATORIEDADE
// ==================================================

float aleatorio(float n) {
	return fract(
		sin(n * 91.731 + 17.42) *
		43758.5453
	);
}


void fragment() {

	// ==================================================
	// CENTRO
	// ==================================================

	vec2 centro = vec2(0.5);
	vec2 pos = UV - centro;


	// ==================================================
	// TEMPO TOTAL
	// ==================================================

	float tempo = progresso * 5.0;

	float raios = 0.0;


	// ==================================================
	// 4 RAIOS PRINCIPAIS
	// UM POR SEGUNDO
	// ==================================================

	float r1 = raio(
		pos,
		-2.35,
		0.040,
		1.00
	);

	float r2 = raio(
		pos,
		-0.72,
		0.038,
		1.00
	);

	float r3 = raio(
		pos,
		0.48,
		0.042,
		1.00
	);

	float r4 = raio(
		pos,
		2.05,
		0.038,
		1.00
	);


	// ==================================================
	// PRIMEIRO — 1 SEGUNDO
	// ==================================================

	if (tempo >= 1.0) {
		raios = max(raios, r1);
	}


	// ==================================================
	// SEGUNDO — 2 SEGUNDOS
	// ==================================================

	if (tempo >= 2.0) {
		raios = max(raios, r2);
	}


	// ==================================================
	// TERCEIRO — 3 SEGUNDOS
	// ==================================================

	if (tempo >= 3.0) {
		raios = max(raios, r3);
	}


	// ==================================================
	// QUARTO — 4 SEGUNDOS
	// ==================================================

	if (tempo >= 4.0) {
		raios = max(raios, r4);
	}


	// ==================================================
	// EXPLOSÃO
	// 4 → 5 SEGUNDOS
	// ==================================================

	if (tempo >= 4.0) {

		float explosao = clamp(
			tempo - 4.0,
			0.0,
			1.0
		);


		// ==================================================
		// EXPLOSÃO PRINCIPAL
		// MUITOS RAIOS AO MESMO TEMPO
		// ==================================================

		for (int i = 0; i < 220; i++) {

			float n = float(i);

			float aleatorio1 = aleatorio(n + 11.7);
			float aleatorio2 = aleatorio(n + 73.4);
			float aleatorio3 = aleatorio(n + 192.7);
			float aleatorio4 = aleatorio(n + 341.2);

			float angulo =
				aleatorio1 * 6.2831853;

			float largura =
				0.012 +
				aleatorio2 * 0.045;

			// Começa menor e cresce extremamente rápido
			float comprimento =
				0.15 +
				pow(explosao, 0.35) *
				(1.80 + aleatorio3 * 1.50);

			float nascimento =
				aleatorio4 * 0.65;

			float apareceu = step(
				nascimento,
				explosao
			);

			float raio_extra = raio(
				pos,
				angulo,
				largura,
				comprimento
			);

			raios = max(
				raios,
				raio_extra * apareceu
			);
		}


		// ==================================================
		// SEGUNDA RAJADA
		// SURGE MUITO RÁPIDO NO FINAL
		// ==================================================

		if (explosao > 0.35) {

			float rajada = clamp(
				(explosao - 0.35) / 0.65,
				0.0,
				1.0
			);

			for (int i = 0; i < 180; i++) {

				float n = float(i) + 600.0;

				float a1 = aleatorio(n);
				float a2 = aleatorio(n + 42.8);
				float a3 = aleatorio(n + 91.2);

				float angulo =
					a1 * 6.2831853;

				float largura =
					0.018 +
					a2 * 0.065;

				float comprimento =
					0.30 +
					pow(rajada, 0.25) *
					2.50;

				float raio_extra = raio(
					pos,
					angulo,
					largura,
					comprimento
				);

				raios = max(
					raios,
					raio_extra
				);
			}
		}
	}


	// ==================================================
	// PREENCHIMENTO FINAL
	// ==================================================

	float preenchimento = smoothstep(
		0.90,
		1.0,
		progresso
	);

	raios = max(
		raios,
		preenchimento
	);


	// ==================================================
	// BRANCO ABSOLUTO
	// ==================================================

	if (progresso >= 0.995) {
		raios = 1.0;
	}


	COLOR = vec4(
		1.0,
		1.0,
		1.0,
		raios
	);
}