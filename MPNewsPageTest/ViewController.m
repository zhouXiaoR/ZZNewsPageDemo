//
//  ViewController.m
//  MPNewsPageTest
//
//  Created by 周晓瑞 on 2017/4/14.
//  Copyright © 2017年 colleny. All rights reserved.
//

#import "ViewController.h"
#import <UIView+MJExtension.h>

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface ViewController ()<UIScrollViewDelegate>

@property(nonatomic,weak)UIScrollView *titleScrollerView;
@property(nonatomic,weak)UIScrollView *contentScrollerView;
@property(nonatomic,strong)NSMutableArray *titleBtnArray;
@property(nonatomic,strong)UIButton *selectButton;

@end

@implementation ViewController

- (NSMutableArray *)titleBtnArray{
    if (_titleBtnArray == nil) {
        _titleBtnArray = [NSMutableArray array];
    }
    return _titleBtnArray;
}

- (UIScrollView *)titleScrollerView{
    if (_titleScrollerView == nil) {
        UIScrollView * titleScorllerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64,self.view.mj_w,44)];
        titleScorllerView.delegate = self;
        [self.view addSubview:titleScorllerView];
        self.titleScrollerView = titleScorllerView;
    }
    return _titleScrollerView;
}

- (UIScrollView *)contentScrollerView{
    if (_contentScrollerView == nil) {
        CGFloat ory = CGRectGetMaxY(self.titleScrollerView.frame);
        UIScrollView * contScorllerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,ory,self.view.mj_w,self.view.mj_h - ory)];
        contScorllerView.delegate= self;
        contScorllerView.backgroundColor= [UIColor grayColor];
        [self.view addSubview:contScorllerView];
        self.contentScrollerView = contScorllerView;
        
        int cout =(int)self.childViewControllers.count;
        self.contentScrollerView.contentSize = CGSizeMake(self.view.mj_w*cout,0);
        self.contentScrollerView.showsHorizontalScrollIndicator = NO;
        self.contentScrollerView.pagingEnabled = YES;
        self.contentScrollerView.bounces = NO;
    }
    return _contentScrollerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setUpChildViewController];
    
    [self setUpTitleButton];
    
}


- (void)setUpChildViewController{
    for (int i = 0; i<10; i++) {
        UIViewController * vc = [self setUpViewControllerWithTile:[NSString stringWithFormat:@"vc%d",i] color:[UIColor redColor]];
        [self addChildViewController:vc];
        if(i%2){
            vc.view.backgroundColor= [UIColor orangeColor];
        }else{
            vc.view.backgroundColor = [UIColor greenColor];
        }
    }
}



- (void)setUpTitleButton{
    int cout = (int)self.childViewControllers.count;
    CGFloat btnW = 100;
    CGFloat btnH = self.titleScrollerView.mj_h;
    for (int i=0; i<cout; i++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnW * i,0,btnW,btnH);
        btn.tag = i;
        UIViewController * vc = self.childViewControllers[i];
        [btn setTitle:vc.title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(newsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleScrollerView addSubview:btn];
        [self.titleBtnArray addObject:btn];
        if(i==0){
            [self newsBtnClick:btn];
        }
    }
    self.titleScrollerView.contentSize = CGSizeMake(btnW*cout,0);
    self.titleScrollerView.showsHorizontalScrollIndicator = NO;
}

- (void)newsBtnClick:(UIButton *)btn{
    NSInteger index = btn.tag;
    [self seletButton:index];
    
    [self setUpButtonTitleCenter:btn];
}

- (void)setUpButtonTitleCenter:(UIButton *)btn{
    CGFloat moveX = btn.center.x - 0.5 * self.view.mj_w;
    
    //左边界
    if (moveX<0) {
        moveX = 0;
    }
    
    //右边界
    CGFloat maxX = self.titleScrollerView.contentSize.width - self.view.mj_w;
    if (moveX>maxX) {
        moveX = maxX;
    }
    
    [self.titleScrollerView setContentOffset:CGPointMake(moveX, 0) animated:YES];
}

- (void)seletButton:(NSInteger)index{
    
    UIButton * btn = self.titleBtnArray[index];
    
    _selectButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     btn.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    [_selectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _selectButton = btn;
    
    [self selectOneViewController:index];
    
    CGFloat orx = self.view.mj_w * index;
    [self.contentScrollerView setContentOffset:CGPointMake(orx, 0) animated:YES];
}

-(void)selectOneViewController:(NSInteger)index{
    UIViewController *vc = self.childViewControllers[index];
    if(vc.view.superview){
        return;
    }
    
    CGFloat orx = self.view.mj_w * index;
    CGFloat h = self.view.mj_h - CGRectGetMaxY(self.titleScrollerView.frame);
    vc.view.frame = CGRectMake(orx,0, self.view.mj_w,h);
    [self.contentScrollerView addSubview:vc.view];
}

- (UIViewController *)setUpViewControllerWithTile:(NSString *)title color:(UIColor *)backColor{
    UIViewController * vc = [[UIViewController alloc]init];
    vc.title = title;
    return vc;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.contentScrollerView == scrollView) {
         NSInteger index  = scrollView.contentOffset.x / self.view.mj_w;
        UIButton * btn = self.titleBtnArray[index];
        [self setUpButtonTitleCenter:btn];
        
        UIButton *leftBtn = self.titleBtnArray[index];
        NSInteger rigIndex = index+1;
        UIButton * rightBtn;
        if(rigIndex<self.titleBtnArray.count){
            rightBtn = self.titleBtnArray[rigIndex];
        }
        
        //获得渐变左右btn，渐变大小 与颜色
        CGFloat x = scrollView.contentOffset.x / self.view.mj_w;
        CGFloat rightTransformValue= x-index;
        CGFloat leftTransformValue =  1- rightTransformValue;
      
        leftBtn.transform = CGAffineTransformMakeScale(1.0+leftTransformValue*0.3,1.0+ leftTransformValue*0.3);
        rightBtn.transform = CGAffineTransformMakeScale(1.0+rightTransformValue*0.3,1.0+ rightTransformValue*0.3);
        UIColor * leftColor = [UIColor colorWithRed:leftTransformValue green:0 blue:0 alpha:1];
        UIColor *rightColor = [UIColor colorWithRed:rightTransformValue green:0 blue:0 alpha:1];
        [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
        [rightBtn setTitleColor:rightColor forState:UIControlStateNormal];
    }else if (self.titleScrollerView == scrollView){
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.contentScrollerView == scrollView) {
        NSInteger index  = scrollView.contentOffset.x / self.view.mj_w;
          [self seletButton:index];
    }
}
@end
