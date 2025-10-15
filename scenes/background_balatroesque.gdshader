shader_type canvas_item;

uniform highp float flow_speed = 0.8;
uniform highp float turbulence = 1.5;
uniform highp float detail_scale = 3.0;
uniform highp vec4 color_1 : source_color = vec4(0.8, 0.6, 0.85, 1.0); // Pastel purple
uniform highp vec4 color_2 : source_color = vec4(0.6, 0.75, 0.95, 1.0); // Pastel blue
uniform highp vec4 color_3 : source_color = vec4(0.95, 0.7, 0.8, 1.0); // Pastel pink
uniform highp vec4 color_4 : source_color = vec4(0.85, 0.88, 0.92, 1.0); // Light pastel base
uniform highp float glow_intensity = 0.6;
uniform highp float contrast = 2.0;
uniform highp float pixel_filter = 740.;
uniform bool animate = true;

// Hash function for noise
highp float hash(highp vec2 p) {
    highp vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Smooth noise
highp float noise(highp vec2 p) {
    highp vec2 i = floor(p);
    highp vec2 f = fract(p);
    highp vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(hash(i + vec2(0.0, 0.0)),
                   hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)),
                   hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// Fractal Brownian Motion for organic patterns
highp float fbm(highp vec2 p) {
    highp float value = 0.0;
    highp float amplitude = 0.5;
    highp float frequency = 1.0;

    for(int i = 0; i < 6; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

// Curl noise - creates swirling, fluid motion
highp vec2 curl_noise(highp vec2 p) {
    const highp float e = 0.1;
    highp float n1 = fbm(p + vec2(e, 0.0));
    highp float n2 = fbm(p - vec2(e, 0.0));
    highp float n3 = fbm(p + vec2(0.0, e));
    highp float n4 = fbm(p - vec2(0.0, e));

    // Calculate curl (rotation) from gradient
    return vec2(n3 - n4, n2 - n1) / (2.0 * e);
}

vec4 effect(vec2 screenSize, vec2 screen_coords){
    highp float pixel_size = length(screenSize.xy) / pixel_filter;
    highp vec2 uv = (floor(screen_coords.xy*(1./pixel_size))*pixel_size - 0.5*screenSize.xy)/length(screenSize.xy);

    highp float time = 0.0;
    if(animate) {
        time = TIME * flow_speed * 0.1;
    }

    // Scale UV
    uv *= detail_scale;

    // Apply curl noise for swirling motion
    highp vec2 curl = curl_noise(uv + time * 0.5);
    uv += curl * 0.3;

    // Create flowing nebula with domain warping
    highp vec2 q = vec2(fbm(uv + time), fbm(uv + vec2(5.2, 1.3) - time * 0.7));

    // Add more curl influence
    q += curl_noise(uv + time * 0.3) * 0.2;

    highp vec2 r = vec2(
        fbm(uv + turbulence * q + vec2(1.7, 9.2) + time * 0.15),
        fbm(uv + turbulence * q + vec2(8.3, 2.8) - time * 0.2)
    );

    // Final curl layer
    r += curl_noise(uv + r * 0.5) * 0.15;

    highp float pattern = fbm(uv + turbulence * r);

    // Create multiple color zones
    highp float zone1 = smoothstep(0.2, 0.4, pattern);
    highp float zone2 = smoothstep(0.4, 0.6, pattern);
    highp float zone3 = smoothstep(0.6, 0.8, pattern);

    // Mix colors based on zones
    highp vec4 mixed_color = color_4;
    mixed_color = mix(mixed_color, color_1, zone1);
    mixed_color = mix(mixed_color, color_2, zone2 * (1.0 - zone3));
    mixed_color = mix(mixed_color, color_3, zone3);

    // Add glow/energy to bright areas (softer for pastel)
    highp float energy = pow(pattern, contrast) * glow_intensity * 0.3;
    mixed_color.rgb += energy;

    // Add subtle sparkle points (optional)
    highp float sparkle = hash(floor(uv * 30.0 + time * 10.0));
    if(sparkle > 0.995) {
        highp float sparkle_brightness = (sparkle - 0.995) * 200.0;
        mixed_color.rgb += vec3(sparkle_brightness * 0.3 * pattern);
    }

    // Add some wispy clouds
    highp float wisps = fbm(uv * 2.0 + r * 0.5);
    wisps = pow(max(0.0, wisps - 0.5), 2.0);
    mixed_color.rgb += wisps * 0.3;

    return mixed_color;
}

void fragment() {
    vec2 uv = UV;
    COLOR *= effect(TEXTURE_PIXEL_SIZE, uv);
}