

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
 A unique name for the download to set it apart from others.
 */
@property (strong, nonatomic, readonly) NSString *uniqueIdentifier;

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
 Deletes the current download.
 
 @return    Boolean indicating the success of the operation.
 
 @warning   This method should not be used to stop a download. If the download is running and this method is called, an exception will be raised.
 */
- (BOOL)delete;

/**
 Designated initialiser for the class.
 
 @param uniqueIdentifier  The unique identifier for the download.
 */
- (instancetype)initWithUniqueIdentifier:(NSString *)uniqueIdentifier NS_DESIGNATED_INITIALIZER;

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
- (instancetype) __unavailable init;
+ (instancetype) __unavailable new;

@end

NS_ASSUME_NONNULL_END
