shader_type canvas_item;

uniform sampler2D mask_texture;
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float border_width : hint_range(0.0, 0.1) = 0.02;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 mask = texture(mask_texture, UV);

	// Sample neighboring pixels to detect edge
	float edge = 0.0;
	vec2 pixel_size = vec2(border_width);

	if (mask.a > 0.5) {
		float left = texture(mask_texture, UV + vec2(-pixel_size.x, 0.0)).a;
		float right = texture(mask_texture, UV + vec2(pixel_size.x, 0.0)).a;
		float up = texture(mask_texture, UV + vec2(0.0, -pixel_size.y)).a;
		float down = texture(mask_texture, UV + vec2(0.0, pixel_size.y)).a;

		if (left < 0.5 || right < 0.5 || up < 0.5 || down < 0.5) {
			edge = 1.0;
		}
	}

	vec3 final_color = mix(color.rgb, border_color.rgb, edge);
	COLOR = vec4(final_color, color.a * mask.a);
}