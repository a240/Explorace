//
//  OGKAccelerometerShooterScene.m
//  ExploRace
//
//  Created by Ben Collins on 2/1/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKAccelerometerShooterScene.h"
#import <CoreMotion/CoreMotion.h>
#define ENERGY_BALL_VELOCITY 150
#define ENEMY_VELOCITY 150

@interface OGKAccelerometerShooterScene () <SKPhysicsContactDelegate>
@property SKNode *enemies;
@property SKSpriteNode *staff;
@property SKSpriteNode *energyBall;
@property BOOL ballIsActive;
@property int enemiesRemaining;
@property (strong,nonatomic) CMMotionManager *motionManager;
@property CMAttitude *referenceAttitude;

@property UISwipeGestureRecognizer *swipeUpDirectionBallGestureRecognizer;
@end

@implementation OGKAccelerometerShooterScene
static const uint32_t projectileCategory = 0x1 <<0;
static const uint32_t monsterCategory = 0x1 << 1;

static const int numEnemies = 6;

- (void)didMoveToView:(SKView *)view
{
     self.motionManager = [[CMMotionManager alloc] init];
}

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
    //resize ball based on y position
    //[self scaleSprite:self.energyBall];
    
    if (self.enemiesRemaining < 1)
    {
        [self.view removeGestureRecognizer:self.swipeUpDirectionBallGestureRecognizer];
        self.currentState = GameStateTransitioning;
        [self returnToSceneFadeToBackgroundImageNamed:@"WastelandBackgroundGood"];
    }
    
    //enemies exiting screen to left
    [self.enemies enumerateChildNodesWithName:@"enemyMovingLeft" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x + node.frame.size.width < 0) {
            CGPoint resetPoint= CGPointMake(self.size.width + node.frame.size.width, node.position.y);
            SKAction *moveEnemy = [SKAction moveTo: resetPoint duration:0.0];
            [node runAction: moveEnemy];
        }
    }];
    
    //enemies exiting screen to right
    [self.enemies enumerateChildNodesWithName:@"enemyMovingRight" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x  - node.frame.size.width/2 > self.size.width) {
            CGPoint resetPoint= CGPointMake(-node.frame.size.width, node.position.y);
            SKAction *moveEnemy = [SKAction moveTo: resetPoint duration:0.0];
            [node runAction: moveEnemy];
        }
    }];
    
    
}

- (void)willMoveFromView:(SKView *)view
{
    [super willMoveFromView:view];
    
}

-(void)createContent
{
    [super createContent];
    
    self.motionManager = [[CMMotionManager alloc] init];
    if([self.motionManager isDeviceMotionAvailable]) {
        [self.motionManager setAccelerometerUpdateInterval:1.0/30.0];
        [self.motionManager startDeviceMotionUpdates];
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMDeviceMotion *motion, NSError *error)
         {
             if(self.referenceAttitude) {
                 self.referenceAttitude = motion.attitude;
             }
             else if(!self.scene.isPaused) {
                 CMAttitude *attitude = motion.attitude;
                 // Multiply by the inverse of the reference attitude so motion is relative to the start attitude.
                 [attitude multiplyByInverseOfAttitude:_referenceAttitude];
                 [self.energyBall.physicsBody applyImpulse:CGVectorMake(attitude.roll * 250, -attitude.pitch * 200)];
             }
         }];
    }
    
    self.swipeUpDirectionBallGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipUpDirection:)];
    [self.view addGestureRecognizer:self.swipeUpDirectionBallGestureRecognizer];
    [self.swipeUpDirectionBallGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    
    [self addBackgroundImageFromName:@"WastelandBackgroundBad"];
    self.ballIsActive = NO;
    
    self.staff = [self createStaff];
    [self.world addChild:self.staff];
    
    
    self.enemiesRemaining = numEnemies;
    self.enemies = [[SKNode alloc] init];
    [self.world addChild:self.enemies];
    for (int i=0; i<numEnemies; i++) {
        [self.enemies addChild: [self createEnemy]];
    }
    
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
}

-(SKSpriteNode *)createStaff{
    SKSpriteNode *staff;
    staff = [SKSpriteNode spriteNodeWithImageNamed:@"GoodBubble"];
    CGPoint bottomOfScreen =
    CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame)+ staff.size.height/2);
    staff.position = bottomOfScreen;
    return staff;
}

-(SKSpriteNode *)createEnemy{
    //basic characteristics
    SKSpriteNode *enemy;
    enemy = [SKSpriteNode spriteNodeWithImageNamed:@"BadBubble"];
    float widthBorder = self.frame.size.width/10;
    float heightBorder = self.frame.size.height/5;
    float xpos=(arc4random() % (int) (self.frame.size.width - 2*widthBorder))+widthBorder;
    float ypos=(arc4random() % (int) (self.frame.size.height - heightBorder))+heightBorder;
    enemy.position = CGPointMake(xpos, ypos);
   
    //scale enemy
    [self scaleSprite:enemy];
    
    //sets up moving enemies (left or right)
    BOOL isLeft=arc4random()%(int)2 == 0;
    int directionModifier;
    if (isLeft) {
        enemy.name = @"enemyMovingLeft";
        directionModifier=-1;
    }
    else{
        enemy.name = @"enemyMovingRight";
        directionModifier=1;
    }
    
    SKAction *moveSideways = [SKAction moveByX:directionModifier * ENEMY_VELOCITY y:0 duration:1.0];
    [enemy runAction:moveSideways];
    [enemy runAction:[SKAction repeatActionForever:(moveSideways)]];
    
    //physics
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = monsterCategory;
    enemy.physicsBody.contactTestBitMask = projectileCategory;
    enemy.physicsBody.collisionBitMask = 0;
    
    return enemy;
}


-(SKSpriteNode *) createEnergyBall{

    //basic characteristics
    SKSpriteNode *energyBall;
    energyBall = [SKSpriteNode spriteNodeWithImageNamed:@"GoodBubble"];
    energyBall.name = @"energyBall";
    CGPoint ballSpawn =
        CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame)+ (energyBall.size.height/4)*3);
    energyBall.position = ballSpawn;
    
    //movement
    SKAction *moveBallUpwords = [SKAction moveByX:0.0 y:ENERGY_BALL_VELOCITY duration:1];
    SKAction *moveBallForever = [SKAction repeatActionForever: moveBallUpwords];
    [energyBall runAction:  moveBallForever];
    //physics
    energyBall.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:energyBall.size.width/2];
    energyBall.physicsBody.dynamic = YES;
    energyBall.physicsBody.categoryBitMask = projectileCategory;
    energyBall.physicsBody.contactTestBitMask = monsterCategory;
    energyBall.physicsBody.collisionBitMask = 0;
    energyBall.physicsBody.usesPreciseCollisionDetection = YES;
    
    
//    SKAction *scaleBall = [SKAction scaleBy:((self.frame.size.height - energyBall.position.y)/self.frame.size.height)/2 duration:1.0];
//    SKAction *moveAndScale = [SKAction group:@[scaleBall, moveBallUpwords]];
//    SKAction *moveAndScaleForever = [SKAction repeatActionForever: moveAndScale];

    return energyBall;
}

- (void)swipUpDirection:(UISwipeGestureRecognizer *)recognizer
{
//    NSLog(@"test");
//    if(self.energyBall==nil)
//    {
//        self.energyBall= [self createEnergyBall];
//        [self.world addChild: self.energyBall];
//    }
    self.energyBall= [self createEnergyBall];
    [self.world addChild: self.energyBall];
}

-(void)scaleSprite: (SKSpriteNode *) sprite
{
    CGFloat scaleAmount = ((self.frame.size.height - sprite.position.y)/self.frame.size.height);
    scaleAmount = scaleAmount;
    SKAction *scaleSprite = [SKAction scaleTo:scaleAmount duration:0.0];
    [sprite runAction: scaleSprite];
}


-(void)energyBall:(SKSpriteNode *)energyBall didCollideWithEnemy: (SKSpriteNode *)enemy
{
    NSLog(@"Hit");
    [energyBall removeFromParent];
    [enemy removeFromParent];
    self.enemiesRemaining -=1;
    energyBall = nil;
}

- (void)didBeginContact: (SKPhysicsContact *) contact
{
    NSLog(@"did begin contact");
    SKPhysicsBody *firstBody, *secondBody;
    
    if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if((firstBody.categoryBitMask & projectileCategory)!=0 && (secondBody.categoryBitMask & monsterCategory) !=0)
    {
        [self energyBall:(SKSpriteNode *) firstBody.node didCollideWithEnemy:(SKSpriteNode *) secondBody.node];
    }
    
}

@end
