

#import <Foundation/Foundation.h>
#import "PTTorrentDownloadStatus.h"
#import "PTTorrentStatus.h"

@class PTTorrentDownload;

NS_ASSUME_NONNULL_BEGIN

/**
 A listener protocol for receiving status updates for downloads.
 */
@protocol PTTorrentDownloadManagerListener <NSObject>

@optional

/**
 Called when the torrent status of a download changes.
 
 @param torrentStatus   The status of the torrent (speed, progress, seeds, peers etc.).
 @param download        The download that's status has changed.
 */
- (void)torrentStatusDidChange:(PTTorrentStatus)torrentStatus forDownload:(PTTorrentDownload *)download;

/**
 Called when the download status of a download changes.
 
 @param downloadStatus  The download status of the torrent (downloading, paused, stopped, failed etc.).
 @param download        The download that's status has changed.
 */
- (void)downloadStatusDidChange:(PTTorrentDownloadStatus)downloadStatus forDownload:(PTTorrentDownload *)download;

/**
 Called when a download fails.
 
 @param download    The download that has failed.
 @param error       The underlying error.
 */
- (void)downloadDidFail:(PTTorrentDownload *)download withError:(NSError *)error;

@end

/**
 A class that manages torrent downloads.
 */
@interface PTTorrentDownloadManager : NSObject

/**
 Signs the specified object up for `PTTorrentDownloadManagerListener` delegate requests.
 
 @param listener    The object to be signed up for delegate requests.
 */
- (void)addListener:(id<PTTorrentDownloadManagerListener>)listener;

/**
 Resigns the specified object from `PTTorrentDownloadManagerListener` delegate requests.
 
 @param listener    The object to be resigned from delegate requests.
 */
- (void)removeListener:(id<PTTorrentDownloadManagerListener>)listener;

/**
 Shared singleton instance.
 */
+ (instancetype)sharedManager;

/**
 Begins streaming of a torrent. To recieve status updates about the download, sign up for delegate requests using the  `addListener:` method.
 
 @param filePathOrMagnetLink    The direct link of a locally stored `.torrent` file or a `magnet:?` link.
 
 @return    The download instance.
 */
- (PTTorrentDownload *)startDownloadingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink;

/**
 Stops the specified download, deletes all download progress (if any) and removes the download object from the `activeDownloads` array.
 
 @param download    The download to stop.
 */
- (void)stopDownload:(PTTorrentDownload *)download;

/**
 Pauses the specified download.
 
 @param download    The download to pause.
 */
- (void)pauseDownload:(PTTorrentDownload *)download;

/**
 Resumes the specified download.
 
 @param download    The download to resume.
 */
- (void)resumeDownload:(PTTorrentDownload *)download;

/**
 An array of all the torrents currently downloading.
 */
@property (strong, nonatomic, readonly) NSHashTable<PTTorrentDownload *> *activeDownloads;

@end

NS_ASSUME_NONNULL_END


