// Fragment shader for Pulsar Markers. A passed value (markerType) determines the type of marker drawn
uniform float uv_fade;
uniform float markerType;
in vec4 color;
in vec2 texcoord;
out vec4 fragColor;

void main()
{
    fragColor = color;
    fragColor.a *= uv_fade;
    vec2 fromCenter = texcoord * 2 - vec2(1);
	float dist2=dot(fromCenter,fromCenter);
	int pMarker =int(markerType); //because UniView won't let you pass an int *I think*
	switch(pMarker) {
		case 0: //Gaussian Marker
			fragColor.a*=exp(-0.5*dist2/0.1);
			break;
		case 1: //Hard outlined circle with center dot
			if (dist2 >1.0) {
				fragColor.a=0.;
			} else if (dist2<0.75 && dist2 >0.05) {
				fragColor.a*=0.5;
			}
			break;
		case 2: //Ring
			fragColor.a*=(2*sin(3.1415*dot(fromCenter,fromCenter)) -1.0);
			break;
	}
    fragColor.a *= smoothstep(-1.5, -0.5, -length(fwidth(texcoord.xy)));
}
