//
//  ViewController.h
//  SphericalHarmonics
//
//  Created by asd on 03/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#include "Common.h"

@interface ViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet SCNView *scene;
@property (weak, nonatomic) IBOutlet UICollectionView *codesCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *labelCode;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

