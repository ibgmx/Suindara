shader_type canvas_item;

uniform float progresso : hint_range(0.0, 1.0) = 0.0;
uniform float tamanho_pixel : hint_range(2.0, 100.0) = 16.0;
uniform vec4 cor : source_color = vec4(0.0, 0.0, 0.0, 1.0);


float random(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}


void fragment() {

	vec2 uv = UV;

	// Cria uma grade de grandes "pixels"
	vec2 grade = floor(uv * tamanho_pixel);

	// Valor aleatório para cada pixel
	float aleatorio = random(grade);

	// Cada pixel aparece em um momento diferente
	float mascara = step(aleatorio, progresso);

	COLOR = vec4(cor.rgb, mascara);
}