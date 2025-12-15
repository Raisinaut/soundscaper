shader_type spatial;

uniform sampler2D noise_texture;

void vertex() {
	VERTEX = texture(noise_texture, NORMAL.yz).rgb;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
