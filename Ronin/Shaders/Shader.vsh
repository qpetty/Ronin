//
//  Shader.vsh
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord0;

varying lowp vec4 colorVarying;
varying lowp vec2 texCoords;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform vec4 diffuseColor;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;
    
    texCoords = texCoord0;
    
    gl_Position = modelViewProjectionMatrix * position;
}
