//
//  XXTPickerFactory.m
//  XXTPickerCollection
//
//  Created by Zheng on 30/04/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTPickerFactory.h"
#import "XXTBasePicker.h"
#import "XXTPickerNavigationController.h"
#import "XXTPickerSnippet.h"

@interface XXTPickerFactory ()

@end

@implementation XXTPickerFactory

+ (instancetype)sharedInstance {
    static XXTPickerFactory *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)executeTask:(XXTPickerSnippet *)pickerTask fromViewController:(UIViewController *)viewController {
    id nextPicker = [pickerTask nextPicker];
    if (nextPicker) {
        if ([nextPicker respondsToSelector:@selector(setPickerTask:)])
        {
            [nextPicker performSelector:@selector(setPickerTask:) withObject:pickerTask];
        }
        if (nextPicker && [nextPicker respondsToSelector:@selector(setPickerFactory:)])
        {
            [nextPicker performSelector:@selector(setPickerFactory:) withObject:self];
        }
        if ([viewController.navigationController isKindOfClass:[XXTPickerNavigationController class]]) {
            [viewController.navigationController pushViewController:nextPicker animated:YES];
        } else {
            XXTPickerNavigationController *navigationController = [[XXTPickerNavigationController alloc] initWithRootViewController:nextPicker];
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [viewController presentViewController:navigationController animated:YES completion:nil];
        }
    } else {
        BOOL shouldFinish = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(pickerFactory:taskShouldFinished:)]) {
            shouldFinish = [_delegate pickerFactory:self taskShouldFinished:pickerTask];
        }
        if (shouldFinish) {
            if ([viewController.navigationController isKindOfClass:[XXTPickerNavigationController class]]) {
                [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

- (void)performNextStep:(UIViewController *)viewController {

    if ([[viewController class] respondsToSelector:@selector(pickerKeyword)]) {
        id pickerResult = [viewController performSelector:@selector(pickerResult)];
        if (!pickerResult) {
            return;
        }
        id pickerTaskObj = [viewController performSelector:@selector(pickerTask)];
        if (!pickerTaskObj) {
            return;
        }
        XXTPickerSnippet *pickerTask = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:pickerTaskObj]];
        [pickerTask addResult:pickerResult];
        id nextPicker = [pickerTask nextPicker];
        if (nextPicker && [nextPicker respondsToSelector:@selector(setPickerTask:)])
        {
            [nextPicker performSelector:@selector(setPickerTask:) withObject:pickerTask];
        }
        if (nextPicker && [nextPicker respondsToSelector:@selector(setPickerFactory:)])
        {
            [nextPicker performSelector:@selector(setPickerFactory:) withObject:self];
        }
        BOOL shouldEnter = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(pickerFactory:taskShouldEnterNextStep:)]) {
            shouldEnter = [_delegate pickerFactory:self taskShouldEnterNextStep:pickerTask];
        }
        if (shouldEnter && nextPicker)
        {
            [viewController.navigationController pushViewController:nextPicker animated:YES];
        }
    }

}

- (void)performFinished:(UIViewController *)viewController {
    
    if ([viewController respondsToSelector:@selector(pickerResult)] &&
        [viewController respondsToSelector:@selector(pickerTask)]) {
        id pickerResult = [viewController performSelector:@selector(pickerResult)];
        if (!pickerResult) {
            return;
        }
        id pickerTaskObj = [viewController performSelector:@selector(pickerTask)];
        if (!pickerTaskObj) {
            return;
        }
        XXTPickerSnippet *pickerTask = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:pickerTaskObj]];
        [pickerTask addResult:pickerResult];
        BOOL shouldFinish = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(pickerFactory:taskShouldFinished:)]) {
            shouldFinish = [_delegate pickerFactory:self taskShouldFinished:pickerTask];
        }
        if (shouldFinish) {
            [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }

}

- (void)performUpdateStep:(UIViewController *)viewController {

    XXTPickerNavigationController *navController = (XXTPickerNavigationController *)viewController.navigationController;
    
    if ([viewController respondsToSelector:@selector(pickerTask)]) {
        XXTPickerSnippet *currentTask = [viewController performSelector:@selector(pickerTask)];
        [navController.popupBar setTitle:[NSString stringWithFormat:@"%@ (%lu/%lu)", viewController.title, (unsigned long)currentTask.currentStep, (unsigned long)currentTask.totalStep]];
        [navController.popupBar setProgress:currentTask.currentProgress];
        
        if ([viewController respondsToSelector:@selector(pickerSubtitle)]) {
            NSString *subtitle = [viewController performSelector:@selector(pickerSubtitle)];
            if ([viewController.navigationController isKindOfClass:[XXTPickerNavigationController class]]) {
                [navController.popupBar setSubtitle:subtitle];
            }
        }
        if ([viewController respondsToSelector:@selector(pickerAttributedSubtitle)]) {
            NSAttributedString *subtitle = [viewController performSelector:@selector(pickerAttributedSubtitle)];
            if ([viewController.navigationController isKindOfClass:[XXTPickerNavigationController class]]) {
                [navController.popupBar setAttributedSubtitle:subtitle];
            }
        }
    } else {
        [navController.popupBar setHidden:YES];
    }

}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"- [XXTPickerFactory dealloc]");
#endif
}

@end