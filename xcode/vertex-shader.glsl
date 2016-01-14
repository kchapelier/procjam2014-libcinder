#version 150

precision highp float;

// Cinder will automatically send the default matrices and attributes to our shader.
uniform mat4 ciModelViewProjection;

in vec4 ciPosition;

out vec4 vPosition;

void main(void)
{
    // Transform the vertex from object space to '2D space'
    // and pass it to the rasterizer.
    gl_Position = ciModelViewProjection * ciPosition;
    
    vPosition = ciPosition;
}
