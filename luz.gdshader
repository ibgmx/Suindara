shader_type canvas_item;

uniform float intensidade = 1.0;
uniform float suavidade = 1.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float distancia = distance(UV, vec2(0.5));

	float alpha = smoothstep(
		0.0,
		0.5 * suavidade,
		distancia
	);

	COLOR = vec4(
		1.0,
		1.0,
		1.0,
		tex.a * alpha * intensidade
	);
}