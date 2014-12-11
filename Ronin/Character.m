//
//  Character.m
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Character.h"

@implementation Character

-(instancetype)init {
    self = [super init];
    if (self) {
        self.isVisible = YES;

//        GLKMatrix3 ident = GLKMatrix3Identity;
//        
//        ident.m20 = (1.0 - TEXTURE_BOX_SIZE) * RANDOM_NUMBER_0_TO_1;
//        ident.m21 = (1.0 - TEXTURE_BOX_SIZE) * RANDOM_NUMBER_0_TO_1;
//        
//        //self.randomMat = ident;
//        self.randomMat = GLKMatrix3RotateZ(ident, RANDOM_NUMBER_0_TO_1 * 2.0 * M_PI);
        
        GLKMatrix3 ident = GLKMatrix3Identity;

        ident = GLKMatrix3RotateZ(ident, RANDOM_NUMBER_0_TO_1 * 2.0 * M_PI);
        //Maybe take out the TEXTURE_BOX_SIZE addition, but looks ok for now
        ident.m20 = TEXTURE_BOX_SIZE + (1.0 - TEXTURE_BOX_SIZE) * RANDOM_NUMBER_0_TO_1;
        ident.m21 = TEXTURE_BOX_SIZE + (1.0 - TEXTURE_BOX_SIZE) * RANDOM_NUMBER_0_TO_1;
        self.randomMat = ident;
    }
    return self;
}

-(GLKMatrix4)modelMatrix {
    return GLKMatrix4MakeTranslation(self.location.x, self.location.y, self.location.z);
}

-(GLKMatrix3)normalMatrix {
    return GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.modelMatrix), NULL);
}

-(void)update {
    NSLog(@"Please implement update on: %@", self);
}

@end
