#version 300 es

precision highp float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;

out vec4 outColor;

float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float createRainLayer(vec2 uv, float timeFactor, float textureSize, float opacity) {
    vec2 gridUv = vec2(uv.x, floor((uv.y + timeFactor * uTime) * textureSize + random(uv)) / textureSize);
    float rain = random(gridUv);
    rain = smoothstep(0.9, 1.1, rain) * opacity; 
    return rain;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Create rain layers
    float rainFirstLayer = createRainLayer(uv, 0.6, 6.0, 1.0);
    float rainSecondLayer = createRainLayer(uv, 0.4, 12.0, 0.8);
    float rain = rainFirstLayer + rainSecondLayer;

    // Set color
    vec3 darkColor = vec3(0.11, 0.09, 0.15);
    vec3 lightColor = vec3(0.9, 0.85, 0.95);
    vec3 finalColor = mix(darkColor, lightColor, rain);
    float opacity = mix(0.5, 1.0, rain);
    outColor = vec4(finalColor, opacity);
}