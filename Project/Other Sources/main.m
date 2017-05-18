//
//  main.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Controller.h"

int main(int argc, char *argv[]) {
    // disable sigpipe (prevents crashes)
    signal(SIGPIPE, SIG_IGN);
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([Controller class]));
    }
}
