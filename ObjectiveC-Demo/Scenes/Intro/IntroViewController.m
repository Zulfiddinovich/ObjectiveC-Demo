//
//  IntroViewController.m
//  ObjectiveC-Demo
//
//  Created by INCHAN KANG on 2018. 4. 4..
//  Copyright © 2018년 INCHAN KANG. All rights reserved.
//

#import "IntroViewController.h"
#import "MySampleClass.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // ordinary printf
    printf("Hello guys!");
}

- (IBAction)clickBtnEvent:(id)sender {
    // using NSString and NSLog
    MySampleClass *sampleClass = [MySampleClass alloc].init; // or [[MySampleClass alloc].init];
    NSString *message = [sampleClass messageToIntro];
    NSLog(@"%@", message);
    
    // local message 1
    char message1[] = "This is ordinary method call";
    [self localMessage: message1];
    
    // local message 2
    char message2[] = "This is overloaded method call";
    [self localMessage: message2];
    
    // static method
    NSString *combinedMessages = [NSString stringWithFormat:@"'%s' and '%s'", message1, message2];
    [IntroViewController combineMessages: combinedMessages];
}

- (void)localMessage: (char[])message {
    // non-static method
    printf("%s \n", message);
    
}

- (int)localMessage: (char[])message _:(BOOL)isPrintable _:(int)messageId {
    // overloaded non-static method
    if (isPrintable) {
        printf("%s, messagId: %d \n", message, messageId);
        return 1;
    }
    return 0;
}

+ (void)combineMessages: (NSString *)message {
    // static method
    NSLog(@"NSLog: %@", message);
    
    printf("printf: %s", [message UTF8String]);
}



@end
