//
//  Shader.fsh
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

uniform sampler2D uTextureMask;
varying lowp vec2 texCoords0;

void main()
{
    //gl_FragColor = vec4(0.5, 1.0, 1.0, 1.0);
    gl_FragColor = texture2D(uTextureMask, texCoords0);
}
