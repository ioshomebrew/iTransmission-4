//
//  TorrentFetcher.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "TorrentFetcher.h"

#define FETCH_SIZE_HARD_LIMIT 1024 * 1024 * 3 // 3MB


@implementation TorrentFetcher

- (id)initWithURLString:(NSString*)u delegate:(id<TorrentFetcherDelegate>)delegate
{
    NSURL *URL = [NSURL URLWithString:u];
    if (!URL) return nil;
    
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
        [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [self.delegate torrentFetcher:self failedToFetchFromURL:self.url withError:error];
            } else {
                if (![self validateLength:[response expectedContentLength]]) {
                    NSError *error = [NSError errorWithDomain:@"TorrentFetcher" code:1 userInfo:[NSDictionary dictionaryWithObject:@"File too large" forKey:NSLocalizedDescriptionKey]];
                    [self.delegate torrentFetcher:self failedToFetchFromURL:self.url withError:error];
                } else {
                    [self.delegate torrentFetcher:self fetchedTorrentContent:data fromURL:self.url];
                }
            }
        }] resume];
    }
    return self;
}

- (BOOL)validateLength:(long long)len
{
    if (len == NSURLResponseUnknownLength) return YES;
    if (len > FETCH_SIZE_HARD_LIMIT) return NO;
    return YES;
}

@end
