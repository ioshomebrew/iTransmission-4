/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: magnet.h 13667 2012-12-14 04:34:42Z jordan $
 */

#ifndef __TRANSMISSION__
 #error only libtransmission should #include this header.
#endif

#ifndef TR_MAGNET_H
#define TR_MAGNET_H 1

#include "transmission.h"
#include "variant.h"

typedef struct tr_magnet_info
{
  uint8_t hash[20];

  char * displayName;

  int trackerCount;
  char ** trackers;

  int webseedCount;
  char ** webseeds;
}
tr_magnet_info;

tr_magnet_info * tr_magnetParse (const char * uri);

struct tr_variant;

void tr_magnetCreateMetainfo (const tr_magnet_info *, tr_variant *);

void tr_magnetFree (tr_magnet_info * info);

#endif
