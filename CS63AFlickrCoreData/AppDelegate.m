//
//  AppDelegate.m
//  CS63AFlickrCoreData
//
//  Created by Viet Trinh on 6/15/15.
//  Copyright (c) 2015 VietTrinh. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoDatabaseAvailability.h"
#import "FlickrFetcher.h"
#import "Photo+Create.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) UIManagedDocument* document;
@property (strong, nonatomic) NSManagedObjectContext* photoDatabaseContext;
@property (strong, nonatomic) NSURLSession* downloadSession;
@property (copy, nonatomic) void (^downloadBackgroundURLSessionCompletionHandler)();
@end

@implementation AppDelegate

#define FLICKR_FETCH @"Flickr Fetch"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self createManagedObjectContext];
    [self startFlickrFetch];
    
    return YES;
}

#pragma mark - Properties

-(void)setDocument:(UIManagedDocument *)document{
    _document = document;
}

-(void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext{
    _photoDatabaseContext = photoDatabaseContext;
    
    // post notification to photo CDTVC whenever the context is updated
    NSDictionary* userInfo = self.photoDatabaseContext? @{PhotoDatabaseAvailabilityContext: self.photoDatabaseContext} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self userInfo:userInfo];
    NSLog(@"Notification is posted");
}

-(NSURLSession*)downloadSession{
    if (!_downloadSession) {
        static dispatch_once_t downloadToken;
        dispatch_once(&downloadToken, ^{
            NSURLSessionConfiguration* urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_FETCH];
            _downloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:nil];
        });
    }
    
    return _downloadSession;
}

#pragma mark - NSURLSessionDownloadDelegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        [self loadPhotosFromLocalURL:localFile
                         intoContext:self.photoDatabaseContext
                 andThenExecuteBlock:^{
                     [self downloadTasksMightBeComplete];
                 }];
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error && (session == self.downloadSession)) {
        NSLog(@"Background Download Session has failed: %@",error.localizedDescription);
        [self downloadTasksMightBeComplete];
    }
}

-(void)downloadTasksMightBeComplete{
    if (self.downloadBackgroundURLSessionCompletionHandler) {
        NSLog(@"Download tasks might be completed");
    }
}

#pragma mark - Create Core Data Document
-(void)createManagedObjectContext{
    NSFileManager* fileManager = [NSFileManager defaultManager];

//  NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask] firstObject];
    
//  NSDocumentationDirectory is outdated, use NSDocumentDirectory instead.
    NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    
    
    NSString* documentName = @"FlickrCoreData";
    NSURL* url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            else NSLog(@"Couldn't open document at %@",url);
        }];
    }
    else{
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            else NSLog(@"Couldn't create document at %@",url);
        }];
    }
}

-(void)documentIsReady{
    if (self.document.documentState == UIDocumentStateNormal) {
        self.photoDatabaseContext = self.document.managedObjectContext;
    }
}

#pragma mark - Fetch Regions and Save into Core Data
-(void)startFlickrFetch{
    // URLSession Delegate functions will get called
    [self.downloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([downloadTasks count]) {
            for (NSURLSessionDownloadTask* task in downloadTasks)
                [task resume];
        }
        else{
            NSURLSessionDownloadTask* task = [self.downloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        }
    }];
}

-(void)loadPhotosFromLocalURL:(NSURL*)localFile intoContext:(NSManagedObjectContext*)context andThenExecuteBlock:(void(^)())whenDone{
    if (context) {
        NSArray* photos = [self flickrPhotosAtURL:localFile];
        //NSLog(@"%@",photos);
        NSLog(@"Fetch completed. Saving into Core Data");
        [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
        if (whenDone) whenDone();
    }
    else{
        if (whenDone) whenDone();
    }
}

// Return an array of photo dictionary
-(NSArray*)flickrPhotosAtURL:(NSURL*)url{
    NSMutableArray* photos ;
    NSData* JSONData = [NSData dataWithContentsOfURL:url];
    if (JSONData){
        NSDictionary* photoPropertyList = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:NULL];
        photos = [photoPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
    }
    NSLog(@"%@",photos);
    return photos;
}

@end
