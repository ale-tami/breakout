//
//  BlockView.m
//  Breakout
//
//  Created by Alejandro Tami on 01/08/14.
//  Copyright (c) 2014 Alejandro Tami. All rights reserved.
//

#import "BlockView.h"


@implementation BlockView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    CGFloat redLevel    = rand() / (float) RAND_MAX;
    CGFloat greenLevel  = rand() / (float) RAND_MAX;
    CGFloat blueLevel   = rand() / (float) RAND_MAX;
    
    self.backgroundColor = [UIColor colorWithRed: redLevel
                                             green: greenLevel
                                              blue: blueLevel
                                             alpha: 1.0];    
    
    return self;
}

@end
