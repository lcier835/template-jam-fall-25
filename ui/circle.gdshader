shader_type canvas_item;
render_mode unshaded;

uniform vec4 color: source_color;
uniform float inner_radius_squared;

void fragment() {
	vec2 centered_uv = (UV - vec2(0.5))* 2.;
	float len_squared = centered_uv.x * centered_uv.x + centered_uv.y * centered_uv.y;
	if (len_squared > 1. || len_squared < inner_radius_squared) {
		discard;
	}
	COLOR = color;
}
