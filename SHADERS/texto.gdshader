
shader_type canvas_item;

uniform float velocidade = 0.7;
uniform float largura = 0.18;
uniform float intensidade = 0.8;

void fragment() {
	vec4 cor = texture(TEXTURE, UV) * COLOR;

	float posicao = fract(TIME * velocidade) * 1.6 - 0.3;
	float distancia = abs(UV.x - posicao);

	float brilho = smoothstep(largura, 0.0, distancia);
	brilho *= smoothstep(0.0, 0.2, UV.x);
	brilho *= smoothstep(1.0, 0.8, UV.x);

	cor.rgb += vec3(1.0) * brilho * intensidade * cor.a;

	COLOR = cor;
}
