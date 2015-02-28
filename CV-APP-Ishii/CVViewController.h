//
//  CVViewController.h
//  CV
//
//  Created by wanko on 2014/08/09.
//  Copyright (c) 2014年 Tetsuji Ishii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
- (IBAction)read:(id)sender;
- (IBAction)clear:(id)sender;

@end
