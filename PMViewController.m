//
// PMViewController.m
// PodMail
//
// Copyright H2CO3, 2011.
// Created by Árpád Goretity, 04/10/2011.
//
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "PMViewController.h"
#import "NSString+PodMail.h"
#import "PMDonate.h"

#define CELL_ID @"PMCell"


@implementation PMViewController

- (id) init {
	self = [super initWithStyle:UITableViewStylePlain];
	self.title = @"Mail songs";
	self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"BarAlbums.png"] tag:9999 ] autorelease];
	return self;
}

// MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
	[[PMDonate sharedInstance] showDonateAlertIfNeccessary];
}

// UITableViewDelegate

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tv deselectRowAtIndexPath:indexPath animated:YES];
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	MFMusicTrack *track = [[MFMusicLibrary sharedLibrary] trackForIndex:indexPath.row];
	NSData *attachment = [[NSData alloc] initWithContentsOfFile:track.path];
	NSString *extension = [track.path pathExtension];
	NSString *type = [track.path mimeType];
	NSString *fileName = [NSString stringWithFormat:@"%@: %@ (%@).%@", track.artist, track.title, track.album, extension];
	int bytessize = [attachment length];
	float size = 0.0;
	char prefix = '\0';
	if (bytessize >= 1024 * 1024 * 1024) {
		size = bytessize / (1024.0 * 1024.0 * 1024.0);
		prefix = 'G';
	} else if (bytessize >= 1024 * 1024) {
		size = bytessize / (1024.0 * 1024.0);
		prefix = 'M';
	} else if (bytessize >= 1024) {
		size = bytessize / 1024.0;
		prefix = 'k';
	} else {
		size = (float)bytessize;
		prefix = '\0';
	}
	[controller setSubject:[NSString stringWithFormat:@"[PodMail] %@ (%.1f %cB)", fileName, size, prefix]];
	[controller setMessageBody:@"Sent using PodMail by H2CO3" isHTML:NO];
	[controller addAttachmentData:attachment mimeType:type fileName:fileName];
	[attachment release];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

// UITableViewDataSource

- (int) tableView:(UITableView *)tv numberOfRowsInSection:(int)section {
	return [[MFMusicLibrary sharedLibrary] numberOfTracks];
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CELL_ID];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_ID] autorelease];
	}
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	MFMusicTrack *track = [[MFMusicLibrary sharedLibrary] trackForIndex:indexPath.row];
	cell.textLabel.text = track.title;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", track.artist, track.album];
	[p release];
	return cell;
}

@end

