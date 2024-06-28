autowhatch = 1; inlets = 1; outlets = 1;

var mat = new JitterMatrix(4,"float32", 1024, 1024);

var permuted = new Array(mat.dim[0]*mat.dim[1]);
var directions = [	[-1,-1],
					[0,-1],
					[1,-1],
					[-1,0],
					[1,0],
					[-1,1],
					[0,1],
					[1,1]];

function gen_random_offset(){

	return directions[Math.floor(Math.random()*8)];
				
}

function gen_random_center(){

	return [	Math.floor(Math.random()*mat.dim[0]),
				Math.floor(Math.random()*mat.dim[1])];
}

function uv2index(uv){
	return uv[0] + uv[1]*mat.dim[0];
}



function bang(){

	mat.setall(0,0);

	for(var i = 0; i < permuted.length; i++) permuted[i] = false;

	var offset;
	var uv0, uv1;
	var index0, index1

	for(var i = permuted.length*2 - 1; i >= 0; i--){
		offset = gen_random_offset();
		uv0 = gen_random_center();
		index0 = uv2index(uv0);
		if(permuted[index0]) continue;
		uv1 = [uv0[0] + offset[0], uv0[1] + offset[1]];
		if(	uv1[0] < 0 || uv1[1] < 0 || uv1[0] >= mat.dim[0] || uv1[1] >= mat.dim[1] ) continue;		
		index1 = uv2index(uv1);
		if(permuted[index1]) continue;

		mat.setcell(uv0, "val", 0, offset, 0);
		mat.setcell(uv1, "val", 0, -offset[0], -offset[1], 0);
		permuted[index0] = true;
		permuted[index1] = true;

	}

	outlet(0, "jit_matrix", mat.name);

}