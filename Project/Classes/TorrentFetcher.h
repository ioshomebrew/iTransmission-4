//
//  TorrentFetcher.h
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TorrentFetcher;
@protocol TorrentFetcherDelegate <NSObject>

- (void)torrentFetcher:(TorrentFetcher*)fetcher fetchedTorrentContent:(NSData*)data fromURL:(NSString*)url;
- (void)torrentFetcher:(TorrentFetcher*)fetcher failedToFetchFromURL:(NSString*)url withError:(NSError*)error;

@end
    

@interface TorrentFetcher : NSObject {
    NSURLConnection *fURLConnection;
    NSMutableData *fData;
    NSString *url;
    id<TorrentFetcherDelegate> fDelegate;
}
@property (nonatomic, retain) NSURLConnection *URLConnection;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) id<TorrentFetcherDelegate> delegate;

- (id)initWithURLString:(NSString*)url delegate:(id<TorrentFetcherDelegate>)d;
- (BOOL)validateLength:(long long)len;

@end
