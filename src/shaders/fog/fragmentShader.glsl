#version 300 es

precision mediump float;

uniform float uIntensity;
uniform vec2 uResolution;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;
    float fog = smoothstep(0.4, 1.0, uv.y);
    outColor = vec4(0.8, 0.8, 0.9, fog * uIntensity);
}