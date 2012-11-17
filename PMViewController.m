//
// PMViewController.m
// PodMail
//
// Copyright H2CO3, 2011.
// Created by Árpád Goretity, 04/10/2011.
//
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#if 0
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#endif

#import <FLAC/all.h>
#import <CoreAudio/CoreAudio.h>
#import "PMViewController.h"
#import "PMDonate.h"

#define CELL_ID @"PMCell"

// toolchain bug workarounds
typedef enum {
	AVAssetReaderStatusUnknown,
	AVAssetReaderStatusReading,
	AVAssetReaderStatusCompleted,
	AVAssetReaderStatusFailed,
	AVAssetReaderStatusCancelled
} AVAssetReaderStatus;

extern NSString *AVFormatIDKey, *AVSampleRateKey, *AVLinearPCMBitDepthKey, *AVLinearPCMIsNonInterleaved, *AVLinearPCMIsFloatKey, *AVLinearPCMIsBigEndianKey;
extern NSString *MPMediaItemPropertyAssetURL;

@class AVURLAsset, AVAssetReader, AVAssetReaderTrackOutput;

typedef void *CMSampleBufferRef;
typedef void *CMBlockBufferRef;

// FLAC encoder output callback
FLAC__StreamEncoderWriteStatus FLAC_writeCallback(const FLAC__StreamEncoder *encoder, const FLAC__byte *buffer, size_t bytes, unsigned samples, unsigned current_frame, void *ctx)
{
	NSMutableData *flacData = ctx;
	[flacData appendBytes:buffer length:bytes];
	return FLAC__STREAM_ENCODER_WRITE_STATUS_OK;
}

@implementation PMViewController

- (id)init
{
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		self.title = @"Mail songs";
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)] autorelease];
		} else {
			UIImage *img = [[UIImage alloc] initWithContentsOfFile:@"/var/mobile/Library/PodMail/PodMail.png"];
			self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:nil image:img tag:'podm'] autorelease];
			[img release];
		}
		MPMediaQuery *query = [[MPMediaQuery alloc] init];
		songs = [query.items copy];
		[query release];
		[self.tableView reloadData];
	}
	return self;
}

- (void)dealloc
{
	[songs release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o
{
	 return YES;
}

- (void)close
{
	[self dismissModalViewControllerAnimated:YES];
}

// MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissModalViewControllerAnimated:YES];
	[[PMDonate sharedInstance] showDonateAlertIfNeccessary];
}

// UITableViewDelegate

- (void)extractItemWithInfo:(NSDictionary *)info
{
	MPMediaItem *item = [info objectForKey:@"item"];
	NSIndexPath *indexPath = [info objectForKey:@"indexPath"];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Get raw PCM data from the track
	NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
	NSMutableData *data = [[NSMutableData alloc] init];

	const uint32_t sampleRate = 16000;
	const uint16_t bitDepth = 16;
	const uint16_t channels = 2;

	NSDictionary *opts = [NSDictionary dictionary];
	AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:assetURL options:opts];
	AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:NULL];
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
		[NSNumber numberWithFloat:(float)sampleRate], AVSampleRateKey,
		[NSNumber numberWithInt:bitDepth], AVLinearPCMBitDepthKey,
		[NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
		[NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
		[NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey, nil];

	AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:[[asset tracks] objectAtIndex:0] outputSettings:settings];
	[asset release];
	[reader addOutput:output];
	[reader startReading];

	// read the samples from the asset and append them subsequently
	while ([reader status] != AVAssetReaderStatusCompleted) {
		CMSampleBufferRef buffer = [output copyNextSampleBuffer];
		if (buffer == NULL) continue;

		CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(buffer);
		size_t size = CMBlockBufferGetDataLength(blockBuffer);
		uint8_t *outBytes = malloc(size);
		CMBlockBufferCopyDataBytes(blockBuffer, 0, size, outBytes);
		CMSampleBufferInvalidate(buffer);
		CFRelease(buffer);
		[data appendBytes:outBytes length:size];
		free(outBytes);
	}
	[output release];

	// Encode the PCM data to FLAC
	uint32_t totalSamples = [data length] / (channels * bitDepth / 8);
	NSMutableData *flacData = [[NSMutableData alloc] init];

	// Create a FLAC encoder
	FLAC__StreamEncoder *encoder = FLAC__stream_encoder_new();
	if (encoder == NULL)
	{
		// handle error
	}

	// Set up the encoder
	FLAC__stream_encoder_set_verify(encoder, true);
	FLAC__stream_encoder_set_compression_level(encoder, 8);
	FLAC__stream_encoder_set_channels(encoder, channels);
	FLAC__stream_encoder_set_bits_per_sample(encoder, bitDepth);
	FLAC__stream_encoder_set_sample_rate(encoder, sampleRate);
	FLAC__stream_encoder_set_total_samples_estimate(encoder, totalSamples);

	// Initialize the encoder
	FLAC__stream_encoder_init_stream(encoder, FLAC_writeCallback, NULL, NULL, NULL, flacData);

	// Start encoding
	size_t left = totalSamples;
	const size_t buffsize = 1 << 16;
	FLAC__byte *buffer;
	static FLAC__int32 pcm[1 << 17];
	size_t need;
	size_t i;
	while (left > 0) {
		need = left > buffsize ? buffsize : left;

		buffer = (FLAC__byte *)[data bytes] + (totalSamples - left) * channels * bitDepth / 8;
		for (i = 0; i < need * channels; i++) {
			if (bitDepth == 16) {
				// 16 bps, signed little endian
				pcm[i] = *(int16_t *)(buffer + i * 2);
			} else {
				// 8 bps, unsigned
				pcm[i] = *(uint8_t *)(buffer + i);
			}
		}
		
		FLAC__bool succ = FLAC__stream_encoder_process_interleaved(encoder, pcm, need);
		if (succ == 0) {
			FLAC__stream_encoder_delete(encoder);
			// handle error
			return;
		}

		left -= need;
	}

	// Clean up
	FLAC__stream_encoder_finish(encoder);
	FLAC__stream_encoder_delete(encoder);
	[data release];

	NSString *fileName = [NSString stringWithFormat:@"%@ - %@.flac", [item valueForProperty:MPMediaItemPropertyAlbumTitle], [item valueForProperty:MPMediaItemPropertyAlbumArtist]];

	NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:fileName, @"fileName", flacData, @"attachment", indexPath, @"indexPath", nil];
       [flacData release];

       [self performSelectorOnMainThread:@selector(conversionDone:) withObject:result waitUntilDone:YES];

       [pool drain];
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tv deselectRowAtIndexPath:indexPath animated:YES];

	UITableViewCell *cell = [tv cellForRowAtIndexPath:indexPath];
	UIActivityIndicatorView *s = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[s startAnimating];
	cell.accessoryView = s;

	MPMediaItem *item = [songs objectAtIndex:indexPath.row];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:item, @"item", indexPath, @"indexPath", nil];
	[self performSelectorInBackground:@selector(extractItemWithInfo:) withObject:info];
}

- (void)conversionDone:(NSDictionary *)conversion
{
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;

	NSString *fileName = [conversion objectForKey:@"fileName"];
	NSData *attachment = [conversion objectForKey:@"attachment"];
	NSIndexPath *indexPath = [conversion objectForKey:@"indexPath"];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryView = nil;

	[controller setSubject:[NSString stringWithFormat:@"[PodMail] %@", fileName]];
	[controller setMessageBody:@"This song was sent to you using PodMail by <a href='http://twitter.com/H2CO3_iOS'>H2CO3</a> - <a href='https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8Y95UZYUHTM22'>please donate</a> in order to help the development of this and other tweaks!" isHTML:YES];
	[controller addAttachmentData:attachment mimeType:@"audio/x-flac" fileName:fileName];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

// UITableViewDataSource

- (int)tableView:(UITableView *)tv numberOfRowsInSection:(int)section
{
	return songs.count;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CELL_ID];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_ID] autorelease];
	}

	MPMediaItem *item = [songs objectAtIndex:indexPath.row];
	cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [item valueForProperty:MPMediaItemPropertyAlbumTitle], [item valueForProperty:MPMediaItemPropertyAlbumArtist]];

	return cell;
}

@end

