shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform bool enabled = true;

uniform float pixel_resolution : hint_range(64.0, 1280.0) = 480.0;
uniform int color_steps : hint_range(2, 64) = 32;

uniform bool enable_noise = true;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.03;

uniform bool enable_dither = true;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.10;

uniform bool enable_glow = true;
uniform float glow_strength : hint_range(0.0, 1.0) = 0.12;
uniform float glow_spread : hint_range(0.001, 0.01) = 0.003;

uniform bool enable_vintage = true;
uniform float vintage_strength : hint_range(0.0, 1.0) = 0.32;

float random(vec2 co) {
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float bayer_dither(vec2 pos) {
	int x = int(mod(pos.x, 4.0));
	int y = int(mod(pos.y, 4.0));
	int index = x + y * 4;

	float bayer[16] = float[](
		0.0, 8.0, 2.0, 10.0,
		12.0, 4.0, 14.0, 6.0,
		3.0, 11.0, 1.0, 9.0,
		15.0, 7.0, 13.0, 5.0
	);

	return bayer[index] / 16.0;
}

vec3 get_glow(vec2 uv) {
	vec3 glow_color = vec3(0.0);
	float total = 0.0;

	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			vec2 offset = vec2(float(x), float(y)) * glow_spread;
			glow_color += texture(screen_texture, uv + offset).rgb;
			total += 1.0;
		}
	}

	return glow_color / total;
}

vec3 apply_vintage_edges(vec3 color, vec2 uv) {
	float dist = distance(uv, vec2(0.5));
	float edge_mask = smoothstep(0.45, 0.9, dist);

	return mix(color, vec3(0.0), edge_mask * vintage_strength);
}

void fragment() {
	vec2 pixel_uv = floor(SCREEN_UV * pixel_resolution) / pixel_resolution;
	vec3 color = texture(screen_texture, pixel_uv).rgb;

	if (enabled) {
		if (enable_glow) {
			vec3 blurred = get_glow(SCREEN_UV);
			color += blurred * glow_strength;
		}

		float steps = float(color_steps);
		color = floor(color * steps + 0.5) / steps;

		if (enable_noise) {
			float noise = (random(SCREEN_UV + vec2(TIME * 0.15, TIME * 0.07)) - 0.5) * noise_strength;
			color += noise;
		}

		if (enable_dither) {
			float threshold = bayer_dither(FRAGCOORD.xy);
			color += dither_strength * (threshold - 0.5);
		}

		if (enable_vintage) {
			color = apply_vintage_edges(color, SCREEN_UV);
		}
	}

	COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}