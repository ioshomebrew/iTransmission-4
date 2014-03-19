/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: trevent.h 13625 2012-12-05 17:29:46Z jordan $
 */

#ifndef __TRANSMISSION__
#error only libtransmission should #include this header.
#endif

#ifndef TR_EVENT_H
#define TR_EVENT_H

/**
**/

void   tr_eventInit (tr_session *);

void   tr_eventClose (tr_session *);

bool   tr_amInEventThread (const tr_session *);

void   tr_runInEventThread (tr_session *, void func (void*), void * user_data);

#endif
