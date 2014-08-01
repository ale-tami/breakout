//
//  ViewController.m
//  Breakout
//
//  Created by Alejandro Tami on 01/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "ViewController.h"
#import "BlockView.h"

@interface ViewController () <UICollisionBehaviorDelegate>

@property (weak, nonatomic) IBOutlet UIView *paddle;
@property (weak, nonatomic) IBOutlet UIView *ball;

@property (weak, nonatomic) BlockView *block;
@property UIDynamicAnimator *dynamicAnimator;
@property UIPushBehavior *pushBehavior;
@property UICollisionBehavior *collisionBehavior;
@property UIDynamicItemBehavior *dynamicBallBehavior;
@property UIDynamicItemBehavior *dynamicPaddleBehavior;
@property UIDynamicItemBehavior *dynamicBlockBehavior;
@property CGPoint ballVelocity;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeDynamics];
    //[self initializeBlocks];

}

- (IBAction)onDrag:(UIPanGestureRecognizer *)sender
{
    self.paddle.center = CGPointMake([sender locationInView:self.view].x, self.paddle.center.y);
    
    [self.dynamicAnimator updateItemUsingCurrentState:self.paddle];

}

- (void) startBallMoving
{
    CGPoint opositeVelocity = CGPointMake(self.ballVelocity.x * -1.0,
                                          self.ballVelocity.y * -1.0);
    
    [self.dynamicBallBehavior addLinearVelocity:opositeVelocity forItem:self.ball];
}

- (void) restartGame
{
    [self.dynamicAnimator removeAllBehaviors];
    
    [self initializeDynamics];
    [self initializeBlocks];
    
}

#pragma mark initializations

- (void) initializeDynamics
{
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ball] mode:UIPushBehaviorModeInstantaneous];
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ball, self.paddle]];
    self.dynamicBallBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ball]];
    self.dynamicPaddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddle]];
//    self.dynamicBlockBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.block]];
    
    self.pushBehavior.pushDirection = CGVectorMake(0.0, 1.0);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = 0.2;
    
    [self.collisionBehavior addBoundaryWithIdentifier: @"belowPaddle"
                                            fromPoint: CGPointMake(0.0, self.paddle.center.y + self.ball.frame.size.height*2)
                                              toPoint: CGPointMake(self.view.frame.size.width, self.paddle.center.y + self.ball.frame.size.height*2) ];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    self.collisionBehavior.collisionDelegate = self;
    
    self.dynamicBallBehavior.elasticity = 1.0;
    self.dynamicBallBehavior.density = 1.0;
    self.dynamicBallBehavior.allowsRotation = NO;
    self.dynamicBallBehavior.friction = 0.0;
    self.dynamicBallBehavior.resistance = 0.0;
    
//    self.dynamicBlockBehavior.elasticity = 1.0;
//    self.dynamicBlockBehavior.density = 10000.0;
    
    self.dynamicPaddleBehavior.allowsRotation = NO;
    self.dynamicPaddleBehavior.density = 10000.0;
    
    [self.dynamicAnimator addBehavior:self.pushBehavior];
    [self.dynamicAnimator addBehavior:self.collisionBehavior];
    [self.dynamicAnimator addBehavior:self.dynamicPaddleBehavior];
    [self.dynamicAnimator addBehavior:self.dynamicBallBehavior];
   // [self.dynamicAnimator addBehavior:self.dynamicBlockBehavior];
}

- (void) initializeBlocks
{
    BlockView *block;
     NSMutableArray *blocksArray = [[NSMutableArray alloc] init];
    CGRect rect = CGRectMake(0.0f, 0.0f, 32.0, 16.0);
    float originY = 0.0;
    float originX = 0.0;
    
    for (int i = 0; i < 40; i++) {
        
        block = [[BlockView alloc] initWithFrame:rect];
        [self.view addSubview:block];
        [blocksArray addObject:block];
        [self.collisionBehavior addItem:block];
        
        
        //Screen width 320
        if (i >= 8  && ((i % 8) == 0)) {
            originY += 16.0; // height + 1
            originX = 0.0;
        } else {
            originX += rect.size.width;
        }
        rect = CGRectMake(originX,
                          originY,
                          rect.size.width,
                          rect.size.height);
        
    }
    self.dynamicBlockBehavior = [[UIDynamicItemBehavior alloc] initWithItems:blocksArray];
    self.dynamicBlockBehavior.elasticity = 1.0f;
    self.dynamicBlockBehavior.density = 10000.0f;
    
    [self.dynamicAnimator addBehavior:self.dynamicBlockBehavior];
}

#pragma mark collision delegate
                                   

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if ( [((NSString*)identifier) isEqualToString:@"belowPaddle"]) {
        
        self.ballVelocity = [self.dynamicBallBehavior linearVelocityForItem:self.ball];
        
        CGPoint velocity = CGPointMake([self.dynamicBallBehavior linearVelocityForItem:self.ball].x*-1.0,
                                       [self.dynamicBallBehavior linearVelocityForItem:self.ball].y*-1.0);
        
        [NSTimer scheduledTimerWithTimeInterval:1.2
                                target:self
                              selector:@selector(startBallMoving)
                              userInfo:nil
                               repeats:NO];
    
        [self.dynamicBallBehavior addLinearVelocity:velocity forItem:self.ball];
        self.ball.center = self.view.center;

        [self.dynamicAnimator updateItemUsingCurrentState:self.ball];
        
    }
    
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    if ([item1 isEqual:self.ball] && [item2 isKindOfClass:BlockView.class]) {
        [(BlockView*)item2 removeFromSuperview];
        [self.collisionBehavior removeItem:item2];
    }
    
    if ([item1 isEqual:self.paddle] || [item2 isEqual:self.paddle]) {
        if ([self.collisionBehavior items].count == 2) // ball and paddle
        {
            [NSTimer scheduledTimerWithTimeInterval:1.2
                                             target:self
                                           selector:@selector(restartGame)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
    
}

@end
