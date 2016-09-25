
#import <Foundation/Foundation.h>

typedef struct {
    float bufferingProgress;
    float totalProgreess;
    int downloadSpeed;
    int upoadSpeed;
    int seeds;
    int peers;
} PTTorrentStatus;

#pragma clang assume_nonnull begin

typedef void (^PTTorrentStreamerProgress)(PTTorrentStatus status);
typedef void (^PTTorrentStreamerReadyToPlay)(NSURL * _Nonnull videoFileURL, NSURL * _Nonnull videoFilePath);
typedef void (^PTTorrentStreamerFailure)(NSError * _Nonnull error);

@interface PTTorrentStreamer : NSObject

+ (instancetype)sharedStreamer;

- (void)startStreamingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink
                                  progress:(PTTorrentStreamerProgress)progreess
                               readyToPlay:(PTTorrentStreamerReadyToPlay)readyToPlay
                                   failure:(PTTorrentStreamerFailure)failure;

- (void)cancelStreamingAndDeleteData:(BOOL) deleteData;

@property (assign, nonatomic) PTTorrentStatus torrentStatus;

@end

#pragma clang assume_nonnull end
