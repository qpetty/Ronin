//
//  Shader.vsh
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

attribute vec4 position;
attribute vec2 texCoord0;

varying lowp vec2 texCoords0;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    texCoords0 = texCoord0;
    
    gl_Position = modelViewProjectionMatrix * position;
}
