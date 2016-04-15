#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform float playerX;

void main () {
	
	vec2 xy = gl_FragCoord.xy;

	if (mod(xy.x + playerX / 5., 20.) < 1. || mod(xy.y - floor(time * 100.), 20.) < 1.) {
		float d = distance(xy, vec2(playerX, 600.));
		gl_FragColor.r = .6 - d / 600.;
		gl_FragColor.g = sin(xy.x + xy.y) / 3.;
		gl_FragColor.b = .25 + sin(time / 5.) / 6.;
	}

}

