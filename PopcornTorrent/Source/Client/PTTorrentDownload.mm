

#import "PTTorrentDownload.h"
#import "PTSize.h"
#import "PTTorrentStreamer+Protected.h"
#import "PTTorrentDownloadManagerListener.h"
#import <MediaPlayer/MPMediaItem.h>
#import <UIKit/UIApplication.h>

NSString *const PTTorrentItemPropertyDownloadStatus = @"downloadStatus";

@implementation PTTorrentDownload {
    PTTorrentDownloadStatus _downloadStatus;
}

- (PTTorrentDownloadStatus)downloadStatus {
    return _downloadStatus;
}

+ (NSString *)downloadDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSMoviesDirectory, NSUserDomainMask, YES);
    NSString *downloadDirectory = [paths objectAtIndex:0];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadDirectory]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NSLog(@"%@", error);
            return nil;
        }
    }
    
    return downloadDirectory;
}

- (instancetype)initFromPlist:(NSString *)pathToPlist {
    NSDictionary<NSString *, id> *dictionary = [NSDictionary dictionaryWithContentsOfFile:pathToPlist];
    
    PTTorrentDownloadStatus downloadStatus = (PTTorrentDownloadStatus)[[dictionary objectForKey:PTTorrentItemPropertyDownloadStatus] integerValue];
    
    NSString *savePath = [pathToPlist stringByDeletingLastPathComponent];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:savePath];
    NSString *fileName;
    
    while (fileName = [enumerator nextObject]) {
        NSString *pathExtension = [fileName pathExtension];
        if ([pathExtension isEqualToString: @"mp4"] || [pathExtension isEqualToString: @"mkv"]) break;
    }
    
    long long requiredSpace = [[[[NSFileManager defaultManager] attributesOfItemAtPath:[savePath stringByAppendingPathComponent:fileName] error:nil] objectForKey:NSFileSize] longLongValue];
    
    if (dictionary && downloadStatus && savePath && fileName && requiredSpace) {
        @try {
            self = [self initWithMediaMetadata:dictionary downloadStatus:downloadStatus];
            _savePath = savePath;
            _fileName = fileName;
            _requiredSpace = requiredSpace;
            _totalDownloaded = requiredSpace;
            self.isFinished = true;
            self.torrentStatus = {1, 1, 0, 0, 0, 0};
            return self;
        } @catch (NSException *exception) {
            return nil;
        }
    }
    return nil;
}

- (instancetype)initWithMediaMetadata:(NSDictionary<NSString *, id> *)mediaMetadata downloadStatus:(PTTorrentDownloadStatus)downloadStatus {
    NSAssert([mediaMetadata objectForKey: MPMediaItemPropertyPersistentID] != nil, @"MPMediaItemPropertyPersistentID property must be set.");
    
    for (id value in [mediaMetadata allValues]) {
        NSArray *validClasses = @[[NSData class], [NSDate class], [NSNumber class], [NSString class], [NSArray class], [NSDictionary class]];
        
        BOOL isSubclass = NO;
        
        for (id validClass in validClasses) {
            if ([[value class] isSubclassOfClass:validClass]) isSubclass = YES;
        }
        
        NSAssert(isSubclass, @"All mediaMetadata values must be instances of NSData, NSDate, NSNumber, NSString, NSArray, or NSDictionary for a valid property list file to be created. %@ is not.", value);
    }
    
    self = [super init];
    if (self) {
        _downloadStatus = downloadStatus;
        _mediaMetadata = mediaMetadata;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[PTTorrentDownload class]]) {
        return [((PTTorrentDownload *)object).mediaMetadata[MPMediaItemPropertyPersistentID] isEqualToString:self.mediaMetadata[MPMediaItemPropertyPersistentID]];
    }
    return NO;
}

- (NSUInteger)hash {
    return [_mediaMetadata[MPMediaItemPropertyPersistentID] hash];
}


- (void)startDownloadingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink {
    __weak __typeof__(self) weakSelf = self;
    
    [super startStreamingFromFileOrMagnetLink:filePathOrMagnetLink directoryName:_mediaMetadata[MPMediaItemPropertyPersistentID] progress:^(PTTorrentStatus status) {
        PTTorrentDownloadStatus downloadStatus = status.totalProgress < 1 ? PTTorrentDownloadStatusDownloading : PTTorrentDownloadStatusFinished;
        
        [weakSelf setDownloadStatus:downloadStatus];
        [weakSelf setTorrentStatus:status];
        
        if (downloadStatus == PTTorrentDownloadStatusFinished) {
            [self performSelector:@selector(cancelStreamingAndDeleteData:) withObject:nil];
        }
    } readyToPlay:nil failure:^(NSError * _Nonnull error) {
        id<PTTorrentDownloadManagerListener> delegate = weakSelf.delegate;
        
        [weakSelf setDownloadStatus:PTTorrentDownloadStatusFailed];
        
        if (delegate && [delegate respondsToSelector:@selector(downloadDidFail:withError:)]) {
            [delegate downloadDidFail:weakSelf withError:error];
        }
    }];
}


- (void)setTorrentStatus:(PTTorrentStatus)torrentStatus {
    _torrentStatus = torrentStatus;
    
    if (_delegate && [_delegate respondsToSelector:@selector(torrentStatusDidChange:forDownload:)]) {
        [_delegate torrentStatusDidChange:torrentStatus forDownload:self];
    }
}

- (void)setDownloadStatus:(PTTorrentDownloadStatus)downloadStatus {
    if (downloadStatus == _downloadStatus) return;
    
    _downloadStatus = downloadStatus;
    
    if (_delegate && [_delegate respondsToSelector:@selector(downloadStatusDidChange:forDownload:)]) {
        [_delegate downloadStatusDidChange:downloadStatus forDownload:self];
    }
}

- (void)stop {
    if (_downloadStatus == PTTorrentDownloadStatusFinished) return;
    
    [self performSelector:@selector(cancelStreamingAndDeleteData:) withObject:@YES];
    [self setDownloadStatus:PTTorrentDownloadStatusFinished];
}

- (void)pause {
    if (_downloadStatus != PTTorrentDownloadStatusDownloading) return;
    
    _session->pause();
    [self setDownloadStatus:PTTorrentDownloadStatusPaused];
    
    #if TARGET_OS_IOS
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    #endif
}

- (void)resume {
    if (_downloadStatus != PTTorrentDownloadStatusPaused) return;
    
    if (_session->is_paused()) {
       _session->resume();
    }
    [self setDownloadStatus:PTTorrentDownloadStatusDownloading];
    
    #if TARGET_OS_IOS
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    #endif
}

- (BOOL)delete {
    NSAssert(_downloadStatus != PTTorrentDownloadStatusPaused && _downloadStatus != PTTorrentDownloadStatusDownloading, @"This method should not be used to stop downloads, only to delete a pre-existing download.");
    
    NSString *path = [[[self class] downloadDirectory] stringByAppendingPathComponent:_mediaMetadata[MPMediaItemPropertyPersistentID]];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (BOOL)save {
    NSString *filePath = [_savePath stringByAppendingPathComponent:@"Metadata.plist"];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:_mediaMetadata];
    [dictionary setObject:@(_downloadStatus) forKey:PTTorrentItemPropertyDownloadStatus];
    return [dictionary writeToFile:filePath atomically:YES];
}

- (void)playWithHandler:(PTTorrentStreamerReadyToPlay)handler {
    if (_downloadStatus != PTTorrentDownloadStatusFinished) return;
    self.readyToPlayBlock = handler;
    [self startWebServerAndPlay];
}

- (void)stopPlaying {
    if (self.mediaServer.isRunning) [self.mediaServer stop];
    [self.mediaServer removeAllHandlers];
    self.readyToPlayBlock = nil;
}

- (void)cancelStreamingAndDeleteData:(BOOL)deleteData {
    NSString *savePath = _savePath;
    NSString *fileName = _fileName;
    long long requiredSpace = _requiredSpace;
    long long totalDownloaded = _totalDownloaded;
    libtorrent::torrent_status status = self.status;
    bool isFinished = self.isFinished;
    
    [super cancelStreamingAndDeleteData:deleteData];
    
    _savePath = savePath;
    _fileName = fileName;
    _requiredSpace = requiredSpace;
    _totalDownloaded = totalDownloaded;
    self.status = status;
    self.isFinished = isFinished;
    
    if (isFinished) {
        self.torrentStatus = {1, 1, 0, 0, 0, 0};
    }
}

@end
