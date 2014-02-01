//
//  OGKGameTimer.m
//  ExploRace
//
//  Created by David Samuelson on 2/1/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKGameTimer.h"

@interface OGKGameTimer ()

@property NSTimer *timer;
@property int currentMinute;
@property int currentSecond;

@end

@implementation OGKGameTimer

- (instancetype)init
{
    if (self = [super init])
    {
    }
    return self;
}

+ (OGKGameTimer *)sharedInstance
{
    static OGKGameTimer *_sharedIntance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedIntance = [[OGKGameTimer alloc] init];
    });
    
    return _sharedIntance;
}

// Time in seconds
- (void)runForTime:(int)time
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    self.currentMinute = time / 60;
    self.currentSecond = time % 60;
}

- (void)timerFired
{
    if ((self.currentMinute > 0 || self.currentSecond >= 0) && self.currentMinute >= 0)
    {
        if (self.currentSecond == 0)
        {
            self.currentMinute -= 1;
            self.currentSecond = 59;
        }
        else if (self.currentSecond > 0)
        {
            self.currentSecond -= 1;
        }
    }
    else
    {
        [self.timer invalidate];
    }
}

- (BOOL)isDone
{
    return self.currentSecond > 0 || self.currentMinute;
}

- (NSString *)getTimeAsString
{
    return [NSString stringWithFormat:@"%2d:%2d", self.currentMinute, self.currentSecond];
}

- (int)getTimeLeft
{
    return self.currentMinute * 60 + self.currentSecond;
}

@end
