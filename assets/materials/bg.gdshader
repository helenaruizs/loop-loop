shader_type canvas_item;

// Background colors
uniform vec4 color_a : source_color = vec4(1, 0.3, 0.7, 1);
uniform vec4 color_b : source_color = vec4(0.3, 1, 0.8, 1);
uniform vec4 color_c : source_color = vec4(0.2, 0.3, 1, 1);

// Swirl controls
uniform float swirl_intensity = 0.08;  // Default is subtle (try 0.02 - 0.12)
uniform float swirl_speed = 0.2;       // Default slow, try 0.1 - 1.0
uniform float swirl_direction = 0.0;   // In radians (0 = right, PI/2 = up)

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 dir_vec = vec2(cos(swirl_direction), sin(swirl_direction));

    // Swirl amount modulated by distance from center and time
    float swirl = swirl_intensity;
    float time = TIME * swirl_speed;
    float swirl_val = swirl * sin(dot(UV - center, dir_vec) * 8.0 + time);

    // Polar swirl
    float angle = atan(UV.y - center.y, UV.x - center.x) + swirl_val * length(UV - center);
    float len = length(UV - center);
    vec2 swirl_uv = center + len * vec2(cos(angle), sin(angle));

    // Animated background color
    float t = time * 0.5;
    float mask_a = smoothstep(0.3, 0.7, sin(t + swirl_uv.x * 4.0 + swirl_uv.y * 3.0));
    float mask_b = smoothstep(0.3, 0.7, sin(t * 1.2 - swirl_uv.y * 5.0));
    float mask_c = 1.0 - mask_a - mask_b;
    vec4 base_color = color_a * mask_a + color_b * mask_b + color_c * mask_c;

    COLOR = base_color;
}
