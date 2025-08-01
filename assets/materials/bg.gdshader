shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(1, 0.3, 0.7, 1);
uniform vec4 color_b : source_color = vec4(0.3, 1, 0.8, 1);
uniform vec4 color_c : source_color = vec4(0.2, 0.3, 1, 1);

uniform float swirl_intensity = 0.08;
uniform float swirl_speed = 0.2;
uniform float swirl_direction = 0.0;

uniform float halftone_scale = 36.0;
uniform float halftone_sharpness = 0.09;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 dir_vec = vec2(cos(swirl_direction), sin(swirl_direction));
    float swirl = swirl_intensity;
    float time = TIME * swirl_speed;
    float swirl_val = swirl * sin(dot(UV - center, dir_vec) * 8.0 + time);

    float angle = atan(UV.y - center.y, UV.x - center.x) + swirl_val * length(UV - center);
    float len = length(UV - center);
    vec2 swirl_uv = center + len * vec2(cos(angle), sin(angle));

    float t = time * 0.5;
    float blend1 = smoothstep(0.3, 0.7, sin(t + swirl_uv.x * 4.0 + swirl_uv.y * 3.0));
    float blend2 = smoothstep(0.3, 0.7, sin(t * 1.2 - swirl_uv.y * 5.0));

    // If in first half, A->B halftone; if in second, B->C halftone
    vec4 final_color;
    if (blend1 > blend2) {
        // A -> B halftone
        float mask = blend1;
        vec2 dot_uv = swirl_uv * halftone_scale;
        dot_uv.x += mod(floor(dot_uv.y), 2.0) * 0.5;
        vec2 grid = fract(dot_uv) - 0.5;
        float dist = length(grid);
        float dot_radius = mask * 0.5;
        float in_dot = 1.0 - smoothstep(dot_radius, dot_radius + halftone_sharpness, dist);
        final_color = mix(color_b, color_a, in_dot);
    } else {
        // B -> C halftone
        float mask = blend2;
        vec2 dot_uv = (swirl_uv + vec2(0.19, 0.13)) * halftone_scale; // offset grid for variety
        dot_uv.x += mod(floor(dot_uv.y), 2.0) * 0.5;
        vec2 grid = fract(dot_uv) - 0.5;
        float dist = length(grid);
        float dot_radius = mask * 0.5;
        float in_dot = 1.0 - smoothstep(dot_radius, dot_radius + halftone_sharpness, dist);
        final_color = mix(color_c, color_b, in_dot);
    }

    COLOR = final_color;
}
