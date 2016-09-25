

#import <XCTest/XCTest.h>
#import <PopcornTorrent/PopcornTorrent.h>

@interface PopcornTorrentTests : XCTestCase

@end

@implementation PopcornTorrentTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testTorrentStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [[PTTorrentStreamer sharedStreamer] startStreamingFromFileOrMagnetLink:@"/Users/aggelospapageorgiou/Library/Developer/CoreSimulator/Devices/BDD4DB27-8EA4-48E2-A8F5-52CC9EAD78D2/data/Containers/Data/Application/D7C268D7-0F49-45CD-B54A-C0FC2EE25162/Library/Caches/Downloads/4C8CDA2CB0E98A7649EC87802781ADBF7D08120A.torrent" progress:^(PTTorrentStatus status) {
        
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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
