shader_type canvas_item;

uniform int bar_count = 32;
uniform float hype = 0.0; // Set from script, 0 (no bars) to 1 (max bars)
uniform vec4 bar_color : source_color = vec4(0.8, 0.5, 1.0, 1.0);
uniform vec4 bg_color : source_color = vec4(0.08, 0.04, 0.12, 1.0);

void fragment() {
    vec2 uv = UV;
    float center_y = 0.5;

    // Determine which bar this is (0 to bar_count-1)
    float bar = floor(uv.x * float(bar_count));
    float bar_center = (bar + 0.5) / float(bar_count);

    // Pseudo-random "energy" per bar, animated
    float t = TIME * 0.8 + bar * 0.3;
    float bar_energy = (sin(t * 1.7 + bar * 2.3) * 0.5 + 0.5); // 0..1
    // Or use a hash for more randomness:
    // float bar_energy = fract(sin(bar * 91.9 + TIME * 2.0) * 43758.5453);

    // Multiply by overall hype
    float bar_height = hype * (0.18 + bar_energy * 0.82); // 0.18 min height for visual interest

    // Mirrored: top and bottom from center_y
    float dist_from_center = abs(uv.y - center_y);
    float is_bar = step(dist_from_center, bar_height * 0.5); // half because it's mirrored

    // Soft edge (fade out)
    float edge = 0.012;
    float fade = smoothstep(bar_height * 0.5, bar_height * 0.5 - edge, dist_from_center);

    // Only draw bars at bar locations, fade between bars
    float bar_mask = smoothstep(0.47, 0.5, 1.0 - abs(uv.x - bar_center) * float(bar_count)); // widen bars

    vec4 color = mix(bg_color, bar_color, fade * bar_mask);

    COLOR = color;
}
