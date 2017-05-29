

#ifndef PTTorrentStatus_h
#define PTTorrentStatus_h

#include <stdbool.h>

typedef struct {
    float bufferingProgress;
    float totalProgress;
    int downloadSpeed;
    int uploadSpeed;
    int seeds;
    int peers;
} PTTorrentStatus;

static inline bool PTTorrentStatusEqualToStatus (PTTorrentStatus lhs, PTTorrentStatus rhs) {
    return lhs.bufferingProgress == rhs.bufferingProgress && lhs.totalProgress == rhs.totalProgress && lhs.downloadSpeed == rhs.downloadSpeed && lhs.uploadSpeed == rhs.uploadSpeed && lhs.seeds == rhs.seeds && lhs.peers == rhs.peers;
}

#endif
