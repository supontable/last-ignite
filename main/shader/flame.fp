#include "/main/shader/common.glsl"
#define zoom   0.800

// texture coordinates that are set in the vertex shader
varying mediump vec2 var_texcoord0;

// time uniform that is altered by script
uniform lowp vec4 time;
uniform lowp sampler2D noise;

float fbm(vec2 uv) {
	float n = (texture2D(noise, uv).r - 0.5) * 0.5;
	n += (texture2D(noise, uv * 2.0).r - 0.5) * 0.5 * 0.5;
	n += (texture2D(noise, uv * 3.0).r - 0.5) * 0.5 * 0.5 * 0.5;
	return n + 0.5;
}

void main()
{
	vec2 fragCoord = var_texcoord0.xy;
	vec4 fragColor;
	
	vec2 res = vec2(1.78, 1.0);
	vec2 uv = fragCoord * res.xy;
	uv.x -= 0.5;
	vec2 _uv = uv;
	vec2 centerUV = uv;
	
	float flameSpeed = time.x;

	// height variation from fbm
	float variationH = fbm(vec2(flameSpeed * .3)) * 1.1;

	// flame "speed"
	vec2 offset = vec2(0.0, -flameSpeed * 0.15);

	// flame turbulence
	float f = fbm(uv * 0.1 + offset); // rotation from fbm
	float l = max(0.1, length(uv)); // rotation amount normalized over distance
	uv += rotz( ((f - 0.5) / l) * smoothstep(-0.2, .4, _uv.y) * 0.45) * uv;

	// flame thickness
	float flame = 1.3 - length(uv.x) * 5.0;
	
	// bottom of flame 
	float blueflame = pow(flame * .9, 15.0);
	blueflame *= smoothstep(.2, -1.0, _uv.y);
	blueflame /= abs(uv.x * 2.0);
	blueflame = clamp(blueflame, 0.0, 1.0);

	// flame
	flame *= smoothstep(1., variationH * 0.5, _uv.y);
	flame = clamp(flame, 0.0, 1.0);
	flame = pow(flame, 3.);
	flame /= smoothstep(1.1, -0.1, _uv.y);    

	// colors
	vec4 col = mix(vec4(1.0, 1., 0.0, 0.0), vec4(1.0, 1.0, .6, 0.0), flame);
	col = mix(vec4(1.0, .0, 0.0, 0.0), col, smoothstep(0.0, 1.6, flame));
	fragColor = col;

	// a bit blueness on the bottom
	vec4 bluecolor = mix(vec4(0.0, 0.0, 1.0, 0.0), fragColor, 0.95);
	fragColor = mix(fragColor, bluecolor, blueflame);

	// clear bg outside of the flame
	fragColor *= flame;
	fragColor.a = flame;

	// bg halo
	float haloSize = 0.5;
	float centerL = 1.0 - (length(centerUV + vec2(0.0, 0.1)) / haloSize);
	vec4 halo = vec4(.8, .3, .3, 0.0) * 1.0 * fbm(vec2(time * 0.035)) * centerL + 0.02;
	vec4 finalCol = mix(halo, fragColor, fragColor.a);
	fragColor = finalCol;

	// just a hint of noise
	fragColor *= mix(rand(uv) + rand(uv * .45), 1.0, 0.9);
	fragColor = clamp(fragColor, 0.0, 1.0);

	gl_FragColor = vec4(fragColor);
}