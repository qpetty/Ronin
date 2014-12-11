//
//  Shader.fsh
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

varying lowp vec3 pos;
varying lowp vec3 norm;
varying lowp vec4 colorVarying;

void main()
{
    lowp vec3 n = normalize(norm);
    lowp vec3 l = normalize(vec3(0.0, 0.0, 1.0) - pos);
    
    lowp vec4 color = colorVarying * max(dot(l, n), 0.0);
    color.w = 1.0;
    gl_FragColor = color;
}
