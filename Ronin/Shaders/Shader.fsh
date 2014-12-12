//
//  Shader.fsh
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

varying lowp vec4 colorVarying;

uniform sampler2D uTextureMask0;
uniform sampler2D uTextureMask1;

varying lowp vec2 texCoords0;
varying lowp vec2 texCoords1;

void main()
{
    lowp vec4 textColor = texture2D(uTextureMask0, texCoords0);
    
    if (textColor == vec4(1.0, 1.0, 1.0, 1.0)) {
        textColor = texture2D(uTextureMask1, texCoords1) + colorVarying;
    }
    
    gl_FragColor = textColor;
}
