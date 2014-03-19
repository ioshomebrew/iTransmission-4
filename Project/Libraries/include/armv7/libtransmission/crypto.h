/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: crypto.h 13625 2012-12-05 17:29:46Z jordan $
 */

#ifndef TR_ENCRYPTION_H
#define TR_ENCRYPTION_H

#ifndef __TRANSMISSION__
#error only libtransmission should #include this header.
#endif

#include <inttypes.h>

#include "utils.h" /* TR_GNUC_NULL_TERMINATED */

/**
*** @addtogroup peers
*** @{
**/

#include <openssl/dh.h> /* RC4_KEY */
#include <openssl/rc4.h> /* DH */

enum
{
    KEY_LEN = 96
};

/** @brief Holds state information for encrypted peer communications */
typedef struct
{
    RC4_KEY         dec_key;
    RC4_KEY         enc_key;
    DH *            dh;
    uint8_t         myPublicKey[KEY_LEN];
    uint8_t         mySecret[KEY_LEN];
    uint8_t         torrentHash[SHA_DIGEST_LENGTH];
    bool            isIncoming;
    bool            torrentHashIsSet;
    bool            mySecretIsSet;
}
tr_crypto;

/** @brief construct a new tr_crypto object */
void tr_cryptoConstruct (tr_crypto * crypto, const uint8_t * torrentHash, bool isIncoming);

/** @brief destruct an existing tr_crypto object */
void tr_cryptoDestruct (tr_crypto * crypto);


void tr_cryptoSetTorrentHash (tr_crypto * crypto, const uint8_t * torrentHash);

const uint8_t* tr_cryptoGetTorrentHash (const tr_crypto * crypto);

int            tr_cryptoHasTorrentHash (const tr_crypto * crypto);

const uint8_t* tr_cryptoComputeSecret (tr_crypto *     crypto,
                                       const uint8_t * peerPublicKey);

const uint8_t* tr_cryptoGetMyPublicKey (const tr_crypto * crypto,
                                        int *             setme_len);

void           tr_cryptoDecryptInit (tr_crypto * crypto);

void           tr_cryptoDecrypt (tr_crypto *  crypto,
                                 size_t       buflen,
                                 const void * buf_in,
                                 void *       buf_out);

void           tr_cryptoEncryptInit (tr_crypto * crypto);

void           tr_cryptoEncrypt (tr_crypto *  crypto,
                                 size_t       buflen,
                                 const void * buf_in,
                                 void *       buf_out);

/* @} */

/**
*** @addtogroup utils Utilities
*** @{
**/


/** @brief generate a SHA1 hash from one or more chunks of memory */
void tr_sha1 (uint8_t    * setme,
              const void * content1,
              int          content1_len,
              ...) TR_GNUC_NULL_TERMINATED;


/** @brief returns a random number in the range of [0...n) */
int tr_cryptoRandInt (int n);

/**
 * @brief returns a pseudorandom number in the range of [0...n)
 *
 * This is faster, BUT WEAKER, than tr_cryptoRandInt () and never
 * be used in sensitive cases.
 * @see tr_cryptoRandInt ()
 */
int            tr_cryptoWeakRandInt (int n);

/** @brief fill a buffer with random bytes */
void  tr_cryptoRandBuf (void * buf, size_t len);

/** @brief generate a SSHA password from its plaintext source */
char*  tr_ssha1 (const void * plaintext);

/** @brief Validate a test password against the a ssha1 password */
bool tr_ssha1_matches (const char * ssha1, const char * pass);

/* @} */

#endif
