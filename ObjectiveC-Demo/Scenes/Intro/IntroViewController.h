//
//  IntroViewController.h
//  ObjectiveC-Demo
//
//  Created by INCHAN KANG on 2018. 4. 4..
//  Copyright © 2018년 INCHAN KANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController

- (void) localMessage: (char[])message;

- (int) localMessage: (char[])message _:(BOOL)isPrintable _:(int)messageId;

+ (void) combineMessages: (NSString *)message;

@end
