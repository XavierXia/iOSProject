//
//  MTViewController.m
//  Documents
//
//  Created by Bart Jacobs on 23/02/13.
//  Copyright (c) 2013 Mobile Tuts. All rights reserved.
//

#import "MTViewController.h"
#import "AFNetworking.h"

@interface MTViewController ()

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;


@end

@implementation MTViewController
//@synthesize filePath;

#pragma mark -
#pragma mark View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark -
#pragma mark Actions
- (IBAction)previewDocument:(id)sender {
//打开本地pdf文件
/*    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"pdf"];

//下载网络pdf文件
//    NSString *urlpdf = @"https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/ProgrammingWithObjectiveC.pdf";
//    NSString *urlpdf = @"http://192.168.0.81/1.pdf";
//    NSString *urlpdf = @"http://192.168.0.81/2.pdf";
    //NSURL *URL = [NSURL URLWithString:[urlpdf stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
 //   NSURL *URL = [NSURL fileURLWithPath:[urlpdf stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"preview url:%@", URL);
    if (URL) {
        // Initialize Document Interaction Controller
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        
        // Configure Document Interaction Controller
        [self.documentInteractionController setDelegate:self];
        
        // Preview PDF
        [self.documentInteractionController presentPreviewAnimated:YES];
    }
 */
    
/*
// 1. open pdf by safari
    NSString *fileUrl = @"http://192.168.0.81/2.pdf";
//    NSString *fileUrl = @"https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/ProgrammingWithObjectiveC.pdf";
//    NSString *fileUrl = @"http://192.168.0.81/1.pdf";
//    NSString *fileUrl = @"http://192.168.0.81/1.pdf";
    
    NSURL *url = [NSURL URLWithString:[fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication ] openURL:url];
*/
    

//2. open pdf, first download this file, and open it by UIDocumentInteractionController
    //设置下载文件保存的目录
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* filePath = [paths objectAtIndex:0];
    NSLog(@"filePath:%@",filePath);
    //File url
    NSString* fileUrl = @"http://192.168.0.81/2.pdf";
    //创建 Request
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
    NSString* fileName = @"down_doc1.pdf";
    filePath = [filePath stringByAppendingPathComponent:fileName];
    NSLog(@"new filePath:%@",filePath);
    //下载进行中的事件
    AFURLConnectionOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //进度
        float progress = (float)totalBytesRead / totalBytesExpectedToRead;
        //下载完成,该方法在下载完成后立即执行
        if (progress == 1.0) {
            //添加一个TableView/WebView
            NSURL *URL = [NSURL fileURLWithPath:filePath];
            NSLog(@"preview url:%@", URL);
            if (URL) {
                // Initialize Document Interaction Controller
                self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
                
                // Configure Document Interaction Controller
                [self.documentInteractionController setDelegate:self];
                
                // Preview PDF
                [self.documentInteractionController presentPreviewAnimated:YES];
            }
        }
    }];
    
    [operation start];
 
}

- (IBAction)openDocument:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"pdf"];
    
    if (URL) {
        // Initialize Document Interaction Controller
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        
        // Configure Document Interaction Controller
        [self.documentInteractionController setDelegate:self];
        
        // Present Open In Menu
        [self.documentInteractionController presentOpenInMenuFromRect:[button frame] inView:self.view animated:YES];
    }
}

#pragma mark -
#pragma mark Document Interaction Controller Delegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

@end
