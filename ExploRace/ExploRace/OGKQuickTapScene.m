//
//  OGKQuickTapScene.m
//  ExploRace
//
//  Created by Christopher Sprague on 1/30/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKQuickTapScene.h"

static NSString * const kDraggableNodeName = @"movable";

@interface OGKQuickTapScene ()

@property BOOL contentCreated;
@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic, strong) SKSpriteNode *selectedNode;
@property int numSelected;

@end

@implementation OGKQuickTapScene

- (void)createSceneContents
{
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild: [self newOGKQuickTapLabelNode]];
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint posInScene = [touch locationInNode:self];
    [self selectNodeForTouch:posInScene];
}

-(void)selectNodeForTouch:(CGPoint)touchLocation {
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    if (![_selectedNode isEqual:touchedNode] )
    {
        [_selectedNode removeAllActions];
        [_selectedNode runAction:[SKAction rotateByAngle:0 duration:.1]];
        _selectedNode = touchedNode;
        if([[touchedNode name] isEqualToString:kDraggableNodeName]){
            [_selectedNode runAction:[SKAction fadeOutWithDuration:0.2]];
        }
    }
    
}

static inline CGFloat skRandf() {
    return arc4random() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(int low, int high) {
    return ((arc4random() % (high-low)) + low);
}

- (id)initWithSize:(CGSize)size {
    const unsigned int PADDING = 50;
    if (self = [super initWithSize:size])
    {
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"RedBackground"];
        [_background setName:@"Background"];
        [_background setAnchorPoint:CGPointZero];
        [self addChild:_background];
        
        NSArray *imageNames = @[@"RedBox", @"RedBox", @"RedBox", @"RedBox", @"RedBox"];
        int ypad = self.size.height / (imageNames.count + 1);
        for(int i = 0 ; i < [imageNames count]; i++ )
        {
            NSString *imageName = [imageNames objectAtIndex:i];
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
            [sprite setName:kDraggableNodeName];
            // float offsetFraction = ((float)(i+1))/([imageNames count] + 1 );
            int low = PADDING + sprite.frame.size.width/2;
            int high = self.size.width - PADDING - sprite.frame.size.width/2;
            int randomNum = skRand(low,high);
            [sprite setPosition:CGPointMake(randomNum, ypad*(i+1))];
            [_background addChild:sprite];
        }
        
    }
    
    return self;
    
}

- (SKLabelNode* )newOGKQuickTapLabelNode
{
    SKLabelNode *OGKQuickTapLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    OGKQuickTapLabelNode.name = @"OGK Label Node";
    OGKQuickTapLabelNode.text = @"Tap all the Squares!";
    OGKQuickTapLabelNode.fontSize = 16;
    OGKQuickTapLabelNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY((self.frame))+200);
    return OGKQuickTapLabelNode;
}

float degToRad(float degree){
    return degree / 180.0f * M_PI;
}

- (void)didMoveToView:(SKView *)view
{
    if(!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated=YES;
    }
}
@end
