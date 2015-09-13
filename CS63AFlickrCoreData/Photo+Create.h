//
//  Photo+Create.h
//  CS63AFlickrCoreData
//
//  Created by Viet Trinh on 6/15/15.
//  Copyright (c) 2015 VietTrinh. All rights reserved.
//

#import "Photo.h"
#import <MapKit/MapKit.h>

@interface Photo (Create) <MKAnnotation>

+(void)loadPhotosFromFlickrArray:(NSArray*)photos intoManagedObjectContext:(NSManagedObjectContext*)context;
+(Photo*)photoWithFlickrInfo:(NSDictionary*)photoDictionary inMangedObjectContext:(NSManagedObjectContext*)context;

@end
