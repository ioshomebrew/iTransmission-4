/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: torrent-magnet.h 13625 2012-12-05 17:29:46Z jordan $
 */

#ifndef __TRANSMISSION__
 #error only libtransmission should #include this header.
#endif

#ifndef TR_TORRENT_MAGNET_H
#define TR_TORRENT_MAGNET_H 1

#include <time.h>

enum
{
    /* defined by BEP #9 */
    METADATA_PIECE_SIZE = (1024 * 16)
};

void* tr_torrentGetMetadataPiece (tr_torrent * tor, int piece, int * len);

void tr_torrentSetMetadataPiece (tr_torrent * tor, int piece, const void * data, int len);

bool tr_torrentGetNextMetadataRequest (tr_torrent * tor, time_t now, int * setme);

void tr_torrentSetMetadataSizeHint (tr_torrent * tor, int metadata_size);

double tr_torrentGetMetadataPercent (const tr_torrent * tor);

#endif
