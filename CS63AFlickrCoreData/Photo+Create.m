//
//  Photo+Create.m
//  CS63AFlickrCoreData
//
//  Created by Viet Trinh on 6/15/15.
//  Copyright (c) 2015 VietTrinh. All rights reserved.
//

#import "Photo+Create.h"
#import "FlickrFetcher.h"

@implementation Photo (Create)
+(void)loadPhotosFromFlickrArray:(NSArray*)photos intoManagedObjectContext:(NSManagedObjectContext*)context{
    for (NSDictionary* photo in photos) {
        [self photoWithFlickrInfo:photo inMangedObjectContext:context];
    }
}

+(Photo*)photoWithFlickrInfo:(NSDictionary*)photoDictionary inMangedObjectContext:(NSManagedObjectContext*)context{
    Photo* photo = nil;
    NSError* error;
    
    // Start fetching photos from Core Data;
    NSString* photo_id = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@",photo_id];
    NSArray* matches = [context executeFetchRequest:request error:&error];
    
    if (error || !matches || [matches count] >1) {
        NSLog(@"Something went wrong in the database");
    }
    else if ([matches count]){
        photo = [matches firstObject];
    }
    else{
        // add photo into Database
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.id = photo_id;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imgURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        photo.longitude = [NSNumber numberWithDouble:[photoDictionary[FLICKR_LONGITUDE] doubleValue]];
        photo.latitude = [NSNumber numberWithDouble:[photoDictionary[FLICKR_LATITUDE] doubleValue]];
    }
    
    return photo;
}

-(CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

@end
