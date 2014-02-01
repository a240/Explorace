//
//  OGKRect.h
//  ExploRace
//
//  Created by David Samuelson on 2/1/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGKRect : NSObject

@property float width;
@property float height;
@property float x;
@property float y;

- (instancetype)initWithX:(float)x Y:(float)y Width:(float)width Height:(float)height;

@end
