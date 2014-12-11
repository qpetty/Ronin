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
attribute vec2 texCoord1;

varying lowp vec4 colorVarying;
varying lowp vec2 texCoords0;
varying lowp vec2 texCoords1;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 normalMatrix;
uniform vec4 diffuseColor;

uniform mat3 uRandNum;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * vec4(normal, 1.0)).xyz;
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;
    
    texCoords0 = texCoord0;
    texCoords1 = (uRandNum * vec3(texCoord1, 1.0)).xy;
    
    gl_Position = modelViewProjectionMatrix * position;
}
