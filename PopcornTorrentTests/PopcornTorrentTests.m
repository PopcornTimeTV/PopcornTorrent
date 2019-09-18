

#import <XCTest/XCTest.h>
#import <PopcornTorrent/PopcornTorrent.h>

@interface PopcornTorrentTests : XCTestCase
@property (nonatomic,strong) PTTorrentStreamer *streamer;
@end

@implementation PopcornTorrentTests

- (PTTorrentStreamer *)streamer{
    if (_streamer == nil){
        _streamer = [PTTorrentStreamer sharedStreamer];
    }
    return _streamer;
}

- (void)testMagnetLinkStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [self.streamer startStreamingFromFileOrMagnetLink:@"magnet:?xt=urn:btih:EB01E7C2ED1B8F52089371B3AC92893B7E8E9934&dn=Hawaii+Five-0+2010+S09E22+HDTV+x264-KILLERS+%5Beztv%5D&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftorrent.gresille.org%3A80%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337&tr=udp%3A%2F%2Ftracker.zer0day.to%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fcoppersurfer.tk%3A6969%2Fannounce" progress:^(PTTorrentStatus status) {
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
    
    // Wait 10 minutes
    [self waitForExpectationsWithTimeout:60.0 * 10 handler:nil];
}

-(void) testMultiTorrentStreaming{
    for (int i=0; i<=1; i++)[self testMagnetLinkStreaming];
}

- (void)testSelectiveMagnetLinkStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    __block NSString *selectedTorrent;
    [self.streamer startStreamingFromMultiTorrentFileOrMagnetLink:@"magnet:?xt=urn:btih:D4161A18932C75F598853910C581ECCFA2A43929&dn=La+Casa+De+Papel+AKA+Money+Heist+%282019%29+Season+03+Complete+720p+WEB-DL+x264+AAC+ESub+%5BEnglish+DD5.1%5D+3.3GB+%5BCraZzyBoY%5D&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.open-internet.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80%2Fannounce&tr=http%3A%2F%2Ftracker3.itzmx.com%3A6961%2Fannounce&tr=http%3A%2F%2Ftracker1.itzmx.com%3A8080%2Fannounce&tr=udp%3A%2F%2Ftracker.zer0day.to%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fcoppersurfer.tk%3A6969%2Fannounce" progress:^(PTTorrentStatus status) {
        NSLog(@"Progress: %f",status.totalProgress);
    } readyToPlay:^(NSURL *videoFileURL, NSURL* video) {
        NSLog(@"%@", videoFileURL);
        XCTAssertNotNil(videoFileURL, @"No file URL");
        XCTAssertEqualObjects(video.lastPathComponent, selectedTorrent);
        [[PTTorrentStreamer sharedStreamer] cancelStreamingAndDeleteData:YES];
        [expectation fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@", error.localizedDescription);
        [expectation fulfill];
    }
    selectFileToStream:^int(NSArray<NSString*> *torrentNames) {
        NSString* torrents = [[NSString alloc] init];
        for (NSString* name in torrentNames)torrents = [torrents stringByAppendingFormat:@"%@\n",name];
        XCTAssertNotEqual(torrents, @"");
        NSLog(@"Available names are \n%@",torrents);
        selectedTorrent = [torrentNames objectAtIndex:2];
        return 2;
    }];
    
    // Wait 5 minutes
    [self waitForExpectationsWithTimeout:60.0 * 10 handler:nil];
}

-(void)testTorrentFileStreaming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [self.streamer startStreamingFromFileOrMagnetLink:[[NSBundle bundleForClass:[self class]] pathForResource:@"Test" ofType:@"torrent"] progress:^(PTTorrentStatus status) {
        
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

-(void)testTorrentResuming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Torrent Streaming"];
    
    [self.streamer startStreamingFromFileOrMagnetLink:@"magnet:?xt=urn:btih:EB01E7C2ED1B8F52089371B3AC92893B7E8E9934&dn=Hawaii+Five-0+2010+S09E22+HDTV+x264-KILLERS+%5Beztv%5D&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftorrent.gresille.org%3A80%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337&tr=udp%3A%2F%2Ftracker.zer0day.to%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fcoppersurfer.tk%3A6969%2Fannounce" progress:^(PTTorrentStatus status) {
        
    } readyToPlay:^(NSURL *videoFileURL, NSURL* video) {
        NSLog(@"%@", videoFileURL);
        [[PTTorrentStreamer sharedStreamer] cancelStreamingAndDeleteData:NO];
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
