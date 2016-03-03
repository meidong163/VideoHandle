//
//  ViewController.m
//  VideoHandle
//
//  Created by 没懂 on 16/2/24.
//  Copyright © 2016年 com.comelet. All rights reserved.
//

#import "MainViewController.h"
#import "MDMediaGenerateController.h"
#import "MDVideoTrimViewController.h"
#import "MDVideoCompositionVC.h"
@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSArray *ToolName;

@end

@implementation MainViewController

- (NSArray *)ToolName
{
    return @[@"视频录制",@"视频截取",@"视频合成"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview: tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 )
    {
        MDMediaGenerateController *mediaGenerateVC = [[MDMediaGenerateController alloc]init];
        [self.navigationController pushViewController:mediaGenerateVC animated:YES];
    }else if(indexPath.row == 1)
    {
        MDVideoTrimViewController *videoTrimVC = [[MDVideoTrimViewController alloc]init];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.navigationController pushViewController:videoTrimVC animated:YES];
    }else
    {
        MDVideoCompositionVC *compositionVC = [[MDVideoCompositionVC alloc]init];
        [self.navigationController pushViewController:compositionVC animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"media";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.ToolName[indexPath.row];
    return cell;
}

@end
