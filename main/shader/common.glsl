mat2 rotz(float angle)
{
	mat2 m;
	m[0][0] = cos(angle); m[0][1] = -sin(angle);
	m[1][0] = sin(angle); m[1][1] = cos(angle);
	return m;
}

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
