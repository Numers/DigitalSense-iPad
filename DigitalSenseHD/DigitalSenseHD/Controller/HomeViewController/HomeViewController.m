//
//  HomeViewController.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/10.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "HomeViewController.h"
#import "SmellView.h"
#import "SmellFakeView.h"
#import "GraduatedLineView.h"
#import "Smell.h"

#import "CustomLewReorderableLayout.h"
#import "ScriptCommand.h"

#import "SpaceHomeCollectionViewCell.h"
#import "VirtualHomeCollectionViewCell.h"
#import "RealHomeCollectionViewCell.h"

#import "CollectionViewOperationManager.h"

#define WidthPerSecond 40.0f
#define SpaceCellIdentify @"SpaceHomeCellIdentify"
#define VirtualCellIdentify @"VirtualHomeCellIdentify"
#define RealCellIdentify @"RealHomeCellIdentify"
@interface HomeViewController ()<SmellViewProtocol,CustomLewReorderableLayoutDataSource,CustomLewReorderableLayoutDelegate>
{
    NSArray *smellList;
    
    NSMutableArray *originCommandList;
    NSMutableArray *commandList;
    SmellFakeView *smellFakeView;
    
    GraduatedLineView *lineView;
    
    CollectionViewOperationManager *operationManager;
}

@property(nonatomic, strong) IBOutlet UICollectionView *collectionView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CustomLewReorderableLayout *layout = (CustomLewReorderableLayout *)[_collectionView collectionViewLayout];
    layout.delegate = self;
    layout.dataSource = self;
    
    [_collectionView setBackgroundColor:[UIColor clearColor]];
//    [_collectionView setBackgroundView:[UIView new]];
    lineView = [[GraduatedLineView alloc] init];
    [_collectionView addSubview:lineView];
    [_collectionView sendSubviewToBack:lineView];
    
    [_collectionView registerClass:[SpaceHomeCollectionViewCell class] forCellWithReuseIdentifier:SpaceCellIdentify];
    [_collectionView registerClass:[VirtualHomeCollectionViewCell class] forCellWithReuseIdentifier:VirtualCellIdentify];
    [_collectionView registerClass:[RealHomeCollectionViewCell class] forCellWithReuseIdentifier:RealCellIdentify];
    
    Smell *smell1 = [[Smell alloc] init];
    smell1.smellRFID = @"00000001";
    smell1.smellName = @"香蕉";
    smell1.smellImage = @"FruitDefaultImage";
    smell1.smellColor = @"#037F00";
    
    Smell *smell2 = [[Smell alloc] init];
    smell2.smellRFID = @"00000002";
    smell2.smellName = @"苹果";
    smell2.smellImage = @"FruitDefaultImage";
    smell2.smellColor = @"#000000";
    
    Smell *smell3 = [[Smell alloc] init];
    smell3.smellRFID = @"00000003";
    smell3.smellName = @"梨";
    smell3.smellImage = @"FruitDefaultImage";
    smell3.smellColor = @"#000000";
    
    Smell *smell4 = [[Smell alloc] init];
    smell4.smellRFID = @"00000004";
    smell4.smellName = @"草莓";
    smell4.smellImage = @"FruitDefaultImage";
    smell4.smellColor = @"#000000";
    
    Smell *smell5 = [[Smell alloc] init];
    smell5.smellRFID = @"00000005";
    smell5.smellName = @"菠萝";
    smell5.smellImage = @"FruitDefaultImage";
    smell5.smellColor = @"#000000";
    
    Smell *smell6 = [[Smell alloc] init];
    smell6.smellRFID = @"00000006";
    smell6.smellName = @"公路";
    smell6.smellImage = @"FruitDefaultImage";
    smell6.smellColor = @"#000000";
    
    Smell *smell7 = [[Smell alloc] init];
    smell7.smellRFID = @"00000007";
    smell7.smellName = @"黄瓜";
    smell7.smellImage = @"FruitDefaultImage";
    smell7.smellColor = @"#000000";
    
    Smell *smell8 = [[Smell alloc] init];
    smell8.smellRFID = @"00000008";
    smell8.smellName = @"葡萄"; 
    smell8.smellImage = @"FruitDefaultImage";
    smell8.smellColor = @"#000000";
    smellList = @[smell1,smell2,smell3,smell4,smell5,smell6,smell7,smell8];
    
    NSInteger i = 1;
    for (Smell *s in smellList) {
        SmellView *sv = [self.view viewWithTag:i];
        sv.delegate = self;
        [sv setSmell:s];
        i++;
    }
    
    commandList = [NSMutableArray array];
    for (NSInteger i = 0; i < 60; i++) {
        ScriptCommand *command = [[ScriptCommand alloc] init];
        command.startRelativeTime = i;
        command.duration = 1;
        command.smellName = @"间隔";
        command.type = SpaceCommand;
        command.power = (arc4random() % 100) / 100.0f;
        [commandList addObject:command];
    }
    
    originCommandList = [commandList copy];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(smellFakeViewCenterChanged:) name:FakeViewCenterChangedNotify object:nil];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [lineView setCenter:CGPointMake((lineView.frame.size.width - 30) / 2.0f, _collectionView.frame.size.height - lineView.frame.size.height / 2)];
    [_collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark privateFunction
-(void)changeVirtualCommandToRealCommand
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type == %d",VirtualCommand];
    NSArray *filterArr = [commandList filteredArrayUsingPredicate:predicate];
    if (filterArr) {
        for (ScriptCommand *command in filterArr) {
            NSInteger index = [commandList indexOfObject:command];
            command.type = RealCommand;
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        }
    }
}

#pragma -mark notification
-(void)smellFakeViewCenterChanged:(NSNotification *)notify
{
    NSDictionary *dic = [notify userInfo];
    if (dic) {
        CGFloat centerX = [[dic objectForKey:@"centerX"] floatValue];
        CGFloat centerY = [[dic objectForKey:@"centerY"] floatValue];
        if (centerX > 0 || centerY > 0) {
            CGPoint backCenter = [_collectionView convertPoint:CGPointMake(centerX, centerY) toView:[UIApplication sharedApplication].keyWindow];
            [smellFakeView setToBackViewCenter:backCenter];
            
            if (operationManager) {
                CustomLewReorderableLayout *layout = (CustomLewReorderableLayout *)[self.collectionView collectionViewLayout];
                [layout setCellFakeIndexPath:operationManager.insertIndexPath];
            }
        }else{
            operationManager = nil;
        }
    }
}

#pragma -mark UICollectionViewDelegate And DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return commandList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScriptCommand *command = [commandList objectAtIndex:indexPath.item];
    HomeCollectionViewCell *cell = nil;
    switch (command.type) {
        case SpaceCommand:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:SpaceCellIdentify forIndexPath:indexPath];
            [cell setupWithScriptCommand:command];
            break;
        }
        case VirtualCommand:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:VirtualCellIdentify forIndexPath:indexPath];
            [cell setupWithScriptCommand:command];
            break;
        }
        case RealCommand:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:RealCellIdentify forIndexPath:indexPath];
            [cell setupWithScriptCommand:command];
            break;
        }
        default:
            break;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScriptCommand *command = [commandList objectAtIndex:indexPath.item];
    CGFloat width = command.duration * WidthPerSecond;
    CGFloat height = collectionView.frame.size.height;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.item > toIndexPath.item) {
        if (operationManager) {
            [operationManager moveLeftOperation:toIndexPath];
        }
    }else{
        if (operationManager) {
            [operationManager moveRightOperation:toIndexPath];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath{

}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)collectionView:(UICollectionView *)collectionView TouchLocation:(CGPoint)location didEndTouch:(void (^)(BOOL isPushBack))completion
{
    if ([collectionView pointInside:location withEvent:nil]) {
        completion(YES);
        [self changeVirtualCommandToRealCommand];
    }else{
        CGPoint locationOnScreen = [collectionView convertPoint:location toView:self.view];
        completion(NO);
    }
}

-(void)collectionView:(UICollectionView *)collectionView PanLocation:(CGPoint)location PanTranslation:(CGPoint)translation didChanged:(void (^)(void))completion{
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:location];
    NSInteger panIndex = translation.x / WidthPerSecond;
    if (panIndex > 0) {
        
    }
    completion();
}

-(void)collectionView:(UICollectionView *)collectionView PanLocation:(CGPoint)location PanTranslation:(CGPoint)translation didMoveout:(void (^)(void))completion{
    completion();
}

-(void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout longTouchCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    smellFakeView = [[SmellFakeView alloc] initWithView:cell];
    smellFakeView.center = [self.collectionView convertPoint:cell.center toView:self.view];
    smellFakeView.originalCenter = smellFakeView.center;
    [self.view addSubview:smellFakeView];
    CustomLewReorderableLayout *layout = (CustomLewReorderableLayout *)collectionViewLayout;
    [layout setCellFakeViewOnScreen:smellFakeView];
    [smellFakeView pushFowardViewWithScale:1.0 completion:^(BOOL isFinished) {
        [collectionView performBatchUpdates:^{
            ScriptCommand *command = [commandList objectAtIndex:indexPath.item];
            command.type = VirtualCommand;
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } completion:^(BOOL finished) {
        
        }];
        
        operationManager = [[CollectionViewOperationManager alloc] initWithCommandArray:commandList WithInsertIndexPath:indexPath WithInsertSmell:nil];
        operationManager.collectionView = self.collectionView;
    }];
}
#pragma -mark SmellViewProtocol
-(void)longTouchWithTag:(NSInteger)tag
{
    Smell *smell = [smellList objectAtIndex:tag - 1];
    
    SmellView *sv = [self.view viewWithTag:tag];
    smellFakeView = [[SmellFakeView alloc] initWithView:sv];
    smellFakeView.smell = smell;
    smellFakeView.originalCenter = sv.center;
    [self.view addSubview:smellFakeView];
    [smellFakeView pushFowardViewWithScale:1.1 completion:^(BOOL isFinished) {
        
    }];
}

-(void)longTouchEnded
{
    if (smellFakeView) {
        operationManager = nil;
        [smellFakeView pushBackView:^(BOOL isFinished) {
            [smellFakeView removeFromSuperview];
            smellFakeView = nil;
            
            [self changeVirtualCommandToRealCommand];
            
            originCommandList = [commandList copy];
        }];
    }
}

-(void)panLocationChanged:(CGPoint)translation
{
    @synchronized (self) {
        if (smellFakeView) {
            CGPoint center = smellFakeView.center;
            center.x += translation.x;
            center.y += translation.y;
            smellFakeView.center = center;
            
            CGPoint pointInCollectionView = [self.view convertPoint:smellFakeView.center toView:_collectionView];
            if ([self.collectionView pointInside:pointInCollectionView withEvent:nil]) {
                NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pointInCollectionView];
                NSLog(@"%ld",indexPath.item);
                
                if (operationManager == nil) {
                    operationManager = [[CollectionViewOperationManager alloc] initWithCommandArray:commandList WithInsertIndexPath:indexPath WithInsertSmell:smellFakeView.smell];
                    operationManager.collectionView = self.collectionView;
                    [operationManager insertOperation:indexPath];
                }else{
                    if (smellFakeView.center.x < smellFakeView.toBackViewCenter.x) {
                        if (operationManager) {
                            [operationManager moveLeftOperation:indexPath];
                        }
                    }else if (smellFakeView.center.x > smellFakeView.toBackViewCenter.x){
                        if (operationManager) {
                            [operationManager moveRightOperation:indexPath];
                        }
                    }
                }
                
            }else{
                if (operationManager) {
                    [smellFakeView setToBackViewCenter:smellFakeView.originalCenter];
                    operationManager = nil;
                    commandList = [NSMutableArray arrayWithArray:[originCommandList copy]];
                    [_collectionView reloadData];
                }
            }
        }
    }
}

-(void)panEnded
{
    
}
@end
