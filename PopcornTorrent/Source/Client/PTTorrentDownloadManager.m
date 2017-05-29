

#import "PTTorrentDownloadManager.h"
#import "PTTorrentDownload.h"
#import <objc/runtime.h>

@interface PTTorrentDownloadManager () <PTTorrentDownloadManagerListener>

@property (strong, nonatomic, nonnull) NSHashTable<id<PTTorrentDownloadManagerListener>> *listeners;

@end

@implementation PTTorrentDownloadManager {
    NSHashTable<PTTorrentDownload *>* _activeDownloads;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static PTTorrentDownloadManager *sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PTTorrentDownloadManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _listeners = [NSHashTable weakObjectsHashTable];
        _activeDownloads = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addListener:(id<PTTorrentDownloadManagerListener>)listener {
    if (![_listeners containsObject:listener]) {
        [_listeners addObject:listener];
    }
}

- (void)removeListener:(id<PTTorrentDownloadManagerListener>)listener {
    [_listeners removeObject:listener];
}

- (PTTorrentDownload *)startDownloadingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink {
    PTTorrentDownload *download = [PTTorrentDownload new];
    download.delegate = self;
    
    [_activeDownloads addObject:download];
    [download startDownloadingFromFileOrMagnetLink:filePathOrMagnetLink];
    
    return download;
}

- (NSHashTable<PTTorrentDownload *> *)activeDownloads {
    return _activeDownloads;
}

- (void)stopDownload:(PTTorrentDownload *)download {
    [download stop];
    download.delegate = nil;
    [_activeDownloads removeObject:download];
}

- (void)resumeDownload:(PTTorrentDownload *)download {
    [download resume];
}

- (void)pauseDownload:(PTTorrentDownload *)download {
    [download pause];
}

#pragma mark - PTTorrentDownloadManagerListener

- (void)torrentStatusDidChange:(PTTorrentStatus)torrentStatus forDownload:(PTTorrentDownload *)download {
    for (id<PTTorrentDownloadManagerListener> listener in _listeners) {
        if (listener && [listener respondsToSelector:@selector(torrentStatusDidChange:forDownload:)]) {
            [listener torrentStatusDidChange:download.torrentStatus forDownload:download];
        }
    }
}


- (void)downloadStatusDidChange:(PTTorrentDownloadStatus)downloadStatus forDownload:(PTTorrentDownload *)download {
    for (id<PTTorrentDownloadManagerListener> listener in _listeners) {
        if (listener && [listener respondsToSelector:@selector(downloadStatusDidChange:forDownload:)]) {
            [listener downloadStatusDidChange:download.downloadStatus forDownload:download];
        }
    }
    
    if (downloadStatus == PTTorrentDownloadStatusFinished) {
        download.delegate = nil;
        [_activeDownloads removeObject:download];
    }
}

- (void)downloadDidFail:(PTTorrentDownload *)download withError:(NSError *)error {
    for (id<PTTorrentDownloadManagerListener> listener in _listeners) {
        if (listener && [listener respondsToSelector:@selector(downloadDidFail:withError:)]) {
            [listener downloadDidFail:download withError:error];
        }
    }
}

@end
