#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;
uniform sampler2D uTexture0;
uniform sampler2D uTexture1;

out vec4 outColor;

float createRainLayer(float speedFactor, float timeFactor, vec2 uv, float textureSize) {
    vec2 speed = vec2(speedFactor, timeFactor);
    vec2 movingUv = uv * textureSize + speed;
    vec2 stretchedUv = vec2(movingUv.x * 2.0, movingUv.y * 0.03); 
    float rainTexture = texture(uTexture1, stretchedUv).r;
    rainTexture = pow(rainTexture, 11.0);
    return rainTexture;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Create rain layers
    float rainFirstLayer = createRainLayer(- 0.007 * uTime, 0.2 * uTime, uv, 1.6);
    float rainSecondLayer = createRainLayer(- 0.006 * uTime, 0.1 * uTime, uv, 2.0);
    float rainThirdLayer = createRainLayer(- 0.005 * uTime, 0.01 * uTime, uv, 2.4);

    // Cloud texture
    float cloud = texture(uTexture0, uv).r;

    // V curve cloud texture
    float vCloud = abs((cloud - 0.5) * 2.0);
    vCloud = mix(1.0, vCloud, 0.1);

    // Opacity for center view
    float opacity = pow(distance(uv, vec2(0.5)), 2.6)  * 2.6;
    opacity = smoothstep(0.0, 0.5, opacity);
    float combinedOpacity = clamp(opacity + rainFirstLayer + rainSecondLayer + rainThirdLayer, 0.0, 1.0);

    // Set color
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color * vCloud, combinedOpacity);
}