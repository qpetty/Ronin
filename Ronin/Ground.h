//
//  Ground.h
//  Ronin
//
//  Created by Quinton Petty on 12/10/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ground : NSObject

@property GLKVector3 location;

@property (nonatomic) GLKMatrix4 modelMatrix;
@property (nonatomic) GLKMatrix3 normalMatrix;

@end
