//
//  Photo.h
//  CS63AFlickrCoreData
//
//  Created by Viet Trinh on 6/15/15.
//  Copyright (c) 2015 VietTrinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * imgURL;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
