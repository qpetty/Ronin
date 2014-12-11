//
//  GLSingleProgram.m
//  Ronin
//
//  Created by Quinton Petty on 12/10/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "GLSingleProgram.h"
#import <OpenGLES/ES2/glext.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface UniformVariable : NSObject

@property NSString *name;
@property int number;

@end

@implementation UniformVariable

-(BOOL)isEqual:(id)object {
    if (object == nil) {
        return NO;
    }
    
    if ([object isKindOfClass:[UniformVariable class]] == NO) {
        return NO;
    }
    
    UniformVariable *v = (UniformVariable*)object;
    if ([self.name isEqualToString:v.name] == NO) {
        return NO;
    }
    
    return YES;
}

@end

@implementation GLSingleProgram {
    GLuint vertShader, fragShader;
    
    NSMutableArray  *attributes;
    NSMutableArray  *uniformsArray;
    
    GLuint _vertexBuffer;
    
    GLuint _trailArray;
    GLuint _trailBuffer;
    
    GLKTextureInfo *spriteTexture0, *spriteTexture1;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        attributes = [[NSMutableArray alloc] init];
        uniformsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(instancetype)initWithVertexShader:(NSString*)vert andFragmentShader:(NSString*)frag {
    self = [self init];
    if (self) {
        [self loadShadersWithVertex:vert andFragment:frag];
    }
    return self;
}

- (BOOL)loadShadersWithVertex:(NSString*)vert andFragment:(NSString*)frag
{
    // Create shader program.
    self.programID = glCreateProgram();
    
    // Create and compile vertex shader.
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vert]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(self.programID, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(self.programID, fragShader);
    
    return YES;
}

-(void)bindAttribs:(NSString*)name {
    [attributes addObject:name];
    glBindAttribLocation(self.programID, (GLuint)[attributes indexOfObject:name], [name UTF8String]);
}

-(GLuint)getAttributeID:(NSString*)name {
    return (GLuint)[attributes indexOfObject:name];
}

- (BOOL)linkProgram {
    // Link program.
    if (![self linkProgram:self.programID]) {
        NSLog(@"Failed to link program: %d", self.programID);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (self.programID) {
            glDeleteProgram(self.programID);
            self.programID = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(self.programID, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(self.programID, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}

-(void)bindUniform:(NSString*)name {
    UniformVariable *v = [[UniformVariable alloc] init];
    v.name = name;
    v.number = glGetUniformLocation(self.programID, [name UTF8String]);
    [uniformsArray addObject:v];
}

-(GLuint)getUniformID:(NSString*)name {
    UniformVariable *v = [[UniformVariable alloc] init];
    v.name = name;
    
    NSUInteger found = [uniformsArray indexOfObject:v];
    if (found) {
        return ((UniformVariable*)[uniformsArray objectAtIndex:found]).number;
    }
    return (GLuint)0;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)tearDownGL
{
    //[EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    if (self.programID) {
        glDeleteProgram(self.programID);
        self.programID = 0;
    }
}

@end
