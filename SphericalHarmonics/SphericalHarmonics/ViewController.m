//
//  ViewController.m
//  SphericalHarmonics
//
//  Created by asd on 03/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import "ViewController.h"
#import "SphericalHarmonics.h"
#import "PlatoPoly.h"
#import "CodesCollectionCollectionViewCell.h"



@interface ViewController () {
    
}
@end

@implementation ViewController

- (IBAction)onStepper:(id)sender {
    [c.sh setColorMap:(int)_stepper.value];
    [c addNodeSH];
}
- (IBAction)onRandom:(id)sender {
    [self randomCode];
}
- (IBAction)onList:(id)sender {
    [self selectList];
}
- (IBAction)onPlay:(id)sender {
    //    // backgroud process: update UI items until random is pressed
    //    if(self->isRunning==NO)
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
    //            self->isRunning=YES;
    //            for (; self->endThread==NO && self->nCode<N_SH_CODES; self->nCode++) {
    //                dispatch_sync(dispatch_get_main_queue(), ^{ // update UI
    //                    self->_labelCode.text=[NSString stringWithFormat:@"%08d", SphericHarmCodes[self->nCode]];
    //                    [c.sh readCode:self->nCode];
    //                    [c addNodeSH];
    //                });
    //            }
    //            self->isRunning=self->endThread=NO;
    //        });
    //    else self->endThread=YES;
}
- (IBAction)onShot:(id)sender {
    c.img= _scene.snapshot;
    // Create path.
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[[c getCode] stringByAppendingString:@".png"]];
    
    // Save image.
    [UIImagePNGRepresentation(c.img) writeToFile:filePath atomically:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self randomCode];
    
    [c setTheSceneView:_scene];
    [c setHandleTab:self scene:_scene selector:@selector(handleTap:)];
    [self setLabel];
}

-(void)randomCode {
    [c.sh randomCode];
    [self displaySH];
    [self setLabel];
}
-(void)showMessage: (NSString*)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)displaySH {
    if(c.sh->multiThread)
        dispatch_group_notify(c.sh->group, c.sh->queue, ^ { // wait complete all threads
            [c.sh createNode];
            [c addNodeSH];
        });
    else [c addNodeSH];
}
-(void)selectList {
    [_codesCollectionView setHidden:NO];
    [_scene setHidden:YES];
    [_toolBar setHidden:YES];
    if([c imageGenerationCompleted])  [_labelCode setHidden:YES];
    else _labelCode.text=[NSString stringWithFormat:@"generated %d of %d", [c getnImages], N_SH_CODES];
    [_codesCollectionView reloadData];
}


- (void) handleTap:(UIGestureRecognizer*)gestureRecognize {
    NSArray *hitResults = [_scene hitTest:[gestureRecognize locationInView:_scene] options:nil];// check what nodes are tapped
    
    // check that we clicked on at least one object
    if([hitResults count]==0){ // Out -> generate random sh
        [self randomCode];
    } else { // IN -> select from table
        [self selectList];
    }
}

-(void)setLabel {
    _labelCode.text = [c getCode];
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return N_SH_CODES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"codeCell";
    
    CodesCollectionCollectionViewCell *_cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // populate the cell
    int ix=(int)indexPath.row;
    _cell.lCode.text = [NSString stringWithFormat:@"%08d", SphericHarmCodes[ix]];
    if (ix<[c.imgs count])
        _cell.imageCell.image = c.imgs[ix];
    else
        _cell.imageCell.image = nil; // still not generated
    
    return _cell;
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [c.sh readCode:(int)indexPath.row];
    
    [self displaySH];
    
    [_codesCollectionView setHidden:YES];
    [_scene setHidden:NO];
    [_toolBar setHidden:NO];
    [_labelCode setHidden:NO];
    [self setLabel];
}


@end
