/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: announcer-common.h 13625 2012-12-05 17:29:46Z jordan $
 */

#ifndef __LIBTRANSMISSION_VARIANT_MODULE___
 #error only libtransmission/variant-*.c should #include this header.
#endif

#ifndef _TR_VARIANT_COMMON_H_
#define _TR_VARIANT_COMMON_H_

typedef void (*VariantWalkFunc)(const tr_variant * val, void * user_data);

struct VariantWalkFuncs
{
  VariantWalkFunc intFunc;
  VariantWalkFunc boolFunc;
  VariantWalkFunc realFunc;
  VariantWalkFunc stringFunc;
  VariantWalkFunc dictBeginFunc;
  VariantWalkFunc listBeginFunc;
  VariantWalkFunc containerEndFunc;
};

void
tr_variantWalk (const tr_variant               * top,
                const struct VariantWalkFuncs  * walkFuncs,
                void                           * user_data,
                bool                             sort_dicts);

void tr_variantToBufJson (const tr_variant * top, struct evbuffer * buf, bool lean);

void tr_variantToBufBenc (const tr_variant * top, struct evbuffer * buf);

void tr_variantInit (tr_variant * v, char type);

int tr_jsonParse (const char    * source, /* Such as a filename. Only when logging an error */
                  const void    * vbuf,
                  size_t          len,
                  tr_variant    * setme_benc,
                  const char   ** setme_end);

/** @brief Private function that's exposed here only for unit tests */
int tr_bencParseInt (const uint8_t *  buf,
                     const uint8_t *  bufend,
                     const uint8_t ** setme_end,
                     int64_t *        setme_val);

/** @brief Private function that's exposed here only for unit tests */
int tr_bencParseStr (const uint8_t *  buf,
                     const uint8_t *  bufend,
                     const uint8_t ** setme_end,
                     const uint8_t ** setme_str,
                     size_t *         setme_strlen);

int tr_variantParseBenc (const void     * buf,
                         const void     * end,
                         tr_variant     * top,
                         const char ** setme_end);



#endif /* _TR_VARIANT_COMMON_H_ */
