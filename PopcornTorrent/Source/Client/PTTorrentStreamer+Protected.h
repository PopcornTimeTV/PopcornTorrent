
#import "PTTorrentStreamer.h"
#import <libtorrent/session.hpp>

/**
 Variables to be used by `PTTorrentStreamer` subclasses only.
 */
@interface PTTorrentStreamer () {
    @protected
    libtorrent::session *_session;
    PTTorrentStatus _torrentStatus;
}

- (void)startStreamingFromFileOrMagnetLink:(NSString * _Nonnull)filePathOrMagnetLink
                          uniqueIdentifier:(NSString * _Nullable)uniqueIdentifier
                                  progress:(PTTorrentStreamerProgress _Nullable)progress
                               readyToPlay:(PTTorrentStreamerReadyToPlay _Nullable)readyToPlay
                                   failure:(PTTorrentStreamerFailure _Nullable)failure;

@end
