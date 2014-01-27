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

@synthesize URLConnection = fURLConnection;
@synthesize url;
@synthesize delegate = fDelegate;

- (id)initWithURLString:(NSString*)u delegate:(id<TorrentFetcherDelegate>)d
{
    NSURL *URL = [NSURL URLWithString:u];
    if (!URL) return nil;
    
    self = [super init];
    if (self) {
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        [connection start];
        self.url = u;
        self.URLConnection = connection;
        self.delegate = d;
        fData = [[NSMutableData alloc] init];
    }
    return self;
}

- (BOOL)validateLength:(long long)len
{
    if (len == NSURLResponseUnknownLength) return YES;
    if (len > FETCH_SIZE_HARD_LIMIT) return NO;
    return YES;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (![self validateLength:[response expectedContentLength]]) {
        [self.URLConnection cancel];
        self.URLConnection = nil;
        NSError *error = [NSError errorWithDomain:@"TorrentFetcher" code:1 userInfo:[NSDictionary dictionaryWithObject:@"File too large" forKey:NSLocalizedDescriptionKey]];
        [self.delegate torrentFetcher:self failedToFetchFromURL:self.url withError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [fData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate torrentFetcher:self failedToFetchFromURL:self.url withError:error];
    [fData release];
    fData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.delegate torrentFetcher:self fetchedTorrentContent:fData fromURL:self.url];
    [fData release];
    fData = nil;
}

- (void)dealloc {
    if (fData)
        [fData release];
    self.URLConnection = nil;
    self.url = nil;
    [super dealloc];
}

@end
