shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // Replace white (or near-white) with red
    if (color.r > 0.9 && color.g > 0.9 && color.b > 0.9) {
        color.rgb = vec3(1.0, 0.0, 0.0); // Red color
    }

    COLOR = color;
}
