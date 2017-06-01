

#import "PTTorrentDownload.h"
#import "PTSize.h"
#import "PTTorrentStreamer+Protected.h"
#import "PTTorrentDownloadManager.h"

@implementation PTTorrentDownload {
    PTTorrentDownloadStatus _downloadStatus;
    NSString *_uniqueIdentifier;
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

- (instancetype)initWithUniqueIdentifier:(NSString *)uniqueIdentifier {
    self = [super init];
    if (self) {
        _downloadStatus = PTTorrentDownloadStatusProcessing;
        _uniqueIdentifier = uniqueIdentifier;
    }
    return self;
}

- (NSString *)uniqueIdentifier {
    return _uniqueIdentifier;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[PTTorrentDownload class]]) {
        return [((PTTorrentDownload *)object).uniqueIdentifier isEqualToString:self.uniqueIdentifier];
    }
    return NO;
}

- (NSUInteger)hash {
    return [_uniqueIdentifier hash];
}


- (void)startDownloadingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink {
    __weak __typeof__(self) weakSelf = self;
    
    [super startStreamingFromFileOrMagnetLink:filePathOrMagnetLink uniqueIdentifier:_uniqueIdentifier progress:^(PTTorrentStatus status) {
        PTTorrentDownloadStatus downloadStatus = status.totalProgress < 1 ? PTTorrentDownloadStatusDownloading : PTTorrentDownloadStatusFinished;
        
        [weakSelf setDownloadStatus:downloadStatus];
        [weakSelf setTorrentStatus:status];
        
        if (downloadStatus == PTTorrentDownloadStatusFinished) {
            [super cancelStreamingAndDeleteData:NO];
        }
    } readyToPlay:nil failure:^(NSError * _Nonnull error) {
        id<PTTorrentDownloadManagerListener> delegate = weakSelf.delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(downloadDidFail:withError:)]) {
            [weakSelf setDownloadStatus:PTTorrentDownloadStatusFailed];
            [delegate downloadDidFail:weakSelf withError:error];
        }
    }];
}


- (void)setTorrentStatus:(PTTorrentStatus)torrentStatus {
    if (PTTorrentStatusEqualToStatus(torrentStatus, _torrentStatus)) return;
    
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
    
    [super cancelStreamingAndDeleteData:YES];
    [self setDownloadStatus:PTTorrentDownloadStatusFinished];
}

- (void)pause {
    if (_downloadStatus != PTTorrentDownloadStatusDownloading) return;
    
    _session->pause();
    [self setDownloadStatus:PTTorrentDownloadStatusPaused];
}

- (void)resume {
    if (_downloadStatus != PTTorrentDownloadStatusPaused) return;
    
    _session->resume();
    [self setDownloadStatus:PTTorrentDownloadStatusDownloading];
}

- (BOOL)delete {
    NSAssert(_downloadStatus != PTTorrentDownloadStatusPaused && _downloadStatus != PTTorrentDownloadStatusDownloading, @"This method should not be used to stop downloads, only to delete a pre-existing download.");
    
    NSString *path = [[[self class] downloadDirectory] stringByAppendingPathComponent:_uniqueIdentifier];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
