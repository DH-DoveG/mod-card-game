shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_opaque;

uniform float progress = 0.0;
uniform float noiseForce = 0.2;
uniform sampler2D noiseTexture;
uniform vec4 burnColor: source_color;
uniform float borderWidth : hint_range(0.0,1.0) = 0.1;
uniform float direction = 180.0;

vec2 degreesToPerpendicular(){
	return vec2(cos(radians(direction)), -sin(radians(direction)));
}

void fragment() {
	vec2 dirVec = degreesToPerpendicular();
	// 使用VERTEX.xy物体局部坐标，而不是UV，不受UV展图影响
	vec2 normPos = VERTEX.xy;
	float noiseVal = texture(noiseTexture, UV).r * noiseForce;
	
	float threshold_val = dot(normPos, dirVec) + noiseVal;

	float burnEdge = float(threshold_val < (progress + borderWidth));
	ALBEDO.rgb = mix(ALBEDO.rgb, burnColor.rgb, burnEdge * burnColor.a);

	if (!(threshold_val > progress)) {
		ALPHA = 0.0;
	} else {
		ALPHA = ALBEDO.x;
	}
}