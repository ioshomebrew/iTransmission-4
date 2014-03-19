/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: handshake.h 13625 2012-12-05 17:29:46Z jordan $
 */

#ifndef __TRANSMISSION__
#error only libtransmission should #include this header.
#endif

#ifndef TR_HANDSHAKE_H
#define TR_HANDSHAKE_H

#include "transmission.h"
#include "net.h"

/** @addtogroup peers Peers
    @{ */

struct tr_peerIo;

/** @brief opaque struct holding hanshake state information.
           freed when the handshake is completed. */
typedef struct tr_handshake tr_handshake;

/* returns true on success, false on error */
typedef bool (*handshakeDoneCB)(struct tr_handshake * handshake,
                                   struct tr_peerIo    * io,
                                   bool                  readAnythingFromPeer,
                                   bool                  isConnected,
                                   const uint8_t       * peerId,
                                   void                * userData);

/** @brief instantiate a new handshake */
tr_handshake *         tr_handshakeNew (struct tr_peerIo * io,
                                        tr_encryption_mode encryptionMode,
                                        handshakeDoneCB    doneCB,
                                        void *             doneUserData);

const tr_address *     tr_handshakeGetAddr (const struct tr_handshake  * handshake,
                                            tr_port                    * port);

void                   tr_handshakeAbort (tr_handshake * handshake);

struct tr_peerIo*      tr_handshakeGetIO (tr_handshake * handshake);

struct tr_peerIo*      tr_handshakeStealIO (tr_handshake * handshake);


/** @} */
#endif
