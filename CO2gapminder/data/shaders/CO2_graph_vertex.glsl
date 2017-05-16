in vec3 uv_vertexAttrib;
uniform vec3 heightOffset;
uniform mat4 uv_modelViewProjectionMatrix;
out vec2 TexCoord;

//Pass though
  
 void main()
 {
   gl_Position = uv_modelViewProjectionMatrix*vec4(uv_vertexAttrib+heightOffset,1.0);
   TexCoord = vec2(-.5*uv_vertexAttrib.x+.5,.5+uv_vertexAttrib.z);

 }
