//
//  TableBaseViewController.h
//  Helper
//
//  Created by zhanghao on 13-1-1.
//  Copyright (c) 2013年 zhanghao. All rights reserved.
//


#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@class HelperConnection;
@interface TableBaseViewController : UIViewController<
EGORefreshTableDelegate,
UITableViewDataSource,
UITableViewDelegate>
{
  EGORefreshTableHeaderView * _refreshHeaderView;
  EGORefreshTableFooterView * _refreshFooterView;
  HelperConnection          * _helperConnection;
  UITableView               * _tableView;
  NSMutableArray            * _dataArray;
  BOOL                        _reloading;         //是否正在loading
  BOOL                        _isReloadData;      //是否是下拉刷新数据
  BOOL                        _isLoadMoreData;    //是否是载入更多
  BOOL                        _isHaveMoreData;    //是否还有更多数据,决定是否有更多view
  NSInteger                   _pageNum;
  
}
@property (nonatomic,retain)UITableView         * tableView;
@property (nonatomic,retain)NSMutableArray      * dataArray;
@property (nonatomic,retain)HelperConnection    * helperConnection;

-(void)createHeaderView;
-(void)removeHeaderView;

-(void)setFooterView;
-(void)removeFooterView;

- (void)finishReloadingData;
-(void)beginToReloadData:(EGORefreshPos)aRefreshPos;


-(void)showRefreshHeader:(BOOL)animated;//代码出发刷新

- (void)getNewData;
- (void)loadMoreData;
- (void)loadDataByStart:(NSInteger)start
                  limit:(NSInteger)limit;



@end
