//
//  ViewController.m
//  后台下载和本地通知
//
//  Created by TungKay on 16/3/11.
//  Copyright © 2016年 TungKay. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate>

@property (nonatomic,strong) NSURLSession *session;

@property (nonatomic,strong) NSURLSessionDownloadTask *task;

@property (nonatomic,strong) NSData *data;


@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadBackground
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"download"];
    //系统根据当前性能自动处理后台任务的优先级
    config.discretionary = YES;
    
    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    // http://farm3.staticflickr.com/2846/9823925914_78cd653ac9_b_d.jpg
    
    // http://dlsw.baidu.com/sw-search-sp/soft/3f/12289/Weibo.4.5.3.37575common_wbupdate.1423811415.exe
    
   // NSURL *url = [NSURL URLWithString:@"http://farm3.staticflickr.com/2846/9823925914_78cd653ac9_b_d.jpg"];
    
    NSURL *url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/3f/12289/Weibo.4.5.3.37575common_wbupdate.1423811415.exe"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _task = [_session downloadTaskWithRequest:request];
    
    [_task resume];
}

- (void)pushLocalNotification
{
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5.0];
    //设置重复通知周期
    localNotification.repeatInterval = kCFCalendarUnitDay;
    
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    localNotification.alertBody = @"下载完成";
    
    localNotification.applicationIconBadgeNumber++;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)copyFileAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
//    NSString *toPath = [documentDirectory stringByAppendingPathComponent:@"1.jpg"];
    
    NSLog(@"document--%@",documentDirectory);
    
    NSString *toPath = [documentDirectory stringByAppendingPathComponent:@"weibo.exe"];
    
    
    
    if (![fileManager fileExistsAtPath:toPath]) {
        
        [fileManager copyItemAtPath:path toPath:toPath error:&error];
        
        if (error) {
            NSLog(@"copy error--%@",error.description);
        }
        
    }
}
- (IBAction)startAction:(UIButton *)sender {
     [self downloadBackground];
}

- (IBAction)pauseAction:(UIButton *)sender {
    
    if (!_task) {
        return;
    }
    
    [_task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        _data = resumeData;
    }];
}

- (IBAction)resumeAction:(UIButton *)sender {
    
    if (!_data) {
        return;
    }else {
        _task = [_session downloadTaskWithResumeData:_data];
        [_task resume];
    }
    
}
#pragma mark -delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"当前进度%f%%",totalBytesWritten * 1.0 / totalBytesExpectedToWrite * 100);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"file--%@,path--%@",downloadTask.description,location);
    
    [self copyFileAtPath:[location relativePath]];
    
    [self pushLocalNotification];
}



@end
