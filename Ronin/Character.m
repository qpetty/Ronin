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
