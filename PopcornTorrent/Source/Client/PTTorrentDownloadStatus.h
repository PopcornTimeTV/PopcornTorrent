

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PTTorrentDownloadStatus) {
    PTTorrentDownloadStatusPaused,
    PTTorrentDownloadStatusDownloading,
    PTTorrentDownloadStatusFinished,
    PTTorrentDownloadStatusFailed,
    PTTorrentDownloadStatusProcessing
};
