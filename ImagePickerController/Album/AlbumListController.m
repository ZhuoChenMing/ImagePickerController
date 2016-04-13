//
//  AlbumListController.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "AlbumListController.h"
#import "AlbumListTableViewCell.h"
#import "PhotoPickerController.h"
#import "AlbumDataHandle.h"

@interface AlbumListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *albumArray;

@end

@implementation AlbumListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self configTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_albumArray) {
        return;
    }
    [self configTableView];
}

- (void)configTableView {
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
    [[AlbumDataHandle manager] getAllAlbums:navigation.allowPickingVideo completion:^(NSArray<AlbumDataModel *> *models) {
        _albumArray = [NSMutableArray arrayWithArray:models];
        
        CGFloat top = 44;
        if (iOS7Later) {
            top += 20;
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - top) style:UITableViewStylePlain];
        _tableView.rowHeight = 70;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[AlbumListTableViewCell class] forCellReuseIdentifier:@"ListCell"];
        [self.view addSubview:_tableView];
    }];
}

#pragma mark - Click Event
- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
    if ([navigation.pickerDelegate respondsToSelector:@selector(albumNavigationControllerDidCancel:)]) {
        [navigation.pickerDelegate albumNavigationControllerDidCancel:navigation];
    }
    if (navigation.albumNavigationControllerDidCancelHandle) {
        navigation.albumNavigationControllerDidCancelHandle();
    }
}

#pragma mark - UITableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AlbumListCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
    cell.model = _albumArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoPickerController *photoPickerVc = [[PhotoPickerController alloc] init];
    photoPickerVc.model = _albumArray[indexPath.row];
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
