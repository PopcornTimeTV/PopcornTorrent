
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

@end
