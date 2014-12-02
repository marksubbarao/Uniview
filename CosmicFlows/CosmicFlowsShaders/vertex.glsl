in vec3 uv_vertexAttrib;
uniform float uv_fade;
  
void main()
{
    gl_Position = vec4(uv_vertexAttrib , 1.0);
}
