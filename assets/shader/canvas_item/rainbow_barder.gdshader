shader_type canvas_item;

/// Width of the shimmering rainbow border in pixels.
uniform float border_px : hint_range(2.0, 24.0) = 2.0;
/// Animation speed — higher values spin the hue faster.
uniform float speed : hint_range(0.1, 4.0) = 0.9;
/// Brightness multiplier applied to the rainbow colour (creates a glow effect).
uniform float glow_intensity : hint_range(1.0, 3.5) = 2.0;
/// Actual pixel dimensions of the node this material is applied to.
/// Set from GDScript via ShaderMaterial.set_shader_parameter("node_size", size).
uniform vec2 node_size = vec2(64.0, 64.0);

/// Converts an HSV colour to RGB.
vec3 hsv_to_rgb(vec3 c) {
	vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
	return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	// Convert UV to pixel coordinates relative to this node.
	vec2 pixel = UV * node_size;

	// Distance from the nearest edge in pixels.
	float dist_left   = pixel.x;
	float dist_right  = node_size.x - pixel.x;
	float dist_top    = pixel.y;
	float dist_bottom = node_size.y - pixel.y;
	float edge_dist   = min(min(dist_left, dist_right), min(dist_top, dist_bottom));

	if (edge_dist > border_px) {
		// Centre of the banner is fully transparent — only the border band is drawn.
		COLOR = vec4(0.0);
	} else {
		// Animated hue: TIME drives the global spin; position offsets phase so
		// the colour travels around the border rather than flashing uniformly.
		// Guard the divisor against zero so we never produce NaN during the one
		// frame when node_size may not yet have been set from GDScript.
		float denom  = max(node_size.x + node_size.y, 1.0);
		float phase   = (pixel.x + pixel.y) / denom;
		float hue     = fract(TIME * speed * 0.25 + phase);
		vec3  rainbow = hsv_to_rgb(vec3(hue, 1.0, 1.0));

		// Alpha fades from full at the very edge to zero at the inner boundary,
		// giving a soft inner glow rather than a harsh cut.
		float alpha = 1.0 - smoothstep(0.0, border_px, edge_dist);
		alpha = pow(alpha, 0.5);

		COLOR = vec4(rainbow * glow_intensity, alpha * 0.92);
	}
}
