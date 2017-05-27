

#import "PTTorrentDownload.h"
#import "PTSize.h"
#import "PTTorrentDownloadManager.h"
#import "PTTorrentStreamer+Protected.h"

@interface PTTorrentDownload ()

@property (weak, nonatomic) NSHashTable<id<PTTorrentDownloadManagerListener>> *listeners;

@end

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

- (void)startDownloadingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink listeners:(NSHashTable<id<PTTorrentDownloadManagerListener>> *)listeners {
    _listeners = listeners;
    __weak __typeof__(self) weakSelf = self;
    
    [super startStreamingFromFileOrMagnetLink:filePathOrMagnetLink progress:^(PTTorrentStatus status) {
        [weakSelf setDownloadStatus:status.totalProgress < 1 ? PTTorrentDownloadStatusDownloading : PTTorrentDownloadStatusFinished];
        
        for (id<PTTorrentDownloadManagerListener> listener in weakSelf.listeners) {
            if (listener && [listener respondsToSelector:@selector(torrentStatusDidChange:forDownload:)]) {
                _torrentStatus = status;
                [listener torrentStatusDidChange:status forDownload:weakSelf];
            }
        }
    } readyToPlay:nil failure:^(NSError * _Nonnull error) {
        [weakSelf setDownloadStatus:PTTorrentDownloadStatusFailed];
        
        for (id<PTTorrentDownloadManagerListener> listener in weakSelf.listeners) {
            if (listener && [listener respondsToSelector:@selector(downloadDidFail:withError:)]) {
                [listener downloadDidFail:self withError:error];
            }
        }
    }];
}

- (void)setDownloadStatus:(PTTorrentDownloadStatus)downloadStatus {
    if (downloadStatus == _downloadStatus) return;
    
    _downloadStatus = downloadStatus;
    
    for (id<PTTorrentDownloadManagerListener> listener in _listeners) {
        if (listener && [listener respondsToSelector:@selector(downloadStatusDidChange:forDownload:)]) {
            [listener downloadStatusDidChange:downloadStatus forDownload:self];
        }
    }
}

- (void)stop {
    if (_downloadStatus == PTTorrentDownloadStatusStopped) return;
    
    [super cancelStreamingAndDeleteData:YES];
    [self setDownloadStatus:PTTorrentDownloadStatusStopped];
    _listeners = nil;
}

- (void)pause {
    if (_downloadStatus == PTTorrentDownloadStatusPaused || _downloadStatus == PTTorrentDownloadStatusStopped || _downloadStatus == PTTorrentDownloadStatusFailed) return;
    
    _session->pause();
    [self setDownloadStatus:PTTorrentDownloadStatusPaused];
}

- (void)resume {
    if (_downloadStatus == PTTorrentDownloadStatusDownloading || _downloadStatus == PTTorrentDownloadStatusStopped || _downloadStatus == PTTorrentDownloadStatusFailed) return;
    
    _session->resume();
    [self setDownloadStatus:PTTorrentDownloadStatusDownloading];
}

@end
