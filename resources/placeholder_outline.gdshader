shader_type spatial;

uniform float outline_thickness : hint_range(0.0, 1) = 0.05;

void fragment() {
    vec3 view_normal = normalize((INV_PROJECTION_MATRIX * vec4(NORMAL, 0.0)).xyz);
    vec3 outline = vec3(0.0);
    if (dot(view_normal, NORMAL) < 0.0) {
        outline = vec3(0.0, 0.0, 0.0); // Black outline
    }
    ALBEDO = mix(outline, vec3(1.0), 1.0 - outline_thickness);
    ALPHA = 0.5; // Set transparency for the white mesh
}