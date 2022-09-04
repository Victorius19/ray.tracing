#version 300 es

precision lowp float;

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

    vec3 itPos = ro + rd * it.x;
    vec3 n = itPos;
    vec3 light = normalize(vec3(-0.5, 0.75, 1.0));
    float diffuse = dot(light, n);

    vec3 col = vec3(1.0, 0.2, 0.1);

    return vec3(diffuse) * col;
}

void main() {
    vec2 uv = gl_PointCoord.xy * u_resolution / u_resolution.y;
    vec3 rayOrigin = vec3(-3.0, 0.0, 0.0);
    vec3 rayDirection = normalize(vec3(1., uv));
    vec3 col = castRay(rayOrigin, rayDirection);
    outColor = vec4(col, 1.0);
}
