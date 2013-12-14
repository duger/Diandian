//
//  TableBaseViewController.m
//  Helper
//
//  Created by zhanghao on 13-1-1.
//  Copyright (c) 2013年 zhanghao. All rights reserved.
//

#import "TableBaseViewController.h"
#import "HelperConnection.h"

@interface TableBaseViewController ()

@end

@implementation TableBaseViewController
@synthesize tableView = _tableView;
@synthesize dataArray = _dataArray;
@synthesize helperConnection = _helperConnection;
- (id)init
{
  self = [super init];
  if (self) {
    self.dataArray = [NSMutableArray array];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self initTableView];

}
- (void)initTableView:(CGRect)rect
{
  [self initTableViewWithRect:rect];
  
}
- (void)initTableView
{
  [self initTableViewWithRect:CGRectMake(self.view.bounds.origin.x,
                                         self.view.bounds.origin.y,
                                         self.view.frame.size.width,
                                         self.view.bounds.size.height - 44)];
}

//初始化tableview，如果需要的样式,frame,父类不满足，子类重写此方法
- (void)initTableViewWithRect:(CGRect)rect
{
  self.tableView = [[UITableView alloc] initWithFrame:rect  style:UITableViewStylePlain];
    self.tableView.tag=10000;
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.tableView.backgroundColor = [UIColor clearColor];
  [self.view addSubview: _tableView];
  [_tableView release];
  
    //创建下拉刷新view
  [self createHeaderView];
}

#pragma mark
#pragma methods for creating and removing the header view
//创建下拉刷新view
-(void)createHeaderView
{
  if (_refreshHeaderView && [_refreshHeaderView superview])
  {
    [_refreshHeaderView removeFromSuperview];
  }
  _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                        CGRectMake(0.0f, 0.0f - self.view.bounds.size.height,
                                   self.view.frame.size.width, self.view.bounds.size.height)];
  _refreshHeaderView.delegate = self;
  [_tableView addSubview:_refreshHeaderView];
  [_refreshHeaderView refreshLastUpdatedDate];
}

//移除下拉刷新view
-(void)removeHeaderView
{
  if (_refreshHeaderView && [_refreshHeaderView superview])
  {
    [_refreshHeaderView removeFromSuperview];
  }
  _refreshHeaderView = nil;
}

//重设加载更多位置
-(void)setFooterView
{
  CGFloat height = MAX(_tableView.contentSize.height, _tableView.frame.size.height);
  if (_refreshFooterView && [_refreshFooterView superview])
  {
    _refreshFooterView.frame = CGRectMake(0.0f,
                                          height,
                                          _tableView.frame.size.width,
                                          self.view.bounds.size.height);
  }
  else
  {
    _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                          CGRectMake(0.0f,
                                     height,
                                     _tableView.frame.size.width,
                                     self.view.bounds.size.height)];
    _refreshFooterView.delegate = self;
    [_tableView addSubview:_refreshFooterView];
  }
  
  if (_refreshFooterView)
  {
    [_refreshFooterView refreshLastUpdatedDate];
  }
}

//删除加载更多view
-(void)removeFooterView
{
  if (_refreshFooterView && [_refreshFooterView superview])
  {
    [_refreshFooterView removeFromSuperview];
  }
  _refreshFooterView = nil;
}


#pragma mark-
#pragma mark force to show the refresh headerView
//代码触发刷新
-(void)showRefreshHeader:(BOOL)animated
{
  if (animated)
  {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 0.0f, 0.0f);
    [self.tableView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
    [UIView commitAnimations];
  }
  else
  {
    self.tableView.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 0.0f, 0.0f);
    [self.tableView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
  }
  
  [_refreshHeaderView setState:EGOOPullRefreshLoading];
  [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
  
}

#pragma mark -
#pragma mark overide UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:CellIdentifier] autorelease];
  }
  cell.textLabel.text = @"";
  return cell;
}

#pragma mark -
#pragma mark data reloading methods that must be overide by the subclass
//根据刷新类型，是看是下拉还是上拉
-(void)beginToReloadData:(EGORefreshPos)aRefreshPos
{
  //  should be calling your tableviews data source model to reload
  _reloading = YES;
  if (aRefreshPos ==  EGORefreshHeader)
  {
    _isReloadData = YES;
    
    [self getNewData];
  }
  else if (aRefreshPos == EGORefreshFooter)
  {
    _isLoadMoreData = YES;
    [self loadMoreData];
  }
  // overide, the actual loading data operation is done in the subclass
}

#pragma mark -
#pragma mark method that should be called when the refreshing is finished
//完成刷新，让上拉，或者下拉弹回去
- (void)finishReloadingData
{
  
  //  model should call this when its done loading
  _reloading = NO;
  
  if (_refreshHeaderView) {
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    _isReloadData = NO;
  }
  
  if (_refreshFooterView) {
    [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    [self setFooterView];
    _isLoadMoreData = NO;
  }
  
  // overide, the actula reloading tableView operation and reseting position operation is done in the subclass
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
  if (_refreshHeaderView) {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
  }
  
  if (_refreshFooterView) {
    [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
  if (_refreshHeaderView) {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
  }
  
  if (_refreshFooterView) {
    [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
  }
}


#pragma mark -
#pragma mark EGORefreshTableDelegate Methods
//EGO 触发下拉或上拉刷新
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
  
  [self beginToReloadData:aRefreshPos];
  
}
//看看delegate是否正在刷新
- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
  
  return _reloading; // should return if data source model is reloading
  
}


// if we don't realize this method, it won't display the refresh timestamp
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view{
  
  return [NSDate date]; // should return date data source was last changed
  
}  

//获取新数据  todo by subClass
- (void)getNewData
{
  
}

//获取更多数据  todo by subClass
- (void)loadMoreData
{
  
}

//获取数据从哪到哪 todo by subClass
- (void)loadDataByStart:(NSInteger)start limit:(NSInteger)limit
{
  
}

- (void)dealloc
{
  [_helperConnection release];
  [_tableView release];
  [_dataArray release];
  [super dealloc];
}

@end
