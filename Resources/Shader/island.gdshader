shader_type spatial;

uniform vec3 grass_color = vec3(0.137, 0.302, 0.102);
uniform vec3 sand_color = vec3(0.55, 0.45, 0.30);

uniform vec3 center = vec3(0.0, 0.0, 0.0);
uniform float island_radius = 30.0;
uniform float blend_radius = 0.5;
uniform float blend_softness = 0.05;

uniform float wave_amplitude = 0.03;
uniform float wave_frequency = 7.0;  // Higher frequency for more waves

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 pos = vec2(world_pos.x, world_pos.z);
    vec2 center_pos = vec2(center.x, center.z);

    float dist = distance(pos, center_pos);
    float normalized_dist = dist / island_radius;

    float angle = atan(pos.y - center_pos.y, pos.x - center_pos.x);

    // Sum of multiple sine waves with different frequencies and phases
    float wave = 0.0;
    wave += sin(angle * wave_frequency * 1.0 + 0.0) * wave_amplitude * 1.0;
    wave += sin(angle * wave_frequency * 2.3 + 1.5) * wave_amplitude * 0.6;
    wave += sin(angle * wave_frequency * 3.7 + 4.0) * wave_amplitude * 0.4;

    float noisy_blend_start = blend_radius + wave;

    float blend = smoothstep(noisy_blend_start, noisy_blend_start + blend_softness, normalized_dist);

    vec3 color = mix(grass_color, sand_color, blend);
    ALBEDO = color;
}
