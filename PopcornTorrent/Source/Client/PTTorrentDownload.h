

#import <Foundation/Foundation.h>
#import "PTTorrentStreamer.h"

typedef NS_ENUM(NSInteger, PTTorrentDownloadStatus) {
    PTTorrentDownloadStatusStopped,
    PTTorrentDownloadStatusPaused,
    PTTorrentDownloadStatusDownloading,
    PTTorrentDownloadStatusFinished,
    PTTorrentDownloadStatusFailed,
    PTTorrentDownloadStatusProcessing
};


@protocol PTTorrentDownloadManagerListener;

NS_ASSUME_NONNULL_BEGIN

/**
 A class that downloads magnet links or `.torrent` files.
 */
@interface PTTorrentDownload : PTTorrentStreamer

/**
 The status of the current download.
 */
@property (nonatomic, readonly) PTTorrentDownloadStatus downloadStatus;

/**
 Stops the current download and deletes all download progress (if any). Once you call stop you can not resume the download - `startDownloadingFromFileOrMagnetLink:listeners` will have to be called again.
 */
- (void)stop;

/**
 Resumes the current download (if possible).
 */
- (void)resume;

/**
 Pauses the current download.
 */
- (void)pause;

/**
 Begins streaming of a torrent.
 
 @param filePathOrMagnetLink    The direct link of a locally stored `.torrent` file or a `magnet:?` link.
 @param listeners               An array of weak listeners to recieve delegate requests. No strong references are held to these objects.
 */
- (void)startDownloadingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink listeners:(NSHashTable<id<PTTorrentDownloadManagerListener>> *)listeners;

#pragma mark - Hidden methods

- (void) __unavailable startStreamingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink
                                  progress:(PTTorrentStreamerProgress _Nullable)progress
                               readyToPlay:(PTTorrentStreamerReadyToPlay _Nullable)readyToPlay
                                   failure:(PTTorrentStreamerFailure _Nullable)failure;
+ (instancetype) __unavailable sharedStreamer;
- (void) __unavailable cancelStreamingAndDeleteData:(BOOL)deleteData;

@end

NS_ASSUME_NONNULL_END
