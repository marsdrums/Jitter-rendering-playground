autowhatch = 1; inlets = 1; outlets = 1;

var finalMesh = [];

function jit_matrix(){
	var mIn = new JitterMatrix(arguments[0]);
	for(var i = 0; i < mIn.dim; i++){
		finalMesh.push(mIn.getcell(i));
	}
}

function bang(){
	var mOut = new JitterMatrix(3, "float32", finalMesh.length);
	for(var i = 0; i < finalMesh.length; i++){
		mOut.setcell(i, "val", finalMesh[i]);
	}
	finalMesh = [];
	outlet(0, "jit_matrix", mOut.name);
}