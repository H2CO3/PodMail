//
// PMDonate.m
// PodMail
//
// Copyright H2CO3, 2011.
// Created by Árpád Goretity, 04/10/2011.
//
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "PMDonate.h"

static id shared = NULL;


@implementation PMDonate

+ (id) sharedInstance {
	if (shared == NULL) {
		shared = [[self alloc] init];
	}
	return shared;
}

- (void) showDonateAlertIfNeccessary {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PMDonateShown"] == NO) {
		UIAlertView *av = [[UIAlertView alloc] init];
		av.delegate = self;
		av.title = @"Please donate";
		av.message = @"If this tweak worked for you and you like it, I would greatly appreciate a donation.";
		[av addButtonWithTitle:@"Donate"];
		[av addButtonWithTitle:@"Later"];
		[av show];
		[av release];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PMDonateShown"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

// UIAlertViewDelegate

- (void) alertView:(UIAlertView *)av didDismissWithButtonIndex:(int)index {
	if (index == 0) {
		// User hit Donate
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://apaczai.elte.hu/~13akga/donate/index.html"]];
	}
}

@end

