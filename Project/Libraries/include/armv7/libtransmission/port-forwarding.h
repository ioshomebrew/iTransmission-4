/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: port-forwarding.h 13625 2012-12-05 17:29:46Z jordan $
 */

#ifndef __TRANSMISSION__
#error only libtransmission should #include this header.
#endif

#ifndef SHARED_H
#define SHARED_H 1

#include "transmission.h"

/**
 * @addtogroup port_forwarding Port Forwarding
 * @{
 */

struct tr_bindsockets;

typedef struct tr_shared tr_shared;

tr_shared* tr_sharedInit (tr_session*);

void       tr_sharedClose (tr_session *);

void       tr_sharedPortChanged (tr_session *);

void       tr_sharedTraversalEnable (tr_shared *, bool isEnabled);

tr_port    tr_sharedGetPeerPort (const tr_shared * s);

bool       tr_sharedTraversalIsEnabled (const tr_shared * s);

int        tr_sharedTraversalStatus (const tr_shared *);

/** @} */
#endif
