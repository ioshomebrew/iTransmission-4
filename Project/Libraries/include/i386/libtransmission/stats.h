/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: stats.h 13625 2012-12-05 17:29:46Z jordan $
 */

#ifndef __TRANSMISSION__
 #error only libtransmission should #include this header.
#endif

#ifndef TR_STATS_H
#define TR_STATS_H

void tr_statsInit          (tr_session * session);
void tr_statsClose         (tr_session * session);
void tr_statsSaveDirty     (tr_session * session);
void tr_statsAddUploaded   (tr_session * session, uint32_t bytes);
void tr_statsAddDownloaded (tr_session * session, uint32_t bytes);
void tr_statsFileCreated   (tr_session * session);

#endif
