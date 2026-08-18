shader_type spatial;
render_mode blend_mix, diffuse_lambert, specular_schlick_ggx;

uniform vec3 grid_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float grid_size = 2.0;          
uniform float line_width = 0.05;        
uniform float base_opacity : hint_range(0.0, 1.0) = 0.1;

uniform vec3 highlight_pos;             
uniform float highlight_radius = 4.0;   
uniform float highlight_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec3 highlight_color : source_color = vec3(1.0, 0.8, 0.0); 

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 grid_uv = fract((world_position.xz / grid_size) + 0.5);
	vec2 grid_line = smoothstep(0.5 - (line_width / grid_size), 0.5, abs(grid_uv - 0.5));
	
	float grid_mask = max(grid_line.x, grid_line.y);

	float dist_to_mouse = distance(world_position.xz, highlight_pos.xz);
	
	float mouse_factor = 1.0 - clamp(dist_to_mouse / highlight_radius, 0.0, 1.0);
	mouse_factor = smoothstep(0.0, 1.0, mouse_factor);

	float final_opacity = base_opacity + (highlight_opacity * mouse_factor);
	
	vec3 final_color = mix(grid_color, highlight_color, mouse_factor);
	
	ALBEDO = final_color;
	ALPHA = grid_mask * final_opacity;
}