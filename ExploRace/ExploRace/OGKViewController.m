//
//  OGKViewController.m
//  ExploRace
//
//  Created by David Samuelson on 1/29/14.
//  Copyright (c) 2014 OGK. All rights reserved.
//

#import "OGKViewController.h"
#import "OGKMenuScene.h"
#import "OGKMapScene.h"

@interface OGKViewController ()

@end

@implementation OGKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    // SKScene * scene = [OGKMenuScene sceneWithSize:skView.bounds.size];
    SKScene * scene = [OGKMapScene sceneWithSize:skView.bounds.size];
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
