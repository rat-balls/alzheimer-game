shader_type canvas_item;

uniform float blink_amount : hint_range(0.0, 1.0) = 0.0;
uniform float softness : hint_range(0.001, 0.2) = 0.04;

void fragment() {
	float top_limit = blink_amount * 0.5;
	float bottom_limit = 1.0 - blink_amount * 0.5;

	float top_mask = 1.0 - smoothstep(top_limit, top_limit + softness, UV.y);
	float bottom_mask = smoothstep(bottom_limit - softness, bottom_limit, UV.y);

	float mask = max(top_mask, bottom_mask);

	COLOR = vec4(0.0, 0.0, 0.0, mask);
}