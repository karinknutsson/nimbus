#version 300 es

precision mediump float;

uniform float uTime;
uniform vec2 uResolution;
uniform float uWind;

uniform vec2 uAtmosphereColor;
uniform float uCloudFactor;
uniform float uMistFactor;
uniform float uRainFactor;

uniform sampler2D uCloudTexture;
uniform sampler2D uAshTexture;
uniform sampler2D uSmokeTexture;
uniform sampler2D uRainTexture;

out vec4 outColor;

vec2 rotateUv(vec2 uv, float angle, vec2 center) {
    uv -= center;
    float s = sin(angle);
    float c = cos(angle);
    uv = vec2(
        uv.x * c - uv.y * s,
        uv.x * s + uv.y * c
    );
    uv += center;
    return uv;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    vec2 speed = vec2(-0.002, -0.001);
    vec2 movingUv = uv + speed * uTime;

    movingUv = rotateUv(movingUv, uTime * 0.003, vec2(0.5));

    // Cloud texture
    float clouds = texture(uCloudTexture, movingUv).r;

    // Inverted cloud texture: scattered and few clouds
    float invertedClouds = 1.0 - clouds;
    float fewClouds = smoothstep(0.3, 1.0, invertedClouds);

    // Pow inverted cloud: few clouds
    float scatteredClouds = pow(fewClouds, 2.0) * 1.5;

    // V curve cloud texture: overcast and broken clouds
    float vCurveClouds = abs((clouds - 0.5) * 2.0);
    float overcastClouds = mix(1.0, vCurveClouds, 0.1);

    float brokenClouds = mix(1.0, vCurveClouds, 0.4);


    // Opacity for center view
    float opacity = pow(distance(uv, vec2(0.5)), 1.2)  * 1.6;
    opacity = smoothstep(0.0, 0.5, opacity);

    vec3 color = vec3(1.0, 1.0, 1.0);

    outColor = vec4(color * overcastClouds, opacity);
    
}