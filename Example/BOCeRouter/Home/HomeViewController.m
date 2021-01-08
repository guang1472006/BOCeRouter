//
//  HomeViewController.m
//  BOCeRouter
//
//  Created by boce on 2021/1/8.
//

#import "HomeViewController.h"
#import <BOCeRouter/BOCeRouter.h>
#import "HomeSecondViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

+(void)load{
    
    [BOCeRouterNavigation autoHidesBottomBarWhenPushed:YES];
    
    [BOCeRouter registerRouteURL:@"http://www.baidu.com?s=100" handler:^(NSDictionary * _Nullable routerParameters) {
        NSLog(@"routerParameters=%@",routerParameters);
        HomeSecondViewController *vc=[[HomeSecondViewController alloc]init];
        vc.param=routerParameters;
        [BOCeRouterNavigation  pushViewController:vc animated:YES];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"Home";
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnClick:)];
}

-(void)btnClick:(UIButton *)button{
    if ([BOCeRouter canRouteURL:@"http://www.baidu.com"]) {
        [BOCeRouter routeURL:@"http://www.baidu.com?s=100" withParameters:@{@"parameters":@"12"}];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
