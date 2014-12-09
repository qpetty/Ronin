//
//  Hero.m
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Hero.h"

@implementation Hero

-(instancetype)init {
    self = [super init];
    if (self) {
        self.diffuseColor = GLKVector4Make(0.4f, 0.4f, 1.0f, 1.0f);
    }
    return self;
}

@end
