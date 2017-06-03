

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

#endif
