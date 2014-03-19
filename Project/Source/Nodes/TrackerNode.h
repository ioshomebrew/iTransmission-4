/******************************************************************************
 * This file is modified based on TrackerNode.h in Transmission project. 
 * Original copyright declaration is as follows. 
 *****************************************************************************/

/******************************************************************************
 * $Id: TrackerNode.h 10190 2010-02-13 04:30:47Z livings124 $
 *
 * Copyright (c) 2009-2010 Transmission authors and contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *****************************************************************************/

#import <UIKit/UIKit.h>

@class Torrent;

@interface TrackerNode : NSObject
{
    tr_tracker_stat fStat;
    
    Torrent * fTorrent; //weak reference
}

- (id) initWithTrackerStat: (tr_tracker_stat *) stat torrent: (Torrent *) torrent;

- (NSString *) host;
- (NSString *) fullAnnounceAddress;

- (NSInteger) tier;

- (NSUInteger) identifier;

- (Torrent *) torrent;

- (NSInteger) totalSeeders;
- (NSInteger) totalLeechers;
- (NSInteger) totalDownloaded;

- (NSString *) lastAnnounceStatusString;
- (NSString *) nextAnnounceStatusString;
- (NSString *) lastScrapeStatusString;

@end
