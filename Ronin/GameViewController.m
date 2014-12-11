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
#import "SwordTrail.h"
#import "Ground.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

GLfloat gCubeVertexData[60] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ, texture0x, texture0y, texture1x, texture1y,
    0.5f, 0.5f, -0.5f,          0.0f, 0.0f, 1.0f,   1.0f, 1.0f,     TEXTURE_BOX_SIZE,   TEXTURE_BOX_SIZE,
    -0.5f, -0.5f, -0.5f,        0.0f, 0.0f, 1.0f,   0.0f, 0.0f,     0.0f,               0.0f,
    0.5f, -0.5f, -0.5f,         0.0f, 0.0f, 1.0f,   1.0f, 0.0f,     TEXTURE_BOX_SIZE,   0.0f,
    0.5f, 0.5f, -0.5f,          0.0f, 0.0f, 1.0f,   1.0f, 1.0f,     TEXTURE_BOX_SIZE,   TEXTURE_BOX_SIZE,
    -0.5f, -0.5f, -0.5f,        0.0f, 0.0f, 1.0f,   0.0f, 0.0f,     0.0f,               0.0f,
    -0.5f, 0.5f, -0.5f,         0.0f, 0.0f, 1.0f,   0.0f, 1.0f,     0.0f,               TEXTURE_BOX_SIZE
};

@interface GameViewController () {
    GLSingleProgram *enemyProgram, *swordTrailProgram, *backgroundProgram;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    GLKMatrix4 _projectionMatrix;
    float _rotation;
    CGPoint _translation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLuint _trailArray;
    GLuint _trailBuffer;
    
    GLuint _texCoordsBuf;
    
    GLuint texture[1];
    
    GLKVector4 beginningTouch;
    
    Hero *hero;
    NSMutableArray *allEnemies;
    NSUInteger enemiesKilled;
    
    SwordTrail *trail;
    Ground *background;
    
    GLKTextureInfo *spriteTexture0, *spriteTexture1;
    GLenum err;
}
@property (strong, nonatomic) EAGLContext *context;

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInteractionEvent:)];
    [view addGestureRecognizer:tap];
    
    [EAGLContext setCurrentContext:self.context];
    
    trail = [[SwordTrail alloc] init];
    
    //Create the enemy and the main character program
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    enemyProgram = [[GLSingleProgram alloc] initWithVertexShader:vertShaderPathname andFragmentShader:fragShaderPathname];
    
    [enemyProgram bindAttribs:@"position"];
    [enemyProgram bindAttribs:@"normal"];
    [enemyProgram bindAttribs:@"texCoord0"];
    [enemyProgram bindAttribs:@"texCoord1"];
    
    [enemyProgram linkProgram];
    
    [enemyProgram bindUniform:@"modelViewProjectionMatrix"];
    [enemyProgram bindUniform:@"normalMatrix"];
    [enemyProgram bindUniform:@"diffuseColor"];
    [enemyProgram bindUniform:@"uTextureMask0"];
    [enemyProgram bindUniform:@"uTextureMask1"];
    [enemyProgram bindUniform:@"uRandNum"];
    
    [self setupEnemyProgram];
    
    
    //Create the Swordtrail program
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"SwordTrail" ofType:@"vsh"];
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"SwordTrail" ofType:@"fsh"];
    swordTrailProgram = [[GLSingleProgram alloc] initWithVertexShader:vertShaderPathname andFragmentShader:fragShaderPathname];
    
    [swordTrailProgram bindAttribs:@"position"];
    [swordTrailProgram bindAttribs:@"normal"];
    [swordTrailProgram bindAttribs:@"color"];
    
    [swordTrailProgram linkProgram];
    
    [swordTrailProgram bindUniform:@"modelViewProjectionMatrix"];
    [swordTrailProgram bindUniform:@"normalMatrix"];
    
    [self setupSwordTrail];
    
    
    //Create Background Program
    background = [[Ground alloc] init];
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Background" ofType:@"vsh"];
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Background" ofType:@"fsh"];
    backgroundProgram = [[GLSingleProgram alloc] initWithVertexShader:vertShaderPathname andFragmentShader:fragShaderPathname];
    
    [backgroundProgram bindAttribs:@"position"];
    //[backgroundProgram bindAttribs:@"normal"];
    [backgroundProgram bindAttribs:@"texCoord0"];
    
    [backgroundProgram linkProgram];
    
    [backgroundProgram bindUniform:@"modelViewProjectionMatrix"];
    [backgroundProgram bindUniform:@"normalMatrix"];
    [backgroundProgram bindUniform:@"uTextureMask"];

    [self setupBackground];
}

- (void)setupEnemyProgram
{
    //[EAGLContext setCurrentContext:self.context];
    
    glUseProgram(enemyProgram.programID);
    
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

    glBindTexture(spriteTexture0.target, spriteTexture0.name);
    if((err = glGetError())){NSLog(@"GL Error = %u", err);}
    
    //filePath = [[NSBundle mainBundle] pathForResource:@"mustang" ofType:@"bmp"];
    //filePath = [[NSBundle mainBundle] pathForResource:@"watercolor_texture_bw" ofType:@"png"];
    //filePath = [[NSBundle mainBundle] pathForResource:@"ChristmasPresent" ofType:@"png"];
    filePath = [[NSBundle mainBundle] pathForResource:@"watercolor_texture_bw_square" ofType:@"png"];
    
    //NSLog(@"filepath: %@", filePath);
    glActiveTexture(GL_TEXTURE1);
    spriteTexture1 = [GLKTextureLoader textureWithContentsOfFile:filePath options:textureLoaderOptions error:&theError];
    if (theError) {
        NSLog(@"error loading texture1: %@", theError);
    }
    
    glBindTexture(spriteTexture1.target, spriteTexture1.name);
    if((err = glGetError())){NSLog(@"GL Error = %u", err);}
    
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
    
    GLuint attribID = [enemyProgram getAttributeID:@"position"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 3, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(0));
    
    attribID = [enemyProgram getAttributeID:@"normal"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 3, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(3 * sizeof(GLfloat)));
    
    attribID = [enemyProgram getAttributeID:@"texCoord0"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 2, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(6 * sizeof(GLfloat)));
    
    attribID = [enemyProgram getAttributeID:@"texCoord1"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 2, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(8 * sizeof(GLfloat)));
    
    glBindVertexArrayOES(0);
}

-(void)setupSwordTrail {
    
    glUseProgram(swordTrailProgram.programID);
    
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    glEnable(GL_DEPTH_TEST);

    //Binds arrays for the sword tail
    glGenVertexArraysOES(1, &_trailArray);
    glBindVertexArrayOES(_trailArray);
    
    glGenBuffers(1, &_trailBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _trailBuffer);
    glBufferData(GL_ARRAY_BUFFER, trail.vertexArraySize, trail.vertexArray, GL_DYNAMIC_DRAW);
    
    GLuint attribID = [swordTrailProgram getAttributeID:@"position"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 3, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(0));
    
    attribID = [swordTrailProgram getAttributeID:@"normal"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 3, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(3 * sizeof(GLfloat)));
    
    attribID = [swordTrailProgram getAttributeID:@"color"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 4, GL_FLOAT, GL_FALSE, 10 * sizeof(GLfloat), BUFFER_OFFSET(6 * sizeof(GLfloat)));
    
    glBindVertexArrayOES(0);
}

-(void)setupBackground {
    glUseProgram(backgroundProgram.programID);
    
    //glEnable(GL_DEPTH_TEST);
    
    NSDictionary *textureLoaderOptions = @{GLKTextureLoaderOriginBottomLeft: [NSNumber numberWithBool:YES]};
    NSError *theError;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mustang" ofType:@"bmp"];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ChristmasPresent" ofType:@"png"];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"square" ofType:@"png"];
    
    glActiveTexture(GL_TEXTURE2);
    background.texInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:textureLoaderOptions error:&theError];
    if (theError) {
        NSLog(@"error loading texture0: %@", theError);
    }
    
    glBindTexture(background.texInfo.target, background.texInfo.name);
    if((err = glGetError())){NSLog(@"GL Error = %u", err);}
    
    
    //Binds arrays for the background
    glGenVertexArraysOES(1, &background->glNameVertexArray);
    glBindVertexArrayOES(background->glNameVertexArray);
    
    glGenBuffers(1, &background->glNameVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, background->glNameVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, background.vertexArraySize, background.vertexArray, GL_STATIC_DRAW);
    
    GLuint attribID = [backgroundProgram getAttributeID:@"position"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), BUFFER_OFFSET(0));
    
//    attribID = [backgroundProgram getAttributeID:@"normal"];
//    glEnableVertexAttribArray(attribID);
//    glVertexAttribPointer(attribID, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), BUFFER_OFFSET(3 * sizeof(GLfloat)));
    
    attribID = [backgroundProgram getAttributeID:@"texCoord0"];
    glEnableVertexAttribArray(attribID);
    glVertexAttribPointer(attribID, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), BUFFER_OFFSET(6 * sizeof(GLfloat)));
    
    glBindVertexArrayOES(0);
}

-(void)setupGame {
    srand((unsigned int)time(0));
    hero = [[Hero alloc] init];
    hero.location = GLKVector3Make(0.0f, 0.0f, -5.0f);
    
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
    [enemyProgram tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [enemyProgram tearDownGL];
        
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

#pragma mark - UIStuff

-(void)updateHUD {
    self.highScore.text = [NSString stringWithFormat:@"Score: %lu", enemiesKilled];
    if (hero.health < 0) { hero.health = 0; }
    self.lifeDisplay.text = [NSString stringWithFormat:@"Lives: %lu", hero.health];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    [hero update];
    
    GLKVector3 worldMove = GLKVector3Subtract(GLKVector3Make(0.0f, 0.0f, 0.0f), hero.location);
    worldMove = GLKVector3DivideScalar(worldMove, 80.0);
    worldMove.z = 0;
    hero.location = GLKVector3Add(hero.location, worldMove);
    hero.destination = GLKVector3Add(hero.destination, worldMove);
    
    for (Enemy *en in allEnemies) {
        [en update];
        en.location = GLKVector3Add(en.location, worldMove);
    }
    
    [trail update];
    
    [self updateHUD];
    
    if (hero.health <= 0) {
        [self gameOver];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLKMatrix4 mvp;
    
    glUseProgram(backgroundProgram.programID);
    glBindVertexArrayOES(background->glNameVertexArray);

    mvp = GLKMatrix4Multiply(_projectionMatrix, background.modelMatrix);
    glUniformMatrix4fv([backgroundProgram getUniformID:@"modelViewProjectionMatrix"], 1, 0, mvp.m);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(background.texInfo.target, background.texInfo.name);
    glUniform1i([backgroundProgram getUniformID:@"uTextureMask"], 2);
    
    if((err = glGetError())){NSLog(@"Background GL Error = %u", err);}
    glDrawArrays(GL_TRIANGLES, 0, background.verticiesToDraw);
    
    
    
    // Render the object again with ES2
    glUseProgram(enemyProgram.programID);
    glBindVertexArrayOES(_vertexArray);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(spriteTexture0.target, spriteTexture0.name);
    glUniform1i([enemyProgram getUniformID:@"uTextureMask0"], 0);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(spriteTexture1.target, spriteTexture1.name);
    glUniform1i([enemyProgram getUniformID:@"uTextureMask1"], 1);
    
    mvp = GLKMatrix4Multiply(_projectionMatrix, hero.modelMatrix);
    
    //Bind and draw Hero
    glUniform4fv([enemyProgram getUniformID:@"diffuseColor"], 1, hero.diffuseColor.v);
    glUniformMatrix3fv([enemyProgram getUniformID:@"uRandNum"], 1, 0, hero.randomMat.m);
    
    glUniformMatrix4fv([enemyProgram getUniformID:@"modelViewProjectionMatrix"], 1, 0, mvp.m);
    glUniformMatrix3fv([enemyProgram getUniformID:@"normalMatrix"], 1, 0, hero.normalMatrix.m);
    
    if((err = glGetError())){NSLog(@"Hero GL Error = %u", err);}
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    
    //Bind and draw Enemies
    for (Enemy *en in allEnemies) {
        if (en.isVisible) {
            mvp = GLKMatrix4Multiply(_projectionMatrix, en.modelMatrix);
            
            glUniform4fv([enemyProgram getUniformID:@"diffuseColor"], 1, en.diffuseColor.v);
            glUniformMatrix3fv([enemyProgram getUniformID:@"uRandNum"], 1, 0, en.randomMat.m);
            
            glUniformMatrix4fv([enemyProgram getUniformID:@"modelViewProjectionMatrix"], 1, 0, mvp.m);
            glUniformMatrix3fv([enemyProgram getUniformID:@"normalMatrix"], 1, 0, en.normalMatrix.m);
            
            if((err = glGetError())){NSLog(@"Enemy GL Error = %u", err);}
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
    }
    
    if (trail.verticiesToDraw) {

        glUseProgram(swordTrailProgram.programID);
    
        //Bind and draw swordtail
        glBindVertexArrayOES(_trailArray);
        
        glBindBuffer(GL_ARRAY_BUFFER, _trailBuffer);
        glBufferData(GL_ARRAY_BUFFER, trail.vertexArraySize, trail.vertexArray, GL_DYNAMIC_DRAW);

        mvp = GLKMatrix4Multiply(_projectionMatrix, trail.modelMatrix);
        glUniformMatrix4fv([swordTrailProgram getUniformID:@"modelViewProjectionMatrix"], 1, 0, mvp.m);
        glUniformMatrix3fv([swordTrailProgram getUniformID:@"normalMatrix"], 1, 0, trail.normalMatrix.m);
        
        if((err = glGetError())){NSLog(@"SwordTrail GL Error = %u", err);}
        glDrawArrays(GL_TRIANGLE_STRIP, 0, trail.verticiesToDraw - 1);
    }
    
    glBindVertexArrayOES(0);
}

#pragma mark Gesture Callbacks

- (void)userInteractionEvent:(UIGestureRecognizer*)sender {
    //NSLog(@"sender: %@", sender);
    
    if (self.paused == YES) {
        return;
    }
    
    UIView *viewOfTrans = sender.view;
    
    if ([sender isKindOfClass:[UIRotationGestureRecognizer class]]) {
        UIRotationGestureRecognizer *rot = (UIRotationGestureRecognizer*)sender;
        _rotation = -rot.rotation;
    } else if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
        GLKVector3 heroLocation = hero.location;
        
        GLKVector4 point = [self pointInModelSpaceForScreenPoint:[tap locationInView:viewOfTrans]
                                                          ofView:sender.view
                                            withProjectionMatrix:_projectionMatrix
                                                        andDepth:-heroLocation.z];
        
        for (Enemy *oneEnemy in allEnemies) {
            [oneEnemy bump:point];
        }
        
    } else if ([sender isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)sender;
        GLKVector3 heroLocation = hero.location;
        
        GLKVector4 point = [self pointInModelSpaceForScreenPoint:[pan locationInView:viewOfTrans]
                                                          ofView:sender.view
                                            withProjectionMatrix:_projectionMatrix
                                                        andDepth:-heroLocation.z];
        
        [trail addTouchPoint:point];
        
        if (sender.state == UIGestureRecognizerStateBegan) {
            //NSLog(@"began touches: %@", [NSThread isMainThread] ? @"YES" : @"NO");
            
            beginningTouch = point;

            //NSLog(@"beginningTouch: (%f, %f, %f, %f)", beginningTouch.x, beginningTouch.y, beginningTouch.z, beginningTouch.w);
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            //NSLog(@"ended touches");
            
            GLKVector4 dir = GLKVector4Subtract(point, beginningTouch);
            dir = GLKVector4DivideScalar(dir, 2.0f);
            GLKVector4 hitPoint = GLKVector4Add(beginningTouch, dir);
            
            for (Enemy *oneEnemy in allEnemies) {

                if ([oneEnemy hitEnemyAt:hitPoint] == YES) {
                    enemiesKilled++;
                    [hero killedCharacter:oneEnemy];
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

@end
