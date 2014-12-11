//
//  Character.h
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#ifndef TEXTURE_BOX_SIZE
#define TEXTURE_BOX_SIZE 0.25f
#endif

@interface Character : NSObject

@property NSInteger health;
@property NSInteger maxHealth;

@property GLKVector3 location;
@property BOOL isVisible;

@property GLKVector4 diffuseColor;
@property GLKMatrix3 randomMat;

@property (nonatomic) GLKMatrix4 modelMatrix;
@property (nonatomic) GLKMatrix3 normalMatrix;

- (void)update;

@end
