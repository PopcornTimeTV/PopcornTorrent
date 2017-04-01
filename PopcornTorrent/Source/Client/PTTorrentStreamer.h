
#import <Foundation/Foundation.h>

typedef struct {
    float bufferingProgress;
    float totalProgress;
    int downloadSpeed;
    int uploadSpeed;
    int seeds;
    int peers;
} PTTorrentStatus;

/**
 Block called when the status of the currently streamed torrent is called.
 
 @param status  The buffering progress of the current piece of the torrent, overall buffering of the torrent, the current download speed, the current upload speed, the amount of active seeds downloading from and the amount of peers connected to.
 */
typedef void (^PTTorrentStreamerProgress)(PTTorrentStatus status);

/**
 Block called when the first piece of the torrent has sufficiently buffered enough for streaming.
 
 @param videoFileURL    The `GCDWebServer` url that the torrent should be streamed from.
 @param videoFilePath   The local path to the video file. This should not be used for streaming.
 */
typedef void (^PTTorrentStreamerReadyToPlay)(NSURL * _Nonnull videoFileURL, NSURL * _Nonnull videoFilePath);

/**
 Block called if there is a fatal error processing the torrent.
 
 @param error    The underlying error.
 */
typedef void (^PTTorrentStreamerFailure)(NSError * _Nonnull error);

NS_ASSUME_NONNULL_BEGIN

/**
 Posted when the status of the current Torrent changes finishes executing. To retrieve the current status, use the instance variable, `torrentStatus`.
 */
FOUNDATION_EXPORT NSNotificationName const PTTorrentStatusDidChangeNotification;

/**
 A class that streams magnet links or `.torrent` files to a `GCDWebServer`.
 */
@interface PTTorrentStreamer : NSObject
    
/**
  Shared singleton instance.
*/
+ (instancetype)sharedStreamer;
    

/**
 Begins streaming of a torrent.
 
 @param filePathOrMagnetLink    The direct link of a locally stored `.torrent` file or a `magnet:?` link.
 @param progress                Block containing useful information about the torrent currently being streamed. Called every time the `torrentStatus` variable changes.
 @param readyToPlay             Block called when the torrent has finished processing and is ready to begin being played.
 @param failure                 Block called if there is an error while processing the torrent.
*/
- (void)startStreamingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink
                                  progress:(PTTorrentStreamerProgress)progress
                               readyToPlay:(PTTorrentStreamerReadyToPlay)readyToPlay
                                   failure:(PTTorrentStreamerFailure)failure;

/**
 Cancels loading of the current torrent and optionally clears the download directory.
 
 @param deleteData  Pass `YES` to clear the download directory, `NO` to keep the downloaded directory.
 */
- (void)cancelStreamingAndDeleteData:(BOOL) deleteData;
    
/**
 Status of the torrent that is currently streaming. Will return all 0 struct if no torrent is being streamed.
 */
@property (assign, nonatomic) PTTorrentStatus torrentStatus;

@end

NS_ASSUME_NONNULL_END
