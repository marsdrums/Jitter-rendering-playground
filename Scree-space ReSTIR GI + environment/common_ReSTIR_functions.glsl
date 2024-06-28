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
};

bool visible_env(in sample this_s, in sample test_s, inout uint seed){

	float num_iterations = 10;
	float step = 1 / num_iterations;
	float start = step * (RandomFloat01(seed) + 0.5);
	vec3 end_pos = this_s.pos + test_s.nor*4; 
	float end_depth = length(end_pos);
	vec2 end_uv = pos2uv(end_pos);
	for(float i = start; i < 1; i += step){ //make a better tracing
		vec2 test_uv = mix(this_s.uv, end_uv, vec2(i));
		if(test_uv.x < 0 || test_uv.y < 0 || test_uv.x >= texDim.x || test_uv.y >= texDim.y) return true;
		float expected_depth = mix(this_s.depth*farClip, end_depth, i);
		float sampled_depth = texture(norDepthTex, test_uv).w*farClip;
		if( expected_depth - sampled_depth > 0.01 ) return false;
	}
	return true;
}