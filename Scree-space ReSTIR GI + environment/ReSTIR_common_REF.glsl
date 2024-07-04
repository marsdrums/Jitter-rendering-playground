#define metallic 0.0
#define roughness 0.3

vec2 get_sample_uv(in sample this_s, inout uint seed){

  	float maxDistance = 200;//max(texDim.x, texDim.y);
  	float resolution  = 0.1;
  	int   steps       = 10;
  	float thickness   = 0.2;

 	vec4 startView = vec4(this_s.pos.xyz, 1);

 	//bool valid = false;
 	//vec3 pivot;
 	//for(int k = 0; k < 20; k++){
	//	pivot = normalize(this_s.ref + randomUnitVector3(seed)*roughness*roughness);
	//	if( dot(pivot, this_s.nor) > 0 ){
	//		valid = true;
	//		break;
	//	}
 	//}
 //
 	//if(!valid) return vec2(-1);

	vec3 pivot = normalize(this_s.ref + randomUnitVector3(seed)*roughness*roughness);

  	vec4 endView   = vec4(startView.xyz + pivot * maxDistance, 1);

  vec4 positionTo = startView;

  vec4 startFrag      = startView;
       //startFrag      = projmat * startFrag;
       //startFrag.xy   /= startFrag.w;
       //startFrag.xy   = startFrag.xy * 0.5 + 0.5;
       //startFrag.y = 1 - startFrag.y;
       //startFrag.y   *= -1;
       //startFrag.xy = (textureMatrix0 * vec4(startFrag.xy*0.5 + 0.5,1,1)).xy;

       //startFrag.xy  *= texDim;
       startFrag.xy = this_s.uv;
       //startFrag.xy = this_s.uv;

  vec4 endFrag      = endView;
       endFrag      = projmat * endFrag;
       endFrag.xy 	/= endFrag.w;
       //endFrag.y   *= -1;
       //endFrag.xy = (textureMatrix0 * vec4(endFrag.xy*0.5 + 0.5,1,1)).xy;
       endFrag.xy   = endFrag.xy * 0.5 + 0.5;
       //endFrag.y = 1 - endFrag.y;
       endFrag.xy  *= texDim;

  vec2 frag  = startFrag.xy;
   //vec4   uv;
   //uv.xy = frag/texDim;

  float deltaX    = endFrag.x - startFrag.x;
  float deltaY    = endFrag.y - startFrag.y;
  float useX      = abs(deltaX) >= abs(deltaY) ? 1.0 : 0.0;
  float delta     = mix(abs(deltaY), abs(deltaX), useX) * clamp(resolution, 0.0, 1.0);
  vec2  increment = vec2(deltaX, deltaY) / max(delta, 0.001);

  float search0 = 0;
  float search1 = 0;

  int hit0 = 0;
  int hit1 = 0;

  float viewDistance = startView.z;
  float depth        = thickness;

  float i = 0;

  for (i = 0; i < int(delta); i+=1) {
    frag      += increment;
    if(frag.x < 0 || frag.y < 0 || frag.x >= texDim.x || frag.y >= texDim.y) return vec2(-1);
    //uv.xy      = frag / texDim;
    positionTo = texture(posTex, frag);

    search1 = mix( (frag.y - startFrag.y) / deltaY, (frag.x - startFrag.x) / deltaX, useX );
    search1 = clamp(search1, 0.0, 1.0);

    viewDistance = (startView.z * endView.z) / mix(endView.z, startView.z, search1);
    depth        = positionTo.z - viewDistance;

    if (depth > 0 && depth < thickness) {
      hit0 = 1;
      break;
    } else {
      search0 = search1;
    }
  }

  search1 = search0 + ((search1 - search0) / 2.0);

  steps *= hit0;

  for (i = 0; i < steps; ++i) {
    frag       = mix(startFrag.xy, endFrag.xy, search1);
    if(frag.x < 0 || frag.y < 0 || frag.x >= texDim.x || frag.y >= texDim.y) return vec2(-1);
    //uv.xy      = frag / texDim;
    positionTo = texture(posTex, frag);

    viewDistance = (startView.z * endView.z) / mix(endView.z, startView.z, search1);
    depth        = positionTo.z - viewDistance;

    if (depth > 0 && depth < thickness) {
      hit1 = 1;
      search1 = search0 + ((search1 - search0) / 2.0);
    } else {
      float temp = search1;
      search1 = search0 + ((search1 - search0) / 2.0);
      search0 = temp;
    }
  }


/*
  float visibility =
      hit1
    * positionTo.w
    * ( 1 - max( dot(-unitPositionFrom, pivot), 0))
    * ( 1 - clamp( depth / thickness, 0, 1))
    * ( 1 - clamp( length(positionTo - positionFrom) / maxDistance, 0, 1))
    * (uv.x < 0 || uv.x > 1 ? 0 : 1)
    * (uv.y < 0 || uv.y > 1 ? 0 : 1);

  visibility = clamp(visibility, 0, 1);

  uv.ba = vec2(visibility);
*/


  return frag;

}

vec2 cartesianToUv(vec3 cartesian) {
    float theta = atan(cartesian.y, cartesian.x)/TWOPI; // azimuthal angle
    float phi = acos(cartesian.z)/M_PI; // polar angle
    return vec2(theta, phi);
}

vec2 get_sample_uv_for_env(inout uint seed, in vec3 ref){

	vec3 rand_dir = normalize(ref + randomUnitVector3(seed)*roughness);
	//rand_dir *= dot(rand_dir, nor) > 0.0 ? 1 : -1;
	vec2 uv = vec2(atan(rand_dir.z, rand_dir.x), asin(rand_dir.y));
    uv *= vec2(-1/(2*M_PI), 1/M_PI); //to invert atan
    uv += 0.5;
    uv *= mapSize;
    return uv;
	//return vec2(RandomFloat01(seed), RandomFloat01(seed))*mapSize;
	//vec3 wNor = (invV * vec4(nor,0)).xyz;
	//vec2 center = cartesianToUv(wNor) + 2;
	//vec2 randOffset = 0.5*(vec2(RandomFloat01(seed)-0.5, RandomFloat01(seed))-0.5);
	//return vec2(RandomFloat01(seed), RandomFloat01(seed))*mapSize;//mod(center + randOffset, vec2(1.0))*mapSize;
}

bool valid_uv(in vec2 uv){
	return uv.x >= 0 && uv.y >= 0 && uv.x < texDim.x && uv.y < texDim.y;
}

int uv2index(in vec2 uv){
	//uv -= 0.5;
	uv = floor(uv);
	return int(uv.x + uv.y*texDim.x);
}

int uv2index_for_env(in vec2 uv){
	uv = floor(uv);
	return -int(uv.x + uv.y*mapSize.x); //negate the index to distinguish it from viewport samples
}

vec2 index2uv(in int i){
	return vec2( mod( float(i), texDim.x ), floor( float(i) / texDim.x ) ) + 0.5;
}

vec2 index2uv_for_env(in int i){
	return vec2( mod( float(-i), mapSize.x ), floor( float(-i) / mapSize.x ) )+0.5;
}

float luminance(vec3 x){
	return dot(x, vec3(0.299, 0.587, 0.114));
}

vec3 uv2dir(in vec2 uv){

	uv /= mapSize;

    // Convert the normalized UV coordinates to the range [-1, 1]
    float u = uv.x * 2.0 - 1.0;
    float v = uv.y * 2.0 - 1.0;

    // Calculate the longitude and latitude angles
    float longitude = u * M_PI;          // Longitude (-π to π)
    float latitude = v * M_PI * 0.5;     // Latitude (-π/2 to π/2)

    // Convert spherical coordinates to Cartesian coordinates
    float x = cos(latitude) * sin(longitude);
    float y = sin(latitude);
    float z = cos(latitude) * cos(longitude);

    vec3 dir = vec3(x, y, z);
    return (V * vec4(dir, 0)).xyz;
}

sample get_sample_pos_col(int index){

	sample s;
	vec2 uv = index2uv(index);
	ivec2 iuv = ivec2(uv);
	vec4 lookup0 = texelFetch(colTex, iuv);
	vec4 lookup3 = texelFetch(posTex, iuv);

	s.col = lookup0.rgb;
	s.pos = lookup3.xyz;
	return s;
}

sample get_sample_pos_col_from_uv(vec2 uv){

	sample s;
	ivec2 iuv = ivec2(uv);
	vec4 lookup0 = texelFetch(colTex, iuv);
	vec4 lookup3 = texelFetch(posTex, iuv);

	s.col = lookup0.rgb;
	s.pos = lookup3.xyz;
	return s;
}

sample get_sample_dir_col_for_env_jittered(int index, inout uint seed){

	sample s;
	s.uv = index2uv_for_env(index);
	ivec2 iuv = ivec2(s.uv);
	vec2 jitter_uv = s.uv;// + 2*vec2(RandomFloat01(seed)-0.5, RandomFloat01(seed)-0.5);
	s.col = texture(environmentMap, jitter_uv).rgb;
	s.nor = uv2dir(jitter_uv);
	s.pos = s.nor; //use the position variable to pass the direction for reprojection
	return s;
}

sample get_sample(int index){

	sample s;
	vec2 uv = index2uv(index);
	ivec2 iuv = ivec2(uv);
	vec4 lookup0 = texelFetch(colTex, iuv);
	vec4 lookup1 = texelFetch(norDepthTex, iuv);
	vec4 lookup2 = texelFetch(velTex, iuv);
	vec4 lookup3 = texelFetch(posTex, iuv);
	vec4 lookup4 = texelFetch(albTex, iuv);
	s.col = lookup0.rgb;
	s.nor = lookup1.xyz;
	s.vel = lookup2.xy;
	s.pos = lookup3.xyz;
	s.depth = lookup1.w;
	s.index = index;
	s.uv = uv;
	s.alb = lookup4.rgb;
	s.id = lookup4.w;
	s.view = normalize(-s.pos);
	s.ref = reflect(s.view, s.nor);
	return s;
}


//PBR functions
float saturate(in float x){ return clamp(x, 0.0, 1.0); }

vec3 	fresnelSchlickRoughness(float HdotV, vec3 F0, float rou){
	float 	x = saturate(1. - HdotV); //x^5
	float 	x2 = x*x;
			x2 *= x2;
			x *= x2;
    return F0 + (max(vec3(1.0 - rou), F0) - F0) * x;
} 
float 	DistributionGGX(float NdotH, float rou){
			rou *= rou; //Disney trick!
			rou *= rou; //roughness^4
     		NdotH *= NdotH; //square the dot product
    float 	denom = (NdotH * (rou - 1.0) + 1.0);
    		denom *= denom;
    		denom *= M_PI;
	
    return 	rou / denom;
}
float 	GeometrySchlickGGX(float NdotV, float rou){
			rou += 1.;
    float 	k = (rou*rou) / 8.0; //Disney trick again...
    return NdotV / ( NdotV * (1.0 - k) + k );
}
float 	GeometrySmith(float NdotV, float NdotL, float rou){
    float ggx2  = GeometrySchlickGGX(NdotV, rou);
    float ggx1  = GeometrySchlickGGX(NdotL, rou);
	
    return ggx1 * ggx2;
} 

vec3 get_specular_radiance(in sample this_s, in sample test_s){

	const vec3 F0 = vec3(0.01);

	vec3 diff = test_s.pos - this_s.pos;
	//if(dot(diff, this_s.nor) < 0) return vec3(0.0);
    vec3 L = normalize(diff);
	vec3 H = normalize(this_s.view + L);		//half vector

	//compute dot products
	float	HdotV = max(0.0, (dot(H, this_s.view)));
    float 	NdotV = max(0.001, (dot(this_s.nor, this_s.view))); //avoid dividing by 0
    float 	NdotL = max(0.001, (dot(this_s.nor, L)));
    float   NdotH = max(0.0, (dot(this_s.nor, H)));
    float   HdotL = max(0.001, (dot(H, L)));

	vec3 	F  	= fresnelSchlickRoughness(HdotV, F0, roughness); //compute fresnel
	//return test_s.col;// * F;
	float	NDF = DistributionGGX(NdotH, roughness); //compute NDF term
	float 	G   = GeometrySmith(NdotV, NdotL, roughness); //compute G term   
	vec3 	spe = (NDF*G*F)/(4.*NdotV*NdotL);  

	//vec3 	kS = F;					//k specular
	//vec3 	kD = vec3(1.0) - kS;	//k diffuse
	//		kD *= 1.0 - metallic;		//nullify k diffuse if metallic

	//const float inv_pi = 0.3183098862;
	//return 	(kD * this_s.alb * inv_pi + spe) * test_s.col * NdotL;
    //float pdfH = NDF * NdotH / (4.0 * HdotL) + 0.001;
	return spe * test_s.col * NdotL;// / pdfH;
}

float get_pdf(in sample this_s, in sample test_s){

	return 1;
	vec3 diff = test_s.pos - this_s.pos;
	vec3 L = normalize(diff);
	vec3 H = normalize(this_s.view + L);		//half vector

	float	HdotV = saturate(dot(H, this_s.view));
	float   NdotH = saturate(dot(this_s.nor, H));
	float   HdotL = saturate(dot(H, L)) + 0.001;

	const vec3 F0 = vec3(0.8);
	float	NDF = DistributionGGX(NdotH, roughness); //compute NDF term

	return NDF * NdotH / (4.0 * HdotL) + 0.001;
}


vec3 get_radiance(in sample this_s, in sample test_s){

	vec3 diff = test_s.pos - this_s.pos;
	vec3 dir = -normalize(diff);//diff / dist;
	float lambert = max(0.0, dot(this_s.ref, dir));
	lambert = pow(lambert, 300)*300;
	return lambert * test_s.col;
}

vec3 get_radiance_for_env(in sample this_s, in sample test_s){

	float lambert = max(0.0, dot(this_s.ref, test_s.nor));
	lambert = pow(lambert, 100)/100;
	return this_s.alb * lambert * test_s.col;							
}

vec4 updateReservoir(vec4 reservoir, float lightToSample, float weight, float c, inout uint seed)
{
	// Algorithm 2 of ReSTIR paper
	reservoir.x = reservoir.x + weight; // r.w_sum
	reservoir.z = reservoir.z + c; // r.M
	if (RandomFloat01(seed) < weight / reservoir.x) {
		reservoir.y = lightToSample; // r.y
	}

	return reservoir;
}

bool background(in sample this_s){
	return this_s.pos.x == 1.0 && this_s.pos.y == 1.0 && this_s.pos.z == 1.0;
}

bool visible(in sample this_s, in sample test_s, inout uint seed){
	//return true;
	float num_iterations = 6;
	float step = 0.1;//1 / num_iterations;
	float start = step * (1 + RandomFloat01(seed) - 0.5);
	for(float i = start; i < 1; i += step){ //make a better tracing
		vec2 test_uv = mix(this_s.uv, test_s.uv, vec2(i*i));
		float expected_depth = (this_s.depth * test_s.depth) / mix(test_s.depth, this_s.depth, i*i);
		float sampled_depth = texelFetch(norDepthTex, ivec2(test_uv)).w;
		if(sampled_depth < (expected_depth - 0.01) ) return false;
	}
	return true;
}

vec2 pos2uv(in vec3 p){

	vec4 projP = projmat * vec4(p, 1);
	projP.xy = (projP.xy/projP.w) * 0.5 + 0.5;
	return floor( ( textureMatrix0 * vec4(projP.xy,1,1) ).xy ) + 0.5;// * texDim;

}

bool visible_env(in sample this_s, in sample test_s, inout uint seed){

	//return true;

	float num_iterations = 6;
	float step = 0.01;//1 / num_iterations;
	float start = step * (RandomFloat01(seed) + 0.5);
	vec3 end_pos = this_s.pos + test_s.nor*6; 
	float end_depth = length(end_pos);
	vec2 end_uv = pos2uv(end_pos);
	for(float i = start; i < 1; i += step){ //make a better tracing
		vec2 test_uv = mix(this_s.uv, end_uv, vec2(i*i));
		if(test_uv.x < 0 || test_uv.y < 0 || test_uv.x >= texDim.x || test_uv.y >= texDim.y) return true;
		float expected_depth = (this_s.depth*farClip * test_s.depth) / mix(test_s.depth*farClip, this_s.depth, i*i);
		float sampled_depth = texture(norDepthTex, test_uv).w*farClip;
		if( expected_depth - sampled_depth > 0.01 ) return false;
	}
	return true;
}
