vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Calculate distance from the center (0.5, 0.5) in texture coordinates
    vec2 center = vec2(0.5, 0.5);
    float dist = length(texture_coords - center);


    // Smooth transparency effect
    // float alpha = 0.5 - dist; // Linearly fade based on distance
    float alpha = smoothstep(0.4, 0.0, dist); // Sharply fade out beyond a certain radius

    // Return orange color with calculated alpha
    return vec4(1.0, 0.8, 0.0, alpha); // Orange with transparency
}
