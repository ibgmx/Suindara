shader_type canvas_item;

uniform float progresso : hint_range(0.0, 1.0) = 0.0;


// ==================================================
// ALEATORIEDADE
// ==================================================

float aleatorio(vec2 p) {
	return fract(
		sin(dot(p, vec2(127.1, 311.7))) * 43758.5453
	);
}


// ==================================================
// RUÍDO
// ==================================================

float ruido(vec2 p) {

	vec2 i = floor(p);
	vec2 f = fract(p);

	f = f * f * (3.0 - 2.0 * f);

	float a = aleatorio(i);
	float b = aleatorio(i + vec2(1.0, 0.0));
	float c = aleatorio(i + vec2(0.0, 1.0));
	float d = aleatorio(i + vec2(1.0, 1.0));

	return mix(
		mix(a, b, f.x),
		mix(c, d, f.x),
		f.y
	);
}


// ==================================================
// RUÍDO EM CAMADAS
// ==================================================

float ruido_fractal(vec2 p) {

	float valor = 0.0;
	float amplitude = 0.5;

	for (int i = 0; i < 4; i++) {

		valor += ruido(p) * amplitude;

		p *= 2.0;
		amplitude *= 0.5;
	}

	return valor;
}


void fragment() {

	// ==================================================
	// COORDENADAS
	// ==================================================

	vec2 uv = UV;

	float distancia_borda = min(
		min(uv.x, 1.0 - uv.x),
		min(uv.y, 1.0 - uv.y)
	);


	// ==================================================
	// RUÍDO ORGÂNICO
	// ==================================================

	vec2 escala = uv * vec2(7.0, 5.0);

	float n1 = ruido_fractal(escala);
	float n2 = ruido_fractal(escala * 1.8 + 13.7);

	float ruido_final = mix(
		n1,
		n2,
		0.45
	);


	// ==================================================
	// AVANÇO DA ESCURIDÃO
	// ==================================================

	float alcance = progresso * 0.72;

	float deformacao =
		(ruido_final - 0.5) * 0.42;

	float limite =
		alcance + deformacao;


	// ==================================================
	// MASSA PRINCIPAL
	// ==================================================

	float escuridao = 1.0 - smoothstep(
		limite - 0.025,
		limite + 0.025,
		distancia_borda
	);


	// ==================================================
	// TENTÁCULOS
	// ==================================================

	float tentaculos = 0.0;

	for (int i = 0; i < 9; i++) {

		float fi = float(i);

		float angulo =
			fi * 6.2831853 / 9.0;

		vec2 centro = vec2(0.5);

		vec2 direcao = vec2(
			cos(angulo),
			sin(angulo)
		);

		vec2 p = uv - centro;

		float distancia_direcao = abs(
			dot(
				p,
				vec2(-direcao.y, direcao.x)
			)
		);

		float ruido_tentaculo = ruido_fractal(
			p * 11.0 + fi * 17.3
		);

		float largura =
			0.035 +
			ruido_tentaculo * 0.055;

		float tentaculo = 1.0 - smoothstep(
			largura,
			largura + 0.025,
			distancia_direcao
		);

		float distancia_profundidade =
			dot(p, direcao) + 0.5;

		float alcance_tentaculo =
			progresso * 1.15;

		tentaculo *= 1.0 - smoothstep(
			alcance_tentaculo - 0.15,
			alcance_tentaculo + 0.15,
			distancia_profundidade
		);

		tentaculos = max(
			tentaculos,
			tentaculo
		);
	}


	// ==================================================
	// MISTURA
	// ==================================================

	escuridao = max(
		escuridao,
		tentaculos * progresso
	);


	// ==================================================
	// ACELERAÇÃO FINAL
	// ==================================================

	float final = smoothstep(
		0.72,
		1.0,
		progresso
	);

	escuridao = max(
		escuridao,
		final
	);


	// ==================================================
	// PRETO ABSOLUTO
	// ==================================================

	if (progresso >= 0.995) {
		escuridao = 1.0;
	}


	COLOR = vec4(
		0.0,
		0.0,
		0.0,
		escuridao
	);
}