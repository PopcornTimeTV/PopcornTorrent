

#import "PTTorrentDownloadManager.h"

@interface PTTorrentDownloadManager ()

@property (strong, nonatomic, nonnull) NSHashTable<id<PTTorrentDownloadManagerListener>> *listeners;

@end

@implementation PTTorrentDownloadManager {
    NSMutableArray<PTTorrentDownload *>* _activeDownloads;
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
    [download startDownloadingFromFileOrMagnetLink:filePathOrMagnetLink listeners:_listeners];
    return download;
}

- (NSArray<PTTorrentDownload *> *)activeDownloads {
    return _activeDownloads;
}

- (void)stopDownload:(PTTorrentDownload *)download {
    [download stop];
    [_activeDownloads removeObject:download];
}

- (void)resumeDownload:(PTTorrentDownload *)download {
    [download resume];
}

- (void)pauseDownload:(PTTorrentDownload *)download {
    [download pause];
}

@end
