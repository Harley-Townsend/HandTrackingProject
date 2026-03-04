shader_type spatial;

render_mode unshaded, cull_disabled, blend_mix;

uniform float fill_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 ring_color : source_color = vec3(0.2, 0.8, 1.0);

void fragment() {
	vec2 uv_centered = UV - vec2(0.5);
	float angle = atan(uv_centered.y, uv_centered.x);
	angle = (angle + PI) / (2.0 * PI);

	float visible = step(angle, fill_amount);

	ALBEDO = ring_color;
	ALPHA = visible;
}