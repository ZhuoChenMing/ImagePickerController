//
//  PMAlbumViewController.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "PMAlbumViewController.h"
#import "PMTableViewCell.h"
#import "PMPhotoPickerController.h"
#import "PMDataManager.h"

@interface PMAlbumViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *albumArray;

@end

@implementation PMAlbumViewController

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
    PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
    [[PMDataManager manager] getAllAlbums:navigation.canPickVideo completion:^(NSArray<PMAlbumInfoModel *> *models) {
        self.albumArray = [NSMutableArray arrayWithArray:models];
        [self createTableView];
    }];
}

- (void)createTableView {
    CGFloat top = 44;
    if (iOS7Later) {
        top += 20;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - top) style:UITableViewStylePlain];
    self.tableView.rowHeight = 70;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[PMTableViewCell class] forCellReuseIdentifier:@"ListCell"];
    [self.view addSubview:_tableView];
}

#pragma mark - Click Event
- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
    if ([navigation.pickerDelegate respondsToSelector:@selector(navigationControllerDidCancel:)]) {
        [navigation.pickerDelegate navigationControllerDidCancel:navigation];
    }
    if (navigation.didCancelHandle) {
        navigation.didCancelHandle();
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
    PMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
    cell.model = _albumArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PMPhotoPickerController *photoPickerVc = [[PMPhotoPickerController alloc] init];
    photoPickerVc.model = _albumArray[indexPath.row];
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
