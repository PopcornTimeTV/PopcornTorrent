

#import "PTTorrentDownload.h"
#import "PTSize.h"
#import "PTTorrentStreamer+Protected.h"
#import "PTTorrentDownloadManager.h"

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

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadStatus = PTTorrentDownloadStatusProcessing;
    }
    return self;
}


- (void)startDownloadingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink {
    __weak __typeof__(self) weakSelf = self;
    
    [super startStreamingFromFileOrMagnetLink:filePathOrMagnetLink progress:^(PTTorrentStatus status) {
        [weakSelf setDownloadStatus:status.totalProgress < 1 ? PTTorrentDownloadStatusDownloading : PTTorrentDownloadStatusFinished];
        [weakSelf setTorrentStatus:status];
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
    
    if (downloadStatus == PTTorrentDownloadStatusFinished) {
        [super cancelStreamingAndDeleteData:NO];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(downloadStatusDidChange:forDownload:)]) {
        [_delegate downloadStatusDidChange:downloadStatus forDownload:self];
    }
}

- (void)stop {
    if (_downloadStatus == PTTorrentDownloadStatusStopped) return;
    
    [super cancelStreamingAndDeleteData:YES];
    [self setDownloadStatus:PTTorrentDownloadStatusStopped];
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

@end
