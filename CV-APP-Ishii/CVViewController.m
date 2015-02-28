//
//  CVViewController.m
//  CV
//
//  Created by wanko on 2014/08/09.
//  Copyright (c) 2014年 Tetsuji Ishii. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CVSEManager.h"
#import "CVViewController.h"

@interface CVViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
@end

@implementation CVViewController

@synthesize cameraView;
@synthesize resultTextView;

NSString *preResult = @"";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //バーコード読み取り部分を隠す
    [self hideCameraView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) showCameraView {
    self.cameraView.hidden = NO;
}
- (void) hideCameraView {
    self.cameraView.hidden = YES;
}

- (IBAction)read:(id)sender {
    [self initQR:self.cameraView];
    [self showCameraView];
}

//QRコードを読み込むための準備
- (void) initQR:(UIView*)cview {
    self.session = [[AVCaptureSession alloc] init];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = nil;
    AVCaptureDevicePosition camera = AVCaptureDevicePositionBack; // Back or Front
    for (AVCaptureDevice *d in devices) {
        device = d;
        if (d.position == camera) {
            break;
        }
    }
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    [self.session addInput:input];
    
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:output];
    
    // QR コードのみ
    //output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // 全部認識させたい場合
    // (
    // face,
    // "org.gs1.UPC-E",
    // "org.iso.Code39",
    // "org.iso.Code39Mod43",
    // "org.gs1.EAN-13",
    // "org.gs1.EAN-8",
    // "com.intermec.Code93",
    // "org.iso.Code128",
    // "org.iso.PDF417",
    // "org.iso.QRCode",
    // "org.iso.Aztec"
    // )
    output.metadataObjectTypes = output.availableMetadataObjectTypes;
    //    NSLog(@"%@", output.availableMetadataObjectTypes);
    //    NSLog(@"%@", output.metadataObjectTypes);
    [self.session startRunning];
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.frame = cview.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [cview.layer addSublayer:preview];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"----");
    NSString *result = @"";
    for (AVMetadataObject *metadata in metadataObjects) {
        //QRコードの場合
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // 複数の QR があっても1度で読み取れている
            result = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            [self readQR:result];
            break;
        }
    }
}

- (void) readQR:(NSString*)result {
    NSLog(@"QR=%@", result);
    //２度読み防止
    if (![result isEqualToString:@""] && ![result isEqualToString:preResult]){
        preResult = result;
        //バイブレーションさせる
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //読み込み結果を表示
        resultTextView.text = result;
        //読み込んだQRがwavファイルなら音声を再生
        if ([result hasPrefix:@"http"] && [result hasSuffix:@"wav"]) {
            [self playWAV:result];
        }
        //バーコード読み取り部分を隠す
        [self hideCameraView];
    }
}


- (IBAction)clear:(id)sender {
    preResult = @"";
    resultTextView.text = @"";
}

//音を鳴らす
-(void) playWAV:(NSString*)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    //サーバから取得した音声ファイルを再生する
    NSURLSessionDownloadTask *getTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //ここに処理を記述
            //音声ファイルを書き込み
            NSString *soundName = @"temp.wav";//とりあえずwavファイルのみ
            [CVSEManager writeFile:[NSData dataWithContentsOfURL:location] soundName:soundName];
            //音声ファイルを再生
            [[CVSEManager sharedManager] playSound:soundName];
        });
    }];
    [getTask resume];
}


@end
