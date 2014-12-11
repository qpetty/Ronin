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

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ, texture0x, texture0y, texture1x, texture1y,
    0.5f, 0.5f, -0.5f,          0.0f, 0.0f, 1.0f,   1.0f, 1.0f,     TEXTURE_BOX_SIZE,   TEXTURE_BOX_SIZE,
    -0.5f, -0.5f, -0.5f,        0.0f, 0.0f, 1.0f,   0.0f, 0.0f,     0.0f,               0.0f,
    0.5f, -0.5f, -0.5f,         0.0f, 0.0f, 1.0f,   1.0f, 0.0f,     TEXTURE_BOX_SIZE,   0.0f,
    0.5f, 0.5f, -0.5f,          0.0f, 0.0f, 1.0f,   1.0f, 1.0f,     TEXTURE_BOX_SIZE,   TEXTURE_BOX_SIZE,
    -0.5f, -0.5f, -0.5f,        0.0f, 0.0f, 1.0f,   0.0f, 0.0f,     0.0f,               0.0f,
    -0.5f, 0.5f, -0.5f,         0.0f, 0.0f, 1.0f,   0.0f, 1.0f,     0.0f,               TEXTURE_BOX_SIZE
    
    //    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    //    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    //    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    //    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    //    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    //    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    //
    //    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    //    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    //    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    //    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    //    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    //    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    //
    //    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    //    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    //    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    //    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    //    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    //    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    //
    //    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    //    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    //    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    //    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    //    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    //    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    //
    //    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    //    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    //    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    //    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    //    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    //    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

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
        [self setupGL];
    }
    return self;
}

- (void)setupGL
{
    GLenum err;
    //[EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glUseProgram(self.programID);
    
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    glEnable(GL_DEPTH_TEST);
    
    NSDictionary *textureLoaderOptions = @{GLKTextureLoaderOriginBottomLeft: [NSNumber numberWithBool:YES]};
    NSError *theError;
    
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mustang" ofType:@"bmp"];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ChristmasPresent" ofType:@"png"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"square" ofType:@"png"];
    
    glActiveTexture(GL_TEXTURE0);
    spriteTexture0 = [GLKTextureLoader textureWithContentsOfFile:filePath options:textureLoaderOptions error:&theError];
    if (theError) {
        NSLog(@"error loading texture0: %@", theError);
    }
    if((err = glGetError())){NSLog(@"GL Error = %u", err);}
    glUniform1i([self getUniformID:@"uTextureMask0"], 0);
    if((err = glGetError())){NSLog(@"GL Error = %u", err);}
    glBindTexture(spriteTexture0.target, spriteTexture0.name);
    if((err = glGetError())){NSLog(@"GL Error = %u", err);}
    
    //filePath = [[NSBundle mainBundle] pathForResource:@"mustang" ofType:@"bmp"];
    //filePath = [[NSBundle mainBundle] pathForResource:@"watercolor_texture_bw" ofType:@"png"];
    //filePath = [[NSBundle mainBundle] pathForResource:@"ChristmasPresent" ofType:@"png"];
    filePath = [[NSBundle mainBundle] pathForResource:@"watercolor_texture_bw_square" ofType:@"png"];
    
    NSLog(@"filepath: %@", filePath);
    glActiveTexture(GL_TEXTURE1);
    spriteTexture1 = [GLKTextureLoader textureWithContentsOfFile:filePath options:textureLoaderOptions error:&theError];
    if (theError) {
        NSLog(@"error loading texture1: %@", theError);
    }
    
    glUniform1i([self getUniformID:@"uTextureMask1"], 1);
    if((err = glGetError())){NSLog(@"GL Error = %u", err);}
    glBindTexture(spriteTexture1.target, spriteTexture1.name);
    
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    if((err = glGetError())){NSLog(@"GL Error = %u", err);}
    
    //Binds arrays for the characters
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    GLuint attribID = [self getAttributeID:@"position"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 3, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(0));
    
    attribID = [self getAttributeID:@"normal"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 3, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(3 * sizeof(GLfloat)));
    
    attribID = [self getAttributeID:@"texCoord0"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 2, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(6 * sizeof(GLfloat)));
    
    attribID = [self getAttributeID:@"texCoord1"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 2, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(8 * sizeof(GLfloat)));
    
    /*
    //Binds arrays for the sword tail
    glGenVertexArraysOES(1, &_trailArray);
    glBindVertexArrayOES(_trailArray);
    
    glGenBuffers(1, &_trailBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _trailBuffer);
    glBufferData(GL_ARRAY_BUFFER, trail.vertexArraySize, trail.vertexArray, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), BUFFER_OFFSET(3 * sizeof(GLfloat)));
    */
    
    glBindVertexArrayOES(0);
}

- (BOOL)loadShaders
{
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    self.programID = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(self.programID, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(self.programID, fragShader);
    
    [self bindAttribs:@"position"];
    [self bindAttribs:@"normal"];
    [self bindAttribs:@"texCoord0"];
    [self bindAttribs:@"texCoord1"];
    
    [self linkProgram];
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
    
    [self setAllUniforms];
    
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

-(void)setAllUniforms {
    // Get uniform locations.
    [self bindUniform:@"modelViewProjectionMatrix"];
    [self bindUniform:@"normalMatrix"];
    [self bindUniform:@"diffuseColor"];
    [self bindUniform:@"uTextureMask0"];
    [self bindUniform:@"uTextureMask1"];
    [self bindUniform:@"uRandNum"];
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
