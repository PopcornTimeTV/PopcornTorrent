

#import <Foundation/Foundation.h>
#import "PTTorrentStreamer.h"
#import "PTTorrentDownloadStatus.h"


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
 The delegate `PTTorrentDownloadManagerListener` requests.
 */
@property (weak, nonatomic, nullable) id<PTTorrentDownloadManagerListener> delegate;

/**
 Stops the current download and deletes all download progress (if any). Once you call stop you can not resume the download - `startDownloadingFromFileOrMagnetLink:` will have to be called again.
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
 Begins streaming of a torrent. To recieve status updates about the download, assign an object to the `delegate` property.
 
 @param filePathOrMagnetLink    The direct link of a locally stored `.torrent` file or a `magnet:?` link.
 
 @warning   Usage of this method is discouraged. Use `PTTorrentDownloadManager` class instead.
 */
- (void)startDownloadingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink;

#pragma mark - Hidden methods

- (void) __unavailable startStreamingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink
                                  progress:(PTTorrentStreamerProgress _Nullable)progress
                               readyToPlay:(PTTorrentStreamerReadyToPlay _Nullable)readyToPlay
                                   failure:(PTTorrentStreamerFailure _Nullable)failure;
+ (instancetype) __unavailable sharedStreamer;
- (void) __unavailable cancelStreamingAndDeleteData:(BOOL)deleteData;

@end

NS_ASSUME_NONNULL_END
