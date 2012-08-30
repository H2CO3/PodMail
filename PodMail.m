//
// PodMail.m
// PodMail
//
// Copyright H2CO3, 2011.
// Created by Árpád Goretity, 04/10/2011.
//
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import <signal.h>
#import <stdio.h>
#import <execinfo.h>
#import <objc/runtime.h>
#import <substrate.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "PMViewController.h"

static IMP _orig1, _orig2;
UIViewController *gridController = nil;

id _mod1(id __self, SEL __cmd, CGRect f)
{
	__self = _orig1(__self, __cmd, f);

	UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
	b.frame = CGRectMake(10, 15, 80, 30);
	[b setTitle:@"PodMail" forState:UIControlStateNormal];
	[b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[b addTarget:gridController action:@selector(showPodMail) forControlEvents:UIControlEventTouchUpInside];
	b.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	b.layer.cornerRadius = 7.0;
	b.backgroundColor = [UIColor darkGrayColor];
	[__self setLeftButton:b];

	return __self;
}

id _mod2(id __self, SEL __cmd, id _1, id _2)
{
	__self = _orig2(__self, __cmd, _1, _2);

	if (gridController == nil)
		gridController = __self;

	return __self;
}

void showPodMail(id __self, SEL __cmd)
{
	PMViewController *rootViewController = [[PMViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[rootViewController release];
	[__self presentModalViewController:navigationController animated:YES];
	[navigationController release];
}

__attribute__((constructor))
extern void init() {
	class_addMethod(
		objc_getClass("MusicGridViewController"),
		@selector(showPodMail),
		(IMP)showPodMail,
		"v@:"
	);

	MSHookMessageEx(
		objc_getClass("MusicHeaderView"),
		@selector(initWithFrame:),
		(IMP)_mod1,
		&_orig1
	);

	MSHookMessageEx(
		objc_getClass("MusicGridViewController"),
		@selector(initWithDataSource:gridConfigurationClass:),
		(IMP)_mod2,
		&_orig2
	);
}

