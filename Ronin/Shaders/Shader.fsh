//
//  Shader.fsh
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

varying lowp vec4 colorVarying;

uniform sampler2D uTextureMask;
varying lowp vec2 texCoords;

void main()
{
    lowp vec4 textColor = texture2D(uTextureMask, texCoords);
    
    if (textColor == vec4(0.0, 0.0, 0.0, 0.0)) {
        textColor += colorVarying * 0.5;
    }
    
    gl_FragColor = textColor;
    
    //gl_FragColor = texture2D(uTextureMask, texCoords) + colorVarying * 0.5;
    //gl_FragColor = colorVarying;
}
