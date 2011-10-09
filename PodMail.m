//
// PodMail.m
// PodMail
//
// Copyright H2CO3, 2011.
// Created by Árpád Goretity, 04/10/2011.
//
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import <objc/runtime.h>
#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PMViewController.h"

static IMP _original_$_iPodTabBarController_$_initWithControllersForRole_;

id _modified_$_iPodTabBarController_$_initWithControllersForRole_(UITabBarController *_self, SEL _cmd, int role) {
	_self = _original_$_iPodTabBarController_$_initWithControllersForRole_(_self, _cmd, role);
	NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:_self.viewControllers];
	PMViewController *rootViewController = [[PMViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[rootViewController release];
	[viewControllers addObject:navigationController];
	[navigationController release];
	_self.viewControllers = viewControllers;
	[viewControllers release];
	return _self;
}

__attribute__((constructor))
extern void init() {
	MSHookMessageEx(objc_getClass("iPodTabBarController"), @selector(initWithControllersForRole:), (IMP)_modified_$_iPodTabBarController_$_initWithControllersForRole_, &_original_$_iPodTabBarController_$_initWithControllersForRole_);
}

