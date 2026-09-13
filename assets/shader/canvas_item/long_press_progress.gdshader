shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float ring_width : hint_range(0.001, 0.2) = 0.03;
uniform float radius : hint_range(0.1, 0.9) = 0.4;
uniform vec4 ring_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);
uniform vec4 bg_color : source_color = vec4(0.1, 0.1, 0.1, 0.6);

void fragment() {
	vec2 center = vec2(0.5);
	float dist = distance(UV, center);
	
	// 环的内外边界
	float inner = radius - ring_width * 0.5;
	float outer = radius + ring_width * 0.5;
	
	// 计算角度：从顶部顺时针
	float angle = atan(UV.x - center.x, UV.y - center.y);
	float normalized_angle = mod(angle + 3.14159265, 6.2831853); // 0 ~ TAU
	float progress_angle = progress * 6.2831853;
	
	// 在环带范围内（使用光滑步长做抗锯齿）
	float edge = 0.005;
	float smooth_inner = smoothstep(inner - edge, inner + edge, dist);
	float smooth_outer = 1.0 - smoothstep(outer - edge, outer + edge, dist);
	float ring_mask = smooth_inner * smooth_outer;
	
	// 背景环
	vec4 color = bg_color * ring_mask;
	
	// 进度弧
	float in_progress = step(normalized_angle, progress_angle);
	float fg_mask = ring_mask * in_progress;
	color = mix(color, ring_color, fg_mask);
	
	COLOR = color;
}
