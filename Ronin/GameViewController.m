//
//  GameViewController.m
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>

#import "Hero.h"
#import "Enemy.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_DIFFUSE_COLOR,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, 0.5f, -0.5f,        0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, -0.5f,          0.0f, 0.0f, 1.0f,
    
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

@interface GameViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    GLKMatrix4 _projectionMatrix;
    float _rotation;
    CGPoint _translation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLKVector4 beginningTouch;
    
    Hero *hero;
    NSMutableArray *allEnemies;
    NSUInteger enemiesKilled;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(userInteractionEvent:)];
    [view addGestureRecognizer:rotation];
    
    UIPanGestureRecognizer *panning = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userInteractionEvent:)];
    [view addGestureRecognizer:panning];
    
    [self setupGL];
}

-(void)setupGame {
    hero = [[Hero alloc] init];
    hero.location = GLKVector3Make(0.0f, 0.0f, -5.0f);
    
    srand((unsigned int)time(0));
    allEnemies = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 6; i++) {
        Enemy *en = [[Enemy alloc] initWithDepth:-5.0];
        en.target = hero;
        [allEnemies addObject:en];
    }
    enemiesKilled = 0;
    [self updateHUD];
}

-(IBAction)startGame:(id)sender {
    [self setupGame];
    self.startButton.hidden = YES;
    self.paused = NO;
}

-(void)gameOver {
    self.startButton.hidden = NO;
    self.paused = YES;
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - UIStuff

-(void)updateHUD {
    self.highScore.text = [NSString stringWithFormat:@"Score: %lu", enemiesKilled];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    for (Enemy *en in allEnemies) {
        [en update];
    }
    
    if (hero.health <= 0) {
        [self gameOver];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    GLKMatrix4 mvp = GLKMatrix4Multiply(_projectionMatrix, hero.modelMatrix);
    
    glUniform4fv(uniforms[UNIFORM_DIFFUSE_COLOR], 1, hero.diffuseColor.v);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, mvp.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, hero.normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    for (Enemy *en in allEnemies) {
        if (en.isVisible) {
            mvp = GLKMatrix4Multiply(_projectionMatrix, en.modelMatrix);
            
            glUniform4fv(uniforms[UNIFORM_DIFFUSE_COLOR], 1, en.diffuseColor.v);
            
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, mvp.m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, en.normalMatrix.m);
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
    }
}

#pragma mark Gesture Callbacks

- (void)userInteractionEvent:(UIGestureRecognizer*)sender {
    //NSLog(@"sender: %@", sender);
    
    if (self.paused == YES) {
        return;
    }
    
    if ([sender isKindOfClass:[UIRotationGestureRecognizer class]]) {
        UIRotationGestureRecognizer *rot = (UIRotationGestureRecognizer*)sender;
        _rotation = -rot.rotation;
    } else if ([sender isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)sender;
        UIView *viewOfTrans = sender.view;
        GLKVector3 heroLocation = hero.location;
        
        if (sender.state == UIGestureRecognizerStateBegan) {
            //NSLog(@"began touches: %@", [NSThread isMainThread] ? @"YES" : @"NO");
            
            beginningTouch = [self pointInModelSpaceForScreenPoint:[pan locationInView:viewOfTrans]
                                                            ofView:sender.view
                                              withProjectionMatrix:_projectionMatrix
                                                          andDepth:-heroLocation.z];

            //NSLog(@"beginningTouch: (%f, %f, %f, %f)", beginningTouch.x, beginningTouch.y, beginningTouch.z, beginningTouch.w);
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            //NSLog(@"ended touches");
            
            GLKVector4 point = [self pointInModelSpaceForScreenPoint:[pan locationInView:viewOfTrans]
                                                              ofView:sender.view
                                                withProjectionMatrix:_projectionMatrix
                                                            andDepth:-heroLocation.z];
            
            GLKVector4 dir = GLKVector4Subtract(point, beginningTouch);
            dir = GLKVector4DivideScalar(dir, 2.0f);
            GLKVector4 hitPoint = GLKVector4Add(beginningTouch, dir);
            
            for (Enemy *oneEnemy in allEnemies) {

                if ([oneEnemy hitEnemyAt:hitPoint] == YES) {
                    enemiesKilled++;
                    [self updateHUD];
                }
            }
            //NSLog(@"endTouch: (%f, %f, %f, %f)", point.x, point.y, point.z, point.w);
        }
    }
}

-(GLKVector4)pointInModelSpaceForScreenPoint:(CGPoint)point ofView:(UIView*)view withProjectionMatrix:(GLKMatrix4)projMatrix andDepth:(float)depth {
    bool invertable;
    //x2 = (2/w)x1 - 1
    //y2 = (-2/h)y1 + 1
    GLKVector4 normalizedPoint = GLKVector4Make((2.0 * point.x / view.frame.size.width) - 1.0,
                                                (-2.0 * point.y / view.frame.size.height) + 1.0,
                                                0.0f,
                                                1.0f);
    
    normalizedPoint = GLKMatrix4MultiplyVector4(GLKMatrix4Invert(projMatrix, &invertable), normalizedPoint);
    if (invertable == NO) {
        normalizedPoint = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
    } else {
        normalizedPoint.x += normalizedPoint.x * depth;
        normalizedPoint.y += normalizedPoint.y * depth;
    }
    return normalizedPoint;
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
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
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_DIFFUSE_COLOR] = glGetUniformLocation(_program, "diffuseColor");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
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

@end
