#define M_PI 3.141592653589793238462643383279502884

in jit_PerVertex {
	smooth vec2 uv;
	smooth vec3 dir;
} jit_in;

uniform sampler2DRect colTex, norDepthTex, velTex, posTex, reservoirTex, p_hatTex, albTex, environmentMap;
uniform int frame, num_samples;
uniform vec2 texDim, mapSize;
uniform mat4 prevMVP, invV, MV, MVP, VP, V, projmat, textureMatrix0;
uniform float farClip, radius;
uniform vec3 eye;

struct sample{
	vec3 col;
	vec3 nor;
	vec3 pos;
	float depth;
	float index;
	vec2 uv;
	vec2 vel;
	vec3 alb;
	float id;
	vec3 ref;
	vec3 view;
};
