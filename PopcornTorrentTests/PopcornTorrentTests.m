

#import <XCTest/XCTest.h>
#import <PopcornTorrent/PopcornTorrent.h>

@interface PopcornTorrentTests : XCTestCase

@end

@implementation PopcornTorrentTests

- (void)testMagnetLinkStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [[PTTorrentStreamer sharedStreamer] startStreamingFromFileOrMagnetLink:@"magnet:?xt=urn:btih:6ccd25433f8aa382a8954575b4598ca3226add92&dn=The.Commuter.2018.1080p.WEB-DL.DD5.1.H264-FGT&tr=http%3A%2F%2Ftracker.trackerfix.com%3A80%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710&tr=udp%3A%2F%2F9.rarbg.to%3A2710" progress:^(PTTorrentStatus status) {
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

- (void)testSelectiveMagnetLinkStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [[PTTorrentStreamer sharedStreamer] startStreamingFromMultiTorrentFileOrMagnetLink:@"magnet:?xt=urn:btih:6ccd25433f8aa382a8954575b4598ca3226add92&dn=The.Commuter.2018.1080p.WEB-DL.DD5.1.H264-FGT&tr=http%3A%2F%2Ftracker.trackerfix.com%3A80%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710&tr=udp%3A%2F%2F9.rarbg.to%3A2710" progress:^(PTTorrentStatus status) {
        NSLog(@"Progress: %f",status.totalProgress);
    } readyToPlay:^(NSURL *videoFileURL, NSURL* video) {
        NSLog(@"%@", videoFileURL);
        XCTAssertNotNil(videoFileURL, @"No file URL");
        [[PTTorrentStreamer sharedStreamer] cancelStreamingAndDeleteData:YES];
        [expectation fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@", error.localizedDescription);
        [expectation fulfill];
    }
    selectFileToStream:^int(NSArray<NSString*> *torrentNames) {
        NSString* torrents = [[NSString alloc] init];
        for (NSString* name in torrentNames)torrents = [torrents stringByAppendingFormat:@"%@ ",name];
        XCTAssertNotEqual(torrents, @"");
        NSLog(@"Available names are %@",torrents);
        return 2;
    }
     ];
    
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
