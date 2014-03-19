/*
 * This file Copyright (C) Mnemosyne LLC
 *
 * This file is licensed by the GPL version 2. Works owned by the
 * Transmission project are granted a special exemption to clause 2 (b)
 * so that the bulk of its code can remain under the MIT license.
 * This exemption does not extend to derived works not owned by
 * the Transmission project.
 *
 * $Id: utils.h 13991 2013-02-09 04:05:03Z jordan $
 */

#ifndef TR_UTILS_H
#define TR_UTILS_H 1

#include <inttypes.h>
#include <stddef.h> /* size_t */
#include <time.h> /* time_t */

#ifdef __cplusplus
extern "C" {
#endif

/***
****
***/

/**
 * @addtogroup utils Utilities
 * @{
 */

#ifndef UNUSED
 #ifdef __GNUC__
  #define UNUSED __attribute__ ((unused))
 #else
  #define UNUSED
 #endif
#endif

#ifndef TR_GNUC_PRINTF
 #ifdef __GNUC__
  #define TR_GNUC_PRINTF(fmt, args) __attribute__ ((format (printf, fmt, args)))
 #else
  #define TR_GNUC_PRINTF(fmt, args)
 #endif
#endif

#ifndef TR_GNUC_NONNULL
 #ifdef __GNUC__
  #define TR_GNUC_NONNULL(...) __attribute__ ((nonnull (__VA_ARGS__)))
 #else
  #define TR_GNUC_NONNULL(...)
 #endif
#endif

#ifndef TR_GNUC_NULL_TERMINATED
 #if __GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 3)
  #define TR_GNUC_NULL_TERMINATED __attribute__ ((__sentinel__))
  #define TR_GNUC_HOT __attribute ((hot))
 #else
  #define TR_GNUC_NULL_TERMINATED
  #define TR_GNUC_HOT
 #endif
#endif

#if __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 96)
 #define TR_GNUC_MALLOC __attribute__ ((__malloc__))
#else
 #define TR_GNUC_MALLOC
#endif


/***
****
***/

const char * tr_strip_positional_args (const char * fmt);

#if !defined (_)
 #if defined (HAVE_LIBINTL_H) && !defined (SYS_DARWIN)
  #include <libintl.h>
  #define _(a) gettext (a)
 #else
  #define _(a)(a)
 #endif
#endif

/* #define DISABLE_GETTEXT */
#ifndef DISABLE_GETTEXT
 #if defined (WIN32) || defined (TR_LIGHTWEIGHT)
   #define DISABLE_GETTEXT
 #endif
#endif
#ifdef DISABLE_GETTEXT
 #undef _
 #define _(a) tr_strip_positional_args (a)
#endif

/****
*****
****/

/**
 * @brief Rich Salz's classic implementation of shell-style pattern matching for ?, \, [], and * characters.
 * @return 1 if the pattern matches, 0 if it doesn't, or -1 if an error occured
 */
bool tr_wildmat (const char * text, const char * pattern) TR_GNUC_NONNULL (1,2);

/** @brief Portability wrapper for basename () that uses the system implementation if available */
char* tr_basename (const char * path) TR_GNUC_MALLOC;

/** @brief Portability wrapper for dirname () that uses the system implementation if available */
char* tr_dirname (const char * path) TR_GNUC_MALLOC;

/**
 * Like mkdir, but makes parent directories as needed.
 *
 * @return zero on success, or -1 if an error occurred
 * (in which case errno is set appropriately).
 */
int tr_mkdirp (const char * path, int permissions) TR_GNUC_NONNULL (1);

/** @brief Portability wrapper for mkdtemp () that uses the system implementation if available */
char* tr_mkdtemp (char * _template);


/**
 * @brief Loads a file and returns its contents.
 * On failure, NULL is returned and errno is set.
 */
uint8_t* tr_loadFile (const char * filename, size_t * size) TR_GNUC_MALLOC
                                                             TR_GNUC_NONNULL (1);


/** @brief build a filename from a series of elements using the
           platform's correct directory separator. */
char* tr_buildPath (const char * first_element, ...) TR_GNUC_NULL_TERMINATED
                                                      TR_GNUC_MALLOC;

bool tr_fileExists (const char * filename, time_t * mtime);

/**
 * @brief Get available disk space (in bytes) for the specified folder.
 * @return zero or positive integer on success, -1 in case of error.
 */
int64_t tr_getDirFreeSpace (const char * path);


struct event;

/**
 * @brief Convenience wrapper around timer_add () to have a timer wake up in a number of seconds and microseconds
 * @param timer
 * @param seconds
 * @param microseconds
 */
void tr_timerAdd (struct event * timer, int seconds, int microseconds) TR_GNUC_NONNULL (1);

/**
 * @brief Convenience wrapper around timer_add () to have a timer wake up in a number of milliseconds
 * @param timer
 * @param milliseconds
 */
void tr_timerAddMsec (struct event * timer, int milliseconds) TR_GNUC_NONNULL (1);


/** @brief return the current date in milliseconds */
uint64_t tr_time_msec (void);

/** @brief sleep the specified number of milliseconds */
void tr_wait_msec (long int delay_milliseconds);

/**
 * @brief make a copy of 'str' whose non-utf8 content has been corrected or stripped
 * @return a newly-allocated string that must be freed with tr_free ()
 * @param str the string to make a clean copy of
 * @param len the length of the string to copy. If -1, the entire string is used.
 */
char* tr_utf8clean (const char * str, int len) TR_GNUC_MALLOC;


/***
****
***/

/* Sometimes the system defines MAX/MIN, sometimes not.
   In the latter case, define those here since we will use them */
#ifndef MAX
 #define MAX(a, b)((a) > (b) ? (a) : (b))
#endif
#ifndef MIN
 #define MIN(a, b)((a) > (b) ? (b) : (a))
#endif

/***
****
***/

/** @brief Portability wrapper around malloc () in which `0' is a safe argument */
void* tr_malloc (size_t size);

/** @brief Portability wrapper around calloc () in which `0' is a safe argument */
void* tr_malloc0 (size_t size);

/** @brief Portability wrapper around free () in which `NULL' is a safe argument */
void tr_free (void * p);

/**
 * @brief make a newly-allocated copy of a chunk of memory
 * @param src the memory to copy
 * @param byteCount the number of bytes to copy
 * @return a newly-allocated copy of `src' that can be freed with tr_free ()
 */
void* tr_memdup (const void * src, size_t byteCount);

#define tr_new(struct_type, n_structs)           \
  ((struct_type *) tr_malloc (sizeof (struct_type) * ((size_t)(n_structs))))

#define tr_new0(struct_type, n_structs)          \
  ((struct_type *) tr_malloc0 (sizeof (struct_type) * ((size_t)(n_structs))))

#define tr_renew(struct_type, mem, n_structs)    \
  ((struct_type *) realloc ((mem), sizeof (struct_type) * ((size_t)(n_structs))))

void* tr_valloc (size_t bufLen);

/**
 * @brief make a newly-allocated copy of a substring
 * @param in is a void* so that callers can pass in both signed & unsigned without a cast
 * @param len length of the substring to copy. if a length less than zero is passed in, strlen (len) is used
 * @return a newly-allocated copy of `in' that can be freed with tr_free ()
 */
char* tr_strndup (const void * in, int len) TR_GNUC_MALLOC;

/**
 * @brief make a newly-allocated copy of a string
 * @param in is a void* so that callers can pass in both signed & unsigned without a cast
 * @return a newly-allocated copy of `in' that can be freed with tr_free ()
 */
char* tr_strdup (const void * in);

/**
 * @brief like strcmp () but gracefully handles NULL strings
 */
int tr_strcmp0 (const char * str1, const char * str2);



struct evbuffer;

char* evbuffer_free_to_str (struct evbuffer * buf);

/** @brief similar to bsearch () but returns the index of the lower bound */
int tr_lowerBound (const void * key,
                   const void * base,
                   size_t       nmemb,
                   size_t       size,
                   int     (* compar)(const void* key, const void* arrayMember),
                   bool       * exact_match) TR_GNUC_HOT TR_GNUC_NONNULL (1,5,6);

/** @brief moves the best k items to the first slots in the array. O(n) */
void tr_quickfindFirstK (void * base, size_t nmemb, size_t size,
                         int (*compar)(const void *, const void *), size_t k);

/**
 * @brief sprintf () a string into a newly-allocated buffer large enough to hold it
 * @return a newly-allocated string that can be freed with tr_free ()
 */
char* tr_strdup_printf (const char * fmt, ...) TR_GNUC_PRINTF (1, 2)
                                                TR_GNUC_MALLOC;

/**
 * @brief Translate a block of bytes into base64
 * @return a newly-allocated string that can be freed with tr_free ()
 */
char* tr_base64_encode (const void * input,
                        int          inlen,
                        int        * outlen) TR_GNUC_MALLOC;

/**
 * @brief Translate a block of bytes from base64 into raw form
 * @return a newly-allocated string that can be freed with tr_free ()
 */
char* tr_base64_decode (const void * input,
                        int          inlen,
                        int        * outlen) TR_GNUC_MALLOC;

/** @brief Portability wrapper for strlcpy () that uses the system implementation if available */
size_t tr_strlcpy (char * dst, const void * src, size_t siz);

/** @brief Portability wrapper for snprintf () that uses the system implementation if available */
int tr_snprintf (char * buf, size_t buflen,
                 const char * fmt, ...) TR_GNUC_PRINTF (3, 4) TR_GNUC_NONNULL (1,3);

/** @brief Convenience wrapper around strerorr () guaranteed to not return NULL
    @param errno */
const char* tr_strerror (int);

/** @brief strips leading and trailing whitspace from a string
    @return the stripped string */
char* tr_strstrip (char * str);

/** @brief Returns true if the string ends with the specified case-insensitive suffix */
bool tr_str_has_suffix (const char *str, const char *suffix);


/** @brief Portability wrapper for memmem () that uses the system implementation if available */
const char* tr_memmem (const char * haystack, size_t haystack_len,
                       const char * needle, size_t needle_len);

/** @brief Portability wrapper for strsep () that uses the system implementation if available */
char* tr_strsep (char ** str, const char * delim);

/***
****
***/

int compareInt (const void * va, const void * vb);

void tr_sha1_to_hex (char * out, const uint8_t * sha1) TR_GNUC_NONNULL (1,2);

void tr_hex_to_sha1 (uint8_t * out, const char * hex) TR_GNUC_NONNULL (1,2);

/** @brief convenience function to determine if an address is an IP address (IPv4 or IPv6) */
bool tr_addressIsIP (const char * address);

/** @brief return true if the url is a http or https url that Transmission understands */
bool tr_urlIsValidTracker (const char * url) TR_GNUC_NONNULL (1);

/** @brief return true if the url is a [ http, https, ftp, ftps ] url that Transmission understands */
bool tr_urlIsValid (const char * url, int url_len) TR_GNUC_NONNULL (1);

/** @brief parse a URL into its component parts
    @return zero on success or an error number if an error occurred */
int  tr_urlParse (const char * url,
                  int          url_len,
                  char      ** setme_scheme,
                  char      ** setme_host,
                  int        * setme_port,
                  char      ** setme_path) TR_GNUC_NONNULL (1);


/** @brief return TR_RATIO_NA, TR_RATIO_INF, or a number in [0..1]
    @return TR_RATIO_NA, TR_RATIO_INF, or a number in [0..1] */
double tr_getRatio (uint64_t numerator, uint64_t denominator);

/**
 * @brief Given a string like "1-4" or "1-4,6,9,14-51", this returns a
 *        newly-allocated array of all the integers in the set.
 * @return a newly-allocated array of integers that must be freed with tr_free (),
 *         or NULL if a fragment of the string can't be parsed.
 *
 * For example, "5-8" will return [ 5, 6, 7, 8 ] and setmeCount will be 4.
 */
int* tr_parseNumberRange (const char * str,
                          int str_len,
                          int * setmeCount) TR_GNUC_MALLOC TR_GNUC_NONNULL (1);


/**
 * @brief truncate a double value at a given number of decimal places.
 *
 * this can be used to prevent a printf () call from rounding up:
 * call with the decimal_places argument equal to the number of
 * decimal places in the printf ()'s precision:
 *
 * - printf ("%.2f%%",           99.999  ) ==> "100.00%"
 *
 * - printf ("%.2f%%", tr_truncd (99.999, 2)) ==>  "99.99%"
 *             ^                        ^
 *             |   These should match   |
 *             +------------------------+
 */
double tr_truncd (double x, int decimal_places);

/* return a percent formatted string of either x.xx, xx.x or xxx */
char* tr_strpercent (char * buf, double x, size_t buflen);

/**
 * @param buf the buffer to write the string to
 * @param buflef buf's size
 * @param ratio the ratio to convert to a string
 * @param the string represntation of "infinity"
 */
char* tr_strratio (char * buf, size_t buflen, double ratio, const char * infinity) TR_GNUC_NONNULL (1,4);

/** @brief Portability wrapper for localtime_r () that uses the system implementation if available */
struct tm * tr_localtime_r (const time_t *_clock, struct tm *_result);


/**
 * @brief move a file
 * @return 0 on success; otherwise, return -1 and set errno
 */
int tr_moveFile (const char * oldpath, const char * newpath,
                 bool * renamed) TR_GNUC_NONNULL (1,2);

/** @brief Portability wrapper for rename () */
int tr_rename (const char * oldpath_utf8, const char * newpath_utf8);

/** @brief Portability wrapper for remove () */
int tr_remove (const char * pathname_utf8);

/** @brief Test to see if the two filenames point to the same file. */
bool tr_is_same_file (const char * filename1, const char * filename2);

/** @brief convenience function to remove an item from an array */
void tr_removeElementFromArray (void         * array,
                                unsigned int   index_to_remove,
                                size_t         sizeof_element,
                                size_t         nmemb);

/***
****
***/

/** @brief Private libtransmission variable that's visible only for inlining in tr_time () */
extern time_t __tr_current_time;

/**
 * @brief very inexpensive form of time (NULL)
 * @return the current epoch time in seconds
 *
 * This function returns a second counter that is updated once per second.
 * If something blocks the libtransmission thread for more than a second,
 * that counter may be thrown off, so this function is not guaranteed
 * to always be accurate. However, it is *much* faster when 100% accuracy
 * isn't needed
 */
static inline time_t tr_time (void) { return __tr_current_time; }

/** @brief Private libtransmission function to update tr_time ()'s counter */
static inline void tr_timeUpdate (time_t now) { __tr_current_time = now; }

#ifdef WIN32
 #include <windef.h> /* MAX_PATH */
 #define TR_PATH_MAX (MAX_PATH + 1)
#else
 #include <limits.h> /* PATH_MAX */
 #ifdef PATH_MAX
  #define TR_PATH_MAX PATH_MAX
 #else
  #define TR_PATH_MAX 4096
 #endif
#endif

/** @brief Portability wrapper for realpath () that uses the system implementation if available.
    @param resolved_path should be TR_PATH_MAX or larger */
char* tr_realpath (const char *path, char * resolved_path);

/** @brief Portability wrapper for htonll () that uses the system implementation if available */
uint64_t tr_htonll (uint64_t);

/** @brief Portability wrapper for htonll () that uses the system implementation if available */
uint64_t tr_ntohll (uint64_t);

/***
****
***/

/* example: tr_formatter_size_init (1024, _ ("KiB"), _ ("MiB"), _ ("GiB"), _ ("TiB")); */

void tr_formatter_size_init (unsigned int kilo, const char * kb, const char * mb,
                                                const char * gb, const char * tb);

void tr_formatter_speed_init (unsigned int kilo, const char * kb, const char * mb,
                                                 const char * gb, const char * tb);

void tr_formatter_mem_init (unsigned int kilo, const char * kb, const char * mb,
                                               const char * gb, const char * tb);

extern unsigned int tr_speed_K;
extern unsigned int tr_mem_K;
extern unsigned int tr_size_K;

/* format a speed from KBps into a user-readable string. */
char* tr_formatter_speed_KBps (char * buf, double KBps, size_t buflen);

/* format a memory size from bytes into a user-readable string. */
char* tr_formatter_mem_B (char * buf, int64_t bytes, size_t buflen);

/* format a memory size from MB into a user-readable string. */
static inline char* tr_formatter_mem_MB (char * buf, double MBps, size_t buflen) { return tr_formatter_mem_B (buf, MBps * tr_mem_K * tr_mem_K, buflen); }

/* format a file size from bytes into a user-readable string. */
char* tr_formatter_size_B (char * buf, int64_t bytes, size_t buflen);

void tr_formatter_get_units (void * dict);

/***
****
***/

#ifdef __cplusplus
}
#endif

/** @} */

#endif
