layout(triangles) in;
layout(triangle_strip, max_vertices = 4) out;
uniform mat4 uv_viewProjectionMatrix;
uniform mat4 uv_modelViewProjectionMatrix;
uniform mat4 uv_modelMatrix;
uniform mat4 uv_viewMatrix;
uniform mat4 uv_projectionMatrix;
uniform mat4 uv_modelViewMatrix;
uniform float uv_fade;
uniform float markerSize;
uniform float arrowLength;
out vec4 color;
out vec2 texcoord;

void drawLine(vec4 position0, vec4 position1, float width)
{
    vec3 viewPosition0 = (uv_modelMatrix * position0).xyz;
    vec3 viewPosition1 = (uv_modelMatrix * position1).xyz;
    vec3 side = normalize(cross(viewPosition0, viewPosition1 - viewPosition0)) * width;
    vec3 side0 = side * length(viewPosition0);
    vec3 side1 = side * length(viewPosition1);
    gl_Position = uv_projectionMatrix *vec4(viewPosition0 - side,1);
    texcoord = vec2(1, 1);
    EmitVertex();
    gl_Position =  uv_projectionMatrix * vec4(viewPosition0 + side,1);
    texcoord = vec2(0,1);
    EmitVertex();
    gl_Position = uv_projectionMatrix *vec4(viewPosition1, 1);
    texcoord = vec2(1,0);
    EmitVertex();
    gl_Position = uv_projectionMatrix * vec4(viewPosition1, 1);
    texcoord = vec2(0, 0);
    EmitVertex();
    EndPrimitive();
}

void main()
{
	float nGals = gl_in[1].gl_Position[0]; 
	vec3 unitVec = gl_in[0].gl_Position.xyz/length(gl_in[0].gl_Position.xyz);
	float PV = gl_in[2].gl_Position[2];
	color=vec4(1.0,0.0,1.0,1.0);
	if (PV>0) {
	  color = mix(vec4(1.0,1.0,1.0,1.0),vec4(0.0,0.0,1.0,1.0),smoothstep(0,3000,PV));
	} else {
	  color = mix(vec4(1.0,1.0,1.0,1.0),vec4(1.0,0.0,0.0,1.0),smoothstep(0,3000,-1.0*PV));
	}
    drawLine(gl_in[0].gl_Position, gl_in[0].gl_Position+0.0001*arrowLength*PV*vec4(unitVec,1),pow(nGals,0.33)*markerSize/2.);
}
