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

static id shared = nil;

@implementation PMDonate

+ (id)sharedInstance
{
	if (shared == nil) {
		shared = [[self alloc] init];
	}
	return shared;
}

- (void)showDonateAlertIfNeccessary
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PMDonateShown3"] == NO) {
		UIAlertView *av = [[UIAlertView alloc] init];
		av.delegate = self;
		av.title = @"Please donate";
		av.message = @"If this tweak worked for you and you like it, I would greatly appreciate a donation. By donating, you support the development of my apps and tweaks. Thank you!";
		[av addButtonWithTitle:@"Donate"];
		[av addButtonWithTitle:@"Later"];
		[av show];
		[av release];
	}
}

// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)av didDismissWithButtonIndex:(int)index
{
	if (index == 0) {
		// User hit Donate
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8Y95UZYUHTM22"]];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PMDonateShown3"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

@end

