shader_type canvas_item;

uniform sampler2D noise_texture : source_color; 
uniform int color_choice : hint_range(0, 3, 1) = 0; 

const float FAR = 2.0;

vec3 tex3D(sampler2D tex, in vec3 p, in vec3 n) {
    n = max(abs(n) - 0.2, 0.001);
    n /= (n.x + n.y + n.z);
    
    vec3 tex_sample = texture(tex, p.yz).rgb * n.x + 
                      texture(tex, p.zx).rgb * n.y + 
                      texture(tex, p.xy).rgb * n.z;
    
    return tex_sample * tex_sample;
}

float n3D(vec3 p) {
    const vec3 s = vec3(7.0, 157.0, 113.0);
    vec3 ip = floor(p);
    p -= ip;
    vec4 h = vec4(0.0, s.yz, s.y + s.z) + dot(ip, s);
    p = p * p * (3.0 - 2.0 * p);
    h = mix(fract(sin(h) * 43758.5453), fract(sin(h + s.x) * 43758.5453), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

vec2 hash22(vec2 p) {
    float n = sin(dot(p, vec2(41.0, 289.0)));
    p = fract(vec2(262144.0, 32768.0) * n);
    return sin(p * 6.2831853 + TIME) * 0.45 + 0.5;
}

float Voronoi(in vec2 p) {
    vec2 g = floor(p);
    vec2 o;
    p -= g;
    
    vec3 d = vec3(1.0);
    
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            o = vec2(float(x), float(y));
            o += hash22(g + o) - p;
            d.z = dot(o, o);
            d.y = max(d.x, min(d.y, d.z));
            d.x = min(d.x, d.z);
        }
    }
    
    return max(d.y / 1.2 - d.x * 1.0, 0.0) / 1.2;
}

vec2 heightMap(vec3 p) {
    vec2 result;
    result.y = 0.0;
    float c = Voronoi(p.xy * 4.0);
    
    if (c < 0.07) {
        c = smoothstep(0.7, 1.0, 1.0 - c) * 0.2;
        result.y = 1.0;
    }
    
    result.x = c;
    return result;
}

float map_dist(vec3 p) {
    float h = heightMap(p).x;
    return 1.0 - p.z - h * 0.1;
}

vec3 get_normal(vec3 p, inout float edge) {
    vec2 e = vec2(0.005, 0.0);
    
    float d1 = map_dist(p + e.xyy);
    float d2 = map_dist(p - e.xyy);
    float d3 = map_dist(p + e.yxy);
    float d4 = map_dist(p - e.yxy);
    float d5 = map_dist(p + e.yyx);
    float d6 = map_dist(p - e.yyx);
    float d = map_dist(p) * 2.0;
    
    edge = abs(d1 + d2 - d) + abs(d3 + d4 - d) + abs(d5 + d6 - d);
    edge = smoothstep(0.0, 1.0, sqrt(edge / e.x * 2.0));
    
    return normalize(vec3(d1 - d2, d3 - d4, d5 - d6));
}

vec3 envMap(vec3 rd) {
    vec3 sRd = rd;
    rd.xy -= TIME * 0.25;
    rd *= 3.0;
    
    float c = n3D(rd) * 0.57 + n3D(rd * 2.0) * 0.28 + n3D(rd * 4.0) * 0.15;
    c = smoothstep(0.5, 1.0, c);
    
    vec3 col = vec3(min(c * 1.5, 1.0), pow(c, 2.5), pow(c, 12.0)).zyx;
    return mix(col, col.yzx, sRd * 0.25 + 0.25);
}


void fragment() {
    vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 u = FRAGCOORD.xy;
    vec3 ro = vec3(0.0);
    vec3 rd = normalize(vec3(u - viewport_size * 0.5, viewport_size.y));
    vec3 light_pos = ro + vec3(0.0, 0.0, -1.0);
    vec2 a = sin(vec2(1.570796, 0.0) + TIME / 8.0);
    rd.xy = mat2(a, vec2(-a.y, a.x)) * rd.xy;
    float t = 0.0;
    for(int i = 0; i < 32; i++) {
        float d = map_dist(ro + rd * t);
        if(abs(d) < 0.001 || t > FAR) break;
        t += d * 0.7;
    }
    
    t = min(t, FAR);
    vec3 final_color = vec3(0.0);
    
    if(t < FAR) {
        vec3 p = ro + rd * t;
        float edge = 0.0;
        vec3 n = get_normal(p, edge);
        vec3 light_dir = light_pos - p;
        float light_dist = max(length(light_dir), 0.001);
        light_dir /= light_dist;
        vec2 h_result = heightMap(p);
        float hm = h_result.x;
        int id = int(h_result.y);
        vec3 tx = tex3D(noise_texture, (p * 2.0 + hm * 0.2), n);
        vec3 base_color = vec3(1.0) * (hm * 0.8 + 0.2);
        base_color *= vec3(1.5) * tx;
        float gray = dot(base_color, vec3(0.299, 0.587, 0.114));
        if (id == 0) {
            vec3 color_palette;
            if (color_choice == 0) { 
               color_palette = vec3(min(gray * 1.5, 1.0), pow(gray, 24.0), min(gray * 1.2, 1.0));
            } 
			else if (color_choice == 1) { 
                color_palette = vec3(pow(gray, 5.0), min(gray * 1.5, 1.0), pow(gray, 24.0));
            } 
			else if (color_choice == 2) { 
                color_palette = vec3(pow(gray, 24.0), pow(gray, 5.0), min(gray * 1.5, 1.0));
            } 
			else { 
                 color_palette = vec3(min(gray * 1.5, 1.0), pow(gray, 5.0), pow(gray, 24.0));
            }
            base_color *= color_palette * 2.0;
        } 
		else {
            base_color *= 0.1;
        }
        
        float diffuse = max(dot(light_dir, n), 0.0);
        float specular = pow(max(dot(reflect(-light_dir, n), -rd), 0.0), 32.0);
        
        if (id == 1) specular *= specular;
        
        final_color = base_color * (diffuse + 0.75) + vec3(1.0, 0.97, 0.92) * specular + vec3(0.5, 0.7, 1.0) * pow(specular, 32.0);
        
        vec3 em = envMap(reflect(rd, n));
        if (id == 1) em *= 0.5;
        final_color += em;
        
        final_color *= 1.0 - edge * 0.8;
        final_color *= 1.0 / (1.0 + light_dist * light_dist * 0.125);
    }
    
    COLOR = vec4(sqrt(clamp(final_color, 0.0, 1.0)), 1.0);
}