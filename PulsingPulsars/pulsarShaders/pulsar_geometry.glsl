layout(triangles) in;
layout(triangle_strip, max_vertices = 4) out;
uniform mat4 uv_modelViewProjectionMatrix;
uniform mat4 uv_modelViewInverseMatrix;
uniform float uv_fade;
uniform float uv_simulationtimeSeconds;
uniform float pulsarMarkerSize;
out vec4 color;
out vec2 texcoord;

mat3 rotationMatrix(vec3 axis, float angle) // axis should be normalized
{
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

void drawSprite(vec4 position, float radius, float rotation)  // Camera facing square
{  
    vec3 objectSpaceUp = vec3(0, 0, 1);
    vec3 objectSpaceCamera = (uv_modelViewInverseMatrix * vec4(0, 0, 0, 1)).xyz;
    vec3 cameraDirection = normalize(objectSpaceCamera - position.xyz);
    vec3 orthogonalUp = normalize(objectSpaceUp - cameraDirection * dot(cameraDirection, objectSpaceUp));
    vec3 rotatedUp = rotationMatrix(cameraDirection, rotation) * orthogonalUp;
    vec3 side = cross(rotatedUp, cameraDirection);
    texcoord = vec2(0, 1);
	gl_Position = uv_modelViewProjectionMatrix * vec4(position.xyz + radius * (-side + rotatedUp), 1);
	EmitVertex();
    texcoord = vec2(0, 0);
	gl_Position = uv_modelViewProjectionMatrix * vec4(position.xyz + radius * (-side - rotatedUp), 1);
	EmitVertex();
    texcoord = vec2(1, 1);
	gl_Position = uv_modelViewProjectionMatrix * vec4(position.xyz + radius * (side + rotatedUp), 1);
	EmitVertex();
    texcoord = vec2(1, 0);
	gl_Position = uv_modelViewProjectionMatrix * vec4(position.xyz + radius * (side - rotatedUp), 1);
	EmitVertex();
	EndPrimitive();
}

void main()
{
	float Period = gl_in[2].gl_Position[0]; 
	float L = gl_in[2].gl_Position[0];
	float Lmin=0.75;
    float repeatingTime = mod(uv_simulationtimeSeconds, Period) / Period; 
	//If the period is too short, don't attempt to vary the size
	if (Period < 0.1) {
	  color=vec4(0.0,1.0,1.0,1.0);
      drawSprite(0.5*gl_in[0].gl_Position, max(Lmin,L)*pulsarMarkerSize, 0);
	} else {
      color = vec4(1.0,1.0,0.2,1.0);
      float repeatingTime = mod(uv_simulationtimeSeconds, Period) / Period; 
      drawSprite(gl_in[0].gl_Position, sin(3.1415926*repeatingTime)*max(Lmin,L)*pulsarMarkerSize, 0);
	}
}
