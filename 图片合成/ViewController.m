//
//  ViewController.m
//  图片合成
//
//  Created by Mac1 on 2018/6/20.
//  Copyright © 2018年 Mac1. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *baseImageView;
@property (nonatomic, strong) UIImageView *watermarkImageView;
@property (nonatomic, assign) BOOL isChooseBaseImage;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGFloat originX;
@property (nonatomic, assign) CGFloat originY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"图片合成";
    
    self.baseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.5 - 60, (SCREEN_HEIGHT - NAVI_HEIGHT) * 0.5 - 60, 120, 120)];
    self.baseImageView.userInteractionEnabled = YES;
    self.baseImageView.image = [UIImage imageNamed:@"addImage"];
//    self.baseImageView.clipsToBounds = YES;
//    self.baseImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.baseImageView];
    //点击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBaseImage)];
    [self.baseImageView addGestureRecognizer:tap];
    
    self.originX = SCREEN_WIDTH * 0.5 - 60;
    self.originY = (SCREEN_HEIGHT - NAVI_HEIGHT) * 0.5 - 60;
    self.width = 120;
    self.height = 120;
    self.watermarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.originX, self.originY, self.width, self.height)];
    self.originalFrame = CGRectMake(SCREEN_WIDTH * 0.5 - 60, (SCREEN_HEIGHT - NAVI_HEIGHT) * 0.5 - 60, 120, 120);
    self.watermarkImageView.userInteractionEnabled = YES;
//    self.watermarkImageView.clipsToBounds = YES;
//    self.watermarkImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.watermarkImageView.hidden = YES;
    [self.view addSubview:self.watermarkImageView];
    //拖拽
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.watermarkImageView addGestureRecognizer:pan];
    
    for (int i=0; i<4; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.backgroundColor = [UIColor clearColor];
        [self.watermarkImageView addSubview:button];
        if (i == 0) {
            [button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.top.mas_equalTo(0);
                make.width.height.mas_equalTo(30);
            }];
        }else if (i == 1) {
            [button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.top.mas_equalTo(0);
                make.width.height.mas_equalTo(30);
            }];
        }else if (i == 2) {
            [button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.bottom.mas_equalTo(0);
                make.width.height.mas_equalTo(30);
            }];
        }else {
            [button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.mas_equalTo(0);
                make.width.height.mas_equalTo(30);
            }];
        }
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPanGesture:)];
        [button addGestureRecognizer:pan];
    }
    
    for (int j=0; j<4; j++) {
        UIView *view = [[UIView alloc] init];
        view.tag = j;
        view.backgroundColor = [UIColor clearColor];
        [self.watermarkImageView addSubview:view];
        if (j == 0) {
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.mas_equalTo(30);
                make.bottom.mas_equalTo(-30);
                make.width.mas_equalTo(30);
            }];
        }else if (j == 1) {
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(30);
                make.right.mas_equalTo(-30);
                make.height.mas_equalTo(30);
            }];
        }else if (j == 2) {
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.top.mas_equalTo(30);
                make.bottom.mas_equalTo(-30);
                make.width.mas_equalTo(30);
            }];
        }else {
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
                make.left.mas_equalTo(30);
                make.right.mas_equalTo(-30);
                make.height.mas_equalTo(30);
            }];
        }
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanGesture:)];
        [view addGestureRecognizer:pan];
    }
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStyleDone target:self action:@selector(addImage)];
    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithTitle:@"合成" style:UIBarButtonItemStyleDone target:self action:@selector(composeImage)];
    self.navigationItem.rightBarButtonItems = @[addItem, compose];
}

- (void)addBaseImage {
    self.isChooseBaseImage = YES;
    [self showAlertView];
}

- (void)buttonPanGesture:(UIPanGestureRecognizer *)panGesture {
    UIView *view = panGesture.view;
    CGPoint transport = [panGesture translationInView:view];
    if (view.tag == 0) {
        self.originX = (self.originalFrame.origin.x + transport.x) < 0 ? 0 : self.originalFrame.origin.x + transport.x;
        self.originY = (self.originalFrame.origin.y + transport.y) < 0 ? 0 : self.originalFrame.origin.y + transport.y;
        self.width = (self.originalFrame.size.width - transport.x) < 60 ? 60 : self.originX == 0 ? self.originalFrame.size.width + self.originalFrame.origin.x : self.originalFrame.size.width - transport.x;
        self.height = (self.originalFrame.size.height - transport.y) < 60 ? 60 : self.originY == 0 ? self.originalFrame.size.height + self.originalFrame.origin.y : self.originalFrame.size.height - transport.y;
    }else if(view.tag == 1) {
        self.originY = (self.originalFrame.origin.y + transport.y) < 0 ? 0 : self.originalFrame.origin.y + transport.y;
        self.width = (self.originalFrame.size.width + transport.x) < 60 ? 60 : self.originalFrame.size.width + transport.x;
        self.height = (self.originalFrame.size.height - transport.y) < 60 ? 60 : self.originY == 0 ? self.originalFrame.size.height + self.originalFrame.origin.y : self.originalFrame.size.height - transport.y;
    }else if(view.tag == 2) {
        self.width = (self.originalFrame.size.width + transport.x) < 60 ? 60 : self.originalFrame.size.width + transport.x;
        self.height = (self.originalFrame.size.height + transport.y) < 60 ? 60 : self.originalFrame.size.height + transport.y;
    }else if(view.tag == 3) {
        self.originX = (self.originalFrame.origin.x + transport.x) < 0 ? 0 : self.originalFrame.origin.x + transport.x;
        self.width = (self.originalFrame.size.width - transport.x) < 60 ? 60 : self.originX == 0 ? self.originalFrame.size.width + self.originalFrame.origin.x : self.originalFrame.size.width - transport.x;
        self.height = (self.originalFrame.size.height + transport.y) < 60 ? 60 : self.originalFrame.size.height + transport.y;
    }
    if ((self.originX + self.width) > SCREEN_WIDTH) {
        if (self.width == 60) {
            self.originX = SCREEN_WIDTH - 60;
        }else {
            self.width = SCREEN_WIDTH - self.originX;
        }
    }
    if ((self.originY + self.height) > (SCREEN_HEIGHT - NAVI_HEIGHT)) {
        if (self.height == 60) {
            self.originY = SCREEN_HEIGHT - NAVI_HEIGHT - 60;
        }else {
            self.height = SCREEN_HEIGHT - NAVI_HEIGHT - self.originY;
        }
    }
    
    self.watermarkImageView.frame = CGRectMake(self.originX, self.originY, self.width, self.height);
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        self.originalFrame = self.watermarkImageView.frame;
    }
}

- (void)viewPanGesture:(UIPanGestureRecognizer *)panGesture {
    UIView *view = panGesture.view;
    CGPoint transport = [panGesture translationInView:view];
    if (view.tag == 0) {
        self.originX = (self.originalFrame.origin.x + transport.x) < 0 ? 0 : self.originalFrame.origin.x + transport.x;
        self.width = (self.originalFrame.size.width - transport.x) < 60 ? 60 : self.originX == 0 ? self.originalFrame.size.width + self.originalFrame.origin.x : self.originalFrame.size.width - transport.x;
    }else if(view.tag == 1) {
        self.originY = (self.originalFrame.origin.y + transport.y) < 0 ? 0 : self.originalFrame.origin.y + transport.y;
        self.height = (self.originalFrame.size.height - transport.y) < 60 ? 60 : self.originY == 0 ? self.originalFrame.size.height + self.originalFrame.origin.y : self.originalFrame.size.height - transport.y;
    }else if(view.tag == 2) {
        self.width = (self.originalFrame.size.width + transport.x) < 60 ? 60 : self.originalFrame.size.width + transport.x;
    }else if(view.tag == 3) {
        self.height = (self.originalFrame.size.height + transport.y) < 60 ? 60 : self.originalFrame.size.height + transport.y;
    }
    if ((self.originX + self.width) > SCREEN_WIDTH) {
        if (self.width == 60) {
            self.originX = SCREEN_WIDTH - 60;
        }else {
            self.width = SCREEN_WIDTH - self.originX;
        }
    }
    if ((self.originY + self.height) > (SCREEN_HEIGHT - NAVI_HEIGHT)) {
        if (self.height == 60) {
            self.originY = SCREEN_HEIGHT - NAVI_HEIGHT - 60;
        }else {
            self.height = SCREEN_HEIGHT - NAVI_HEIGHT - self.originY;
        }
    }
    
    self.watermarkImageView.frame = CGRectMake(self.originX, self.originY, self.width, self.height);
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        self.originalFrame = self.watermarkImageView.frame;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    //返回在横坐标上、纵坐标上拖动了多少像素
    CGPoint transport = [panGesture translationInView:self.view];
    CGFloat centerX = panGesture.view.center.x + transport.x;
    CGFloat centerY = panGesture.view.center.y + transport.y;
    CGFloat viewHalfH = panGesture.view.frame.size.height / 2;
    CGFloat viewhalfW = panGesture.view.frame.size.width / 2;
    //确定特殊的centerY
    if (centerY - viewHalfH < 0 ) {
        centerY = viewHalfH;
    }
    if (centerY + viewHalfH > SCREEN_HEIGHT - NAVI_HEIGHT) {
        centerY = SCREEN_HEIGHT - NAVI_HEIGHT - viewHalfH;
    }
    //确定特殊的centerX
    if (centerX - viewhalfW < 0){
        centerX = viewhalfW;
    }
    if (centerX + viewhalfW > SCREEN_WIDTH){
        centerX = SCREEN_WIDTH - viewhalfW;
    }
    panGesture.view.center = CGPointMake(centerX, centerY);
    self.originX = self.watermarkImageView.frame.origin.x;
    self.originY = self.watermarkImageView.frame.origin.y;
    self.width = self.watermarkImageView.frame.size.width;
    self.height = self.watermarkImageView.frame.size.height;
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        self.originalFrame = self.watermarkImageView.frame;
    }
    //拖动完之后，每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
    [panGesture setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)addImage {
    self.isChooseBaseImage = NO;
    [self showAlertView];
}

- (void)showAlertView {
    // 创建UIImagePickerController实例
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    // 设置代理
    imagePickerController.delegate = self;
    // 是否允许编辑（默认为NO）
//    imagePickerController.allowsEditing = YES;
    // 创建一个警告控制器
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 设置警告响应事件
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 设置照片来源为相机
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 设置进入相机时使用前置或后置摄像头
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        // 展示选取照片控制器
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    UIAlertAction *photosAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 添加警告按钮
        [alert addAction:cameraAction];
    }
    [alert addAction:photosAction];
    [alert addAction:cancelAction];
    // 展示警告控制器
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 选取完图片后跳转回原控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    /* 此处参数 info 是一个字典，下面是字典中的键值 （从相机获取的图片和相册获取的图片时，两者的info值不尽相同）
     * UIImagePickerControllerMediaType; // 媒体类型
     * UIImagePickerControllerOriginalImage; // 原始图片
     * UIImagePickerControllerEditedImage; // 裁剪后图片
     * UIImagePickerControllerCropRect; // 图片裁剪区域（CGRect）
     * UIImagePickerControllerMediaURL; // 媒体的URL
     * UIImagePickerControllerReferenceURL // 原件的URL
     * UIImagePickerControllerMediaMetadata // 当数据来源是相机时，此值才有效
     */
    // 从info中将图片取出，并加载到imageView当中
    if ([picker allowsEditing]) {
        if (self.isChooseBaseImage) {
            self.baseImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVI_HEIGHT);
            self.baseImageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
            //剪裁图片
//            [self cuttingImageFromImage:self.baseImageView.image inRect:CGRectMake(0, 0, self.baseImageView.image.size.width, self.baseImageView.image.size.height)];
        }else {
            self.watermarkImageView.hidden = NO;
            self.watermarkImageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
        }
    }else {
        if (self.isChooseBaseImage) {
            self.baseImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVI_HEIGHT);
            self.baseImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }else {
            self.watermarkImageView.hidden = NO;
            self.watermarkImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//裁剪
- (UIImage *)cuttingImageFromImage:(UIImage *)image inRect:(CGRect)rect{
    //将UIImage转换成CGImageRef
    CGImageRef sourceImageRef = [image CGImage];
    //按照给定的矩形区域进行剪裁
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    //将CGImageRef转换成UIImage
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    //将图片保存到相册
    UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil);
    //调用这个方法 否则会造成内存泄漏
    CGImageRelease(newImageRef);
    //返回剪裁后的图片
    return newImage;
}

- (void)composeImage {
    CGFloat scaleW = self.baseImageView.image.size.width / SCREEN_WIDTH;
    CGFloat scaleH = self.baseImageView.image.size.height / SCREEN_HEIGHT;
    
    UIImage *image = [UIImageView WaterImageWithImage:self.baseImageView.image text:nil textPoint:CGPointZero attributedString:nil];
    image = [UIImageView WaterImageWithImage:image waterImage:self.watermarkImageView.image waterImageRect:CGRectMake(self.watermarkImageView.frame.origin.x * scaleW, self.watermarkImageView.frame.origin.y * scaleH, self.watermarkImageView.frame.size.width * scaleW, self.watermarkImageView.frame.size.height * scaleW)];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
//    UIGraphicsBeginImageContext(self.baseImageView.image.size);
//    [self.baseImageView.image drawInRect:CGRectMake(0, 0, self.baseImageView.image.size.width, self.baseImageView.image.size.height)];
//    [self.watermarkImageView.image drawInRect:CGRectMake(self.watermarkImageView.frame.origin.x * scaleW, self.watermarkImageView.frame.origin.y * scaleH, self.watermarkImageView.frame.size.width * scaleW, self.watermarkImageView.frame.size.height * scaleW)];
//    CGImageRef NewMergeImg = CGImageCreateWithImageInRect(UIGraphicsGetImageFromCurrentImageContext().CGImage,
//                                                          CGRectMake(0, 0, self.baseImageView.image.size.width, self.baseImageView.image.size.height));
//    UIImageWriteToSavedPhotosAlbum([UIImage imageWithCGImage:NewMergeImg], nil, nil, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
