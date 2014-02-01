//
//  OGKGameTimer.h
//  ExploRace
//
//  Created by David Samuelson on 2/1/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGKGameTimer : NSObject

+ (OGKGameTimer *)sharedInstance;
- (void)runForTime:(int)time;
- (BOOL)isDone;
- (int)getTimeLeft;

@end
