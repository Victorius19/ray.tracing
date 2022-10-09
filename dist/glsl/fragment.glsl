#version 300 es

precision highp float;

out vec4 outColor;

uniform vec2 u_resolution;

uvec4 R_STATE;
vec2 u_seed1 = vec2(0.343, 0.943);
vec2 u_seed2 = vec2(0.123, 0.232);
const float MAX_DIST = 99999.0;

uint TausStep(uint z, int S1, int S2, int S3, uint M) {
	uint b = (((z << S1) ^ z) >> S2);
	return (((z & M) << S3) ^ b);	
}

uint LCGStep(uint z, uint A, uint C) {
	return (A * z + C);	
}

vec2 hash22(vec2 p) {
	p += u_seed1.x;
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
	p3 += dot(p3, p3.yzx+33.33);

	return fract((p3.xx+p3.yz)*p3.zy);
}

float random() {
	R_STATE.x = TausStep(R_STATE.x, 13, 19, 12, uint(4294967294));
	R_STATE.y = TausStep(R_STATE.y, 2, 25, 4, uint(4294967288));
	R_STATE.z = TausStep(R_STATE.z, 3, 11, 17, uint(4294967280));
	R_STATE.w = LCGStep(R_STATE.w, uint(1664525), uint(1013904223));

	return 2.3283064365387e-10 * float((R_STATE.x ^ R_STATE.y ^ R_STATE.z ^ R_STATE.w));
}

vec3 randomOnSphere() {
	vec3 rand = vec3(random(), random(), random());

	float theta = rand.x * 2.0 * 3.14159265;
	float v = rand.y;
	float phi = acos(2.0 * v - 1.0);
	float r = pow(rand.z, 1.0 / 3.0);
	float x = r * sin(phi) * cos(theta);
	float y = r * sin(phi) * sin(theta);
	float z = r * cos(phi);

	return vec3(x, y, z);
}
 
vec2 sphIntersect(in vec3 ro, in vec3 rd, float ra) {
    float b = dot(ro, rd);
    float c = dot(ro, ro) - ra * ra;
    float h = b * b - c;

    if(h < 0.0) return vec2(-1.0);
    h = sqrt(h);
    return vec2(-b - h, -b + h);
}

vec2 boxIntersection(in vec3 ro, in vec3 rd, in vec3 rad, out vec3 oN)  {
	vec3 m = 1.0 / rd;
	vec3 n = m * ro;
	vec3 k = abs(m) * rad;
	vec3 t1 = -n - k;
	vec3 t2 = -n + k;
	float tN = max(max(t1.x, t1.y), t1.z);
	float tF = min(min(t2.x, t2.y), t2.z);
	if(tN > tF || tF < 0.0) return vec2(-1.0);
	oN = -sign(rd) * step(t1.yzx, t1.xyz) * step(t1.zxy, t1.xyz);
	return vec2(tN, tF);
}

float plaIntersect(in vec3 ro, in vec3 rd, in vec4 p) {
	return -(dot(ro, p.xyz) + p.w) / dot(rd, p.xyz);
}

vec4 castRay(inout vec3 ro, inout vec3 rd) {
    vec4 color;
    vec2 object;
    vec2 nearestObject = vec2(MAX_DIST);
    vec3 norm;

    // Обход всех сфер
    mat2x4 sph[3];
    // Три координаты + размер сферы
    sph[0][0] = vec4(0.0, 0.0, -1.0, 1.5);
    // Цвет сферы + кф отражения
    sph[0][1] = vec4(0.2, 0.4, 1.0, 0.0);

    sph[1][0] = vec4(1.0, 3.1, -1.0, 0.5);
    sph[1][1] = vec4(1.0, 0.35, 1.0, -1.0);

    sph[2][0] = vec4(2.0, 3.0, 1.0, 0.9);
    sph[2][1] = vec4(0.7, 0.4, 0.8, 0.5);

    for (int i = 0; i < sph.length(); i++) {
        object = sphIntersect(ro - sph[i][0].xyz, rd, sph[i][0].w);

        if (object.x > 0.0 && object.x < nearestObject.x) {
            nearestObject = object;

            norm = normalize(ro + rd * object.x - sph[i][0].xyz);
            color = sph[i][1];
        }
    }

    mat2x4 box[6];
    float boxDist = 10.0;
    float boxSize = boxDist / 2.0;
    float boxReflect = 0.0;
    // Три координаты + размер
    box[0][0] = vec4(0.0, 0.0, boxDist, boxSize);
    // Цвет сферы + кф отражения
    box[0][1] = vec4(1.0, 1.0, 1.0, boxReflect);

    box[1][0] = vec4(0.0, 0.0, -boxDist, boxSize);
    box[1][1] = vec4(1.0, 1.0, 1.0, boxReflect);

    box[2][0] = vec4(0.0, boxDist, 0.0, boxSize);
    box[2][1] = vec4(0.0, 1.0, 0.0, boxReflect);

    box[3][0] = vec4(0.0, -boxDist, 0.0, boxSize);
    box[3][1] = vec4(1.0, 0.0, 0.0, boxReflect);

    box[4][0] = vec4(boxDist, 0.0, 0.0, boxSize);
    box[4][1] = vec4(0.0, 0.0, 1.0, boxReflect);

    // источник света
    box[5][0] = vec4(0.0, 0.0, boxDist - boxDist / 4.0 - 0.01, boxSize / 2.0);
    box[5][1] = vec4(1.0, 1.0, 1.0, -2.0);

    for (int j = 0; j < box.length(); j++) {
        vec3 boxN;
        object = boxIntersection(ro - box[j][0].xyz, rd, vec3(box[j][0].w), boxN);

        if(object.x > 0.0 && object.x < nearestObject.x) {
            nearestObject = object;
            norm = boxN;
            color = box[j][1];
        }
    }
    

    if(nearestObject.x == MAX_DIST) return vec4(0.0, 0.0, 0.0, -2.0);
	if(color.a == -2.0) return color;
	vec3 reflected = reflect(rd, norm);
	if(color.a < 0.0) {
		float fresnel = 1.0 - abs(dot(-rd, norm));
		if(random() - 0.1 < fresnel * fresnel) {
			rd = reflected;
			return color;
		}
		ro += rd * (nearestObject.y + 0.001);
		rd = refract(rd, norm, 1.0 / (1.0 - color.a));
		return color;
	}

    vec3 itPos = ro + rd * object.x;
	vec3 r = randomOnSphere();
	vec3 diffuse = normalize(r * dot(r, norm));
	ro += rd * (nearestObject.x - 0.001);
	rd = mix(diffuse, reflected, color.a);
	return color;
}

vec3 traceRay(vec3 ro, vec3 rd) {
	vec3 col = vec3(1.0);
	for(int i = 0; i < 8; i++)
	{
		vec4 refCol = castRay(ro, rd);
		col *= refCol.rgb;
		if(refCol.a == -2.0) return col;
	}
	return vec3(0.0);
}

void main() {
    vec2 uv = gl_PointCoord.xy * u_resolution / u_resolution.y;

    vec2 uvRes = hash22(uv + 1.0) * u_resolution + u_resolution;
	R_STATE.x = uint(u_seed1.x + uvRes.x);
	R_STATE.y = uint(u_seed1.y + uvRes.x);
	R_STATE.z = uint(u_seed2.x + uvRes.y);
	R_STATE.w = uint(u_seed2.y + uvRes.y);

    vec3 rayOrigin = vec3(-5.0, 0.0, 0.0);
    vec3 rayDirection = normalize(vec3(1.0, uv));
    vec3 col = vec3(0.0);

	int samples = 16;
	for(int i = 0; i < samples; i++) {
		col += traceRay(rayOrigin, rayDirection) / 16.0;
	}

	float white = 20.0;
	col *= white * 16.0;
	col = (col * (1.0 + col / white / white)) / (1.0 + col);

    outColor = vec4(col, 1.0);
}
