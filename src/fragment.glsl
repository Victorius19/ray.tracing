#version 300 es
 
// fragment shaders don't have a default precision so we need
// to pick one. highp is a good default. It means "high precision"
precision lowp float;
 
// we need to declare an output for the fragment shader
out vec4 outColor;

uniform vec2 u_resolution;
 
vec2 sphIntersect(in vec3 ro, in vec3 rd, float ra) {
    float b = dot(ro, rd);
    float c = dot(ro, ro) - ra * ra;
    float h = b * b - c;

    if(h < 0.0) return vec2(-1.0);
    h = sqrt(h);
    return vec2(-b - h, -b + h);
}

vec3 castRay(vec3 ro, vec3 rd) {
    vec2 it = sphIntersect(ro, rd, 1.0);
    if (it.x < 0.0) return vec3(0.0);
    return vec3(1.0);
}

void main() {
    vec2 uv = gl_PointCoord.xy * u_resolution / u_resolution.y;
    vec3 rayOrigin = vec3(-3.0, 0.0, 0.0);
    vec3 rayDirection = normalize(vec3(1., uv));
    vec3 col = castRay(rayOrigin, rayDirection);
    outColor = vec4(col, 1.0);
}
