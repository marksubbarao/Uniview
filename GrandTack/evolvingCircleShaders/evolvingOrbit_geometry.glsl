layout(triangles) in;
layout(line_strip, max_vertices = 128) out;
uniform mat4 uv_modelViewProjectionMatrix;
uniform mat4 uv_modelViewInverseMatrix;
uniform vec3 incolor = vec3(1);
uniform float uv_fade;
uniform float uv_simulationtimeSeconds;
out vec4 color;
out vec2 texcoord;

void drawOrbit(float radius) //subroutine to draw a circular orbit
{
	float theta=0;
	float dTheta=2.0*3.1415926535/127.;
	float a=1495.9787*radius;
	for (int i=0;i<128;i++) {
		theta=i*dTheta;
		gl_Position=uv_modelViewProjectionMatrix*vec4(a*cos(theta),a*sin(theta),0,1.0);
		EmitVertex();
	}
	EndPrimitive();
}

void main()
{
	float a1 = gl_in[0].gl_Position.x;  
	float a2 = gl_in[0].gl_Position.y; 
	float t= gl_in[0].gl_Position.z;
	float dt= -1.0*gl_in[1].gl_Position.x;
	int colIndex=int(gl_in[1].gl_Position.y);
	float simTime=mod(uv_simulationtimeSeconds,60)/100.;
	if (simTime>t && simTime <(t+dt)) {
	  if(colIndex==5) color=vec4(1.0,0.1,0.1,1.0);
	  if(colIndex==6) color=vec4(1.0,1.0,0.1,1.0);
	  if(colIndex==7) color=vec4(0.1,1.0,0.5,1.0);
	  if(colIndex==8) color=vec4(0.1,0.1,1.0,1.0);
	  float frac = (simTime-t)/dt;
      drawOrbit(a1+frac*(a2-a1));
	}
}
