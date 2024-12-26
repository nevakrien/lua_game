extern float t;
extern float seed;
extern float strength;

const float PI = 3.14159265359;


float hash(vec2 p, float t,float seed) {
    // Add temporal variation
    p += t * 0.1; // Adjust the time influence for slower or faster variation

    // // Combine multiple sine frequencies with different weights
    float freq1 = sin(2.0 * p.x) * sin(3.0 * p.y);
    float freq2 = sin(5.0 * p.x + t) * cos(5.0 * p.y - t);
    // float freq3 = cos(6.0 * p.x + 2.0 * t) * sin(7.0 * p.y - 3.0 * t);
    float freq4 = cos(7.0 *seed * p.x) * sin(11.0 *seed * p.y);

    // // Combine the frequencies with different weights
    // float combined = freq1 + 0.5 * freq2 + 0.25 * freq3 + freq4;
    float combined = 0.1*freq1+freq2  + freq4;

    return clamp(combined*combined,0,1);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Calculate distance from the center (0.5, 0.5) in texture coordinates
    vec2 center = vec2(0.5, 0.5);
    float dist = length(texture_coords - center);
    float random = hash(texture_coords,t,seed);
    float random2 = mod(17*random,1);

    // Smooth transparency effect
    float phase = sin(PI*t);
    if (phase <= 0.0) {
        return vec4(0);
    }
    float alpha = smoothstep(0.4 * phase, 0.0, dist); // Sharply fade out beyond a certain radius
    // alpha = mix(alpha,random,0.3);


    // Color gradient: orange (inner) to red (outer)
    vec3 innerColor = vec3(1.0, 1.0, 0.5*strength); // Orange
    vec3 outerColor = vec3(0.8, 0.4, 0.1); // Red
    vec3 explosionColor = mix(innerColor, outerColor, dist / (0.4 * phase));
    
    explosionColor = mix(explosionColor, vec3(1.0,0.5+random*0.3,0.1+0.2*random2*strength), 0.5-0.2*strength);

    // Return the calculated color with transparency
    return vec4(explosionColor, alpha);
}
