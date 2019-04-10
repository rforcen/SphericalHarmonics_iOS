//
//  Common.m
//  SphericalHarmonics
//
//  Created by asd on 04/10/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#import "Common.h"
#import "SCNUtils.h"

@implementation Common 

+(id)init {
    Common *common=[[super alloc]init];
    
    common.sh=[SphericalHarmonics init];
    common.imgs=[NSMutableArray array];
    common.myscene = [SCNScene scene]; // Create an empty scene
    
    [Common randomize];
    [common createAnimation];
    
    common.nCPU=[[NSProcessInfo processInfo] processorCount]; // get number of processors for MThreading
    return common;
}

+(void) randomize { srand((unsigned)time(NULL)); }
+(float) rnd :(float)range {  return (float)(range * rand())/RAND_MAX; }

-(void)loadView: (UIViewController*)fromVC name:(NSString*)name {
    UIViewController *toVC=[fromVC.storyboard instantiateViewControllerWithIdentifier:name];
    [fromVC presentViewController:toVC animated:YES completion:nil];
}

-(void)addNodeSH {
    SCNNode*root = _myscene.rootNode;
    [_shNode removeFromParentNode]; // remove last from root
    [root addChildNode:_shNode=_sh->node]; // keep node for prev. deletion
}
-(NSString*)getCode {
    return [NSString stringWithCString:_sh->code encoding:NSASCIIStringEncoding];
}
-(void)createAnimation {
    SCNNode*root=_myscene.rootNode; // w/camera & light
    
    [root addChildNode:[SCNUtils createCamera:9]];
    [root addChildNode:[SCNUtils createAmbientLight]];
    [root addChildNode:[SCNUtils createDiffuseLightWithPosition:SCNVector3Make(-30, 30, 50)]];
}
-(void)setTheSceneView : (SCNView*)inScene {
    [self addNodeSH];
    
    _sceneView=inScene;
    inScene.scene = _myscene; // and assign created scene
    inScene.allowsCameraControl = YES; // allows the user to manipulate the camera (move scene)
    inScene.backgroundColor = [UIColor clearColor]; // configure the view
    inScene.showsStatistics = YES;// show statistics such as fps and timing information
}

-(void)setHandleTab: (NSObject*)caller scene:(SCNView*)inScene  selector:(SEL)selector {
    // add a tap gesture recognizer
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:[[UITapGestureRecognizer alloc] initWithTarget:caller action:selector]];
    [gestureRecognizers addObjectsFromArray:inScene.gestureRecognizers];
    inScene.gestureRecognizers = gestureRecognizers;
}
-(void)generateImages {
    NSString *thumbsPath=@"/SHTHN";
    const int thSize=128;
    
    // Create path for thumbs
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:thumbsPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) // exists?
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder if ! exists
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        
        Common *ct=[Common init];
        SCNView*scnv=[[SCNView alloc] initWithFrame:CGRectMake(0, 0, thSize, thSize)];
        [ct setTheSceneView:scnv];
        
        for (int nCode=0;  nCode<N_SH_CODES; nCode++) {
            
            NSString *filePath=[NSString stringWithFormat:@"%@/%@.png",dataPath, [ct.sh getCode:nCode]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // th exists? no:create, yes:read
                    [ct.sh readCode:nCode]; // generate sh
                    [ct addNodeSH];
                    self->_imgs[nCode] = ct->_sceneView.snapshot; // copy image to self not ct
                    [UIImagePNGRepresentation(self->_imgs[nCode]) writeToFile:filePath atomically:YES]; // Save image.
                } else {
                    self->_imgs[nCode] = [UIImage imageWithContentsOfFile:filePath];
                }
            });
        }
        
        [ct.sh freeMesh];
    });
}
-(int) getnImages {
    return (int)[_imgs count];
}
-(BOOL)imageGenerationCompleted {
    return [_imgs count]==N_SH_CODES;
}
@end

Common*c; // the common instance
