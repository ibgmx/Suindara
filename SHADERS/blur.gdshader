shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
    vec3 cor = textureLod(screen_texture, SCREEN_UV, 2.5).rgb;

    cor *= 0.65;

    COLOR = vec4(cor, 1.0);
}