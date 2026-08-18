shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

// 0: Local (Mesh Attached)
// 1: Global (World Space)
// 2: UV Coordinates
uniform int mapping_mode = 0; 

uniform vec4 line_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float line_thickness : hint_range(0.0, 10.0) = 1.0;
uniform float grid_density = 10.0;
uniform bool draw_back_side = true;

varying vec3 v_local_pos;
varying vec3 v_world_pos;
varying vec3 v_local_normal;
varying vec3 v_world_normal;
varying vec2 v_uv;

void vertex() {
    v_local_pos = VERTEX;
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    v_local_normal = NORMAL;
    v_world_normal = (MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz;
    v_uv = UV;
}

void fragment() {
    if (!FRONT_FACING && !draw_back_side) {
        discard;
    }

    vec3 pos;
    vec3 normal;
    
    if (mapping_mode == 0) {
        pos = v_local_pos * grid_density;
        normal = abs(v_local_normal);
    } else if (mapping_mode == 1) {
        pos = v_world_pos * grid_density;
        normal = abs(v_world_normal);
    } else {
        pos = vec3(v_uv, 0.0) * grid_density;
        normal = vec3(0.0, 0.0, 1.0);
    }
    
    vec3 fw = max(fwidth(pos), vec3(0.0001));
    vec3 grid = abs(fract(pos - 0.5) - 0.5) / fw;
    
    // Prevent "purely shaded" artifact when a face perfectly aligns with a grid plane
    grid += step(0.99, normal) * 1000.0;
    
    float line;
    if (mapping_mode == 2) {
        line = min(grid.x, grid.y);
    } else {
        line = min(grid.x, min(grid.y, grid.z));
    }
    
    float final_line = 0.0;//smoothstep(line_thickness, line_thickness + 1.0, line);

    // ========== 修改核心：只保留网格线，面片区域直接丢弃 ==========
    // final_line = 1.0 → 不在线上的面片部分
    if(final_line > 0.5)
    {
        discard;
    }

    ALBEDO = line_color.rgb;
    ALPHA = line_color.a;
}