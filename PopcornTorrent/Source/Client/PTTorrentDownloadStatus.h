

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PTTorrentDownloadStatus) {
    PTTorrentDownloadStatusStopped,
    PTTorrentDownloadStatusPaused,
    PTTorrentDownloadStatusDownloading,
    PTTorrentDownloadStatusFinished,
    PTTorrentDownloadStatusFailed,
    PTTorrentDownloadStatusProcessing
};
