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
    rain = smoothstep(0.9, 1.3, rain) * opacity; 
    return rain;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Create rain layers
    float rainFirstLayer = createRainLayer(uv, 0.6, 6.0, 1.0);
    float rainSecondLayer = createRainLayer(uv, 0.4, 12.0, 0.8);
    float rainThirdLayer = createRainLayer(uv, 0.2, 16.0, 0.6);
    float rainFourthLayer = createRainLayer(uv, 0.1, 20.0, 0.4);
    float rain = rainFirstLayer + rainSecondLayer + rainThirdLayer + rainFourthLayer;

    // Set color
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color, rain);
}