//
//  Shader.vsh
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

varying lowp vec3 pos;
varying lowp vec3 norm;
varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 normalMatrix;
uniform vec4 diffuseColor;

void main()
{
    pos = (modelViewMatrix * position).xyz;
    norm = (modelViewMatrix * vec4(normal, 0.0)).xyz;
    
    colorVarying = diffuseColor;
    gl_Position = modelViewProjectionMatrix * position;
}
