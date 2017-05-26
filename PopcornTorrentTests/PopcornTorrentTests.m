

#import <XCTest/XCTest.h>
#import <PopcornTorrent/PopcornTorrent.h>

@interface PopcornTorrentTests : XCTestCase

@end

@implementation PopcornTorrentTests

- (void)testMangetLinkStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [[PTTorrentStreamer sharedStreamer] startStreamingFromFileOrMagnetLink:@"magnet:?xt=urn:btih:6268ABCCB049444BEE76813177AA46643A7ADA88&tr=udp://glotorrents.pw:6969/announce&tr=udp://tracker.opentrackr.org:1337/announce&tr=udp://torrent.gresille.org:80/announce&tr=udp://tracker.openbittorrent.com:80&tr=udp://tracker.coppersurfer.tk:6969&tr=udp://tracker.leechers-paradise.org:6969&tr=udp://p4p.arenabg.ch:1337&tr=udp://tracker.internetwarriors.net:1337" progress:^(PTTorrentStatus status) {
        
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

-(void)testTorrentFileStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [[PTTorrentStreamer sharedStreamer] startStreamingFromFileOrMagnetLink:[[NSBundle mainBundle] pathForResource:@"Test" ofType:@"torrent"] progress:^(PTTorrentStatus status) {
        
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
