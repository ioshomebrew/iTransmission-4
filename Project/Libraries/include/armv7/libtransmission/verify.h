/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: verify.h 13913 2013-01-31 21:58:25Z jordan $
 */

#ifndef __TRANSMISSION__
#error only libtransmission should #include this header.
#endif

#ifndef TR_VERIFY_H
#define TR_VERIFY_H 1

/**
 * @addtogroup file_io File IO
 * @{
 */

void tr_verifyAdd (tr_torrent           * tor,
                   tr_verify_done_func    callback_func,
                   void                 * callback_user_data);

void tr_verifyRemove (tr_torrent * tor);

void tr_verifyClose (tr_session *);

/* @} */

#endif
