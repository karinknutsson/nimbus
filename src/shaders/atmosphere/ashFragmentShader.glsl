#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform sampler2D uTexture;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    float smoke = texture(uTexture, uv).r;

    float opacity = distance(uv, vec2(0.5));
    outColor = vec4(0.0, 0.0, 0.0, smoke);
}