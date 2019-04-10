//
//  CollectionViewController.m
//  SphericalHarmonics
//
//  Created by asd on 04/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import "CollectionViewController.h"
#import "Common.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate=self;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return N_SH_CODES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CodesCollectionCollectionViewCell *_cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // get the track
    NSString *text = [NSString stringWithFormat:@"%08d", SphericHarmCodes[indexPath.row]];
    
    // populate the cell
    _cell.lCode.text = text;
   
    return _cell;
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [c.sh readCode:(int)indexPath.row];
    [c loadView:self name:@"animationController"];
}



@end
