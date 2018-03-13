

#import <XCTest/XCTest.h>
#import <PopcornTorrent/PopcornTorrent.h>

@interface PopcornTorrentTests : XCTestCase

@end

@implementation PopcornTorrentTests

- (void)testMangetLinkStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [[PTTorrentStreamer sharedStreamer] startStreamingFromFileOrMagnetLink:@"magnet:?xt=urn:btih:321f30bd5e190158e24100d639ae6058217b03a9&dn=Jimmy.Fallon.2018.03.12.Alec.Baldwin.720p.HDTV.x264-SORNY%5Brartv%5D&tr=http%3A%2F%2Ftracker.trackerfix.com%3A80%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710&tr=udp%3A%2F%2F9.rarbg.to%3A2710" progress:^(PTTorrentStatus status) {
        NSLog(@"Progress: %f",status.totalProgress);
    } readyToPlay:^(NSURL *videoFileURL, NSURL* video) {
        NSLog(@"%@", videoFileURL);
        XCTAssertNotNil(videoFileURL, @"No file URL");
        [[PTTorrentStreamer sharedStreamer] cancelStreamingAndDeleteData:YES];
        [expectation fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@", error.localizedDescription);
        [expectation fulfill];
    }];
    
    // Wait 5 minutes
    [self waitForExpectationsWithTimeout:60.0 * 10 handler:nil];
}

-(void)testTorrentFileStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [[PTTorrentStreamer sharedStreamer] startStreamingFromFileOrMagnetLink:[[NSBundle bundleForClass:[self class]] pathForResource:@"Test" ofType:@"torrent"] progress:^(PTTorrentStatus status) {
        
    } readyToPlay:^(NSURL *videoFileURL, NSURL* video) {
        NSLog(@"%@", videoFileURL);
        [[PTTorrentStreamer sharedStreamer] cancelStreamingAndDeleteData:YES];
        XCTAssertNotNil(videoFileURL, @"No file URL");
        [expectation fulfill];
        
    } failure:^(NSError *error) {
        XCTFail(@"%@", error.localizedDescription);
        [expectation fulfill];
    }];
   
    
    // Wait 5 minutes
    [self waitForExpectationsWithTimeout:60.0 * 5 handler:nil];
}

@end
