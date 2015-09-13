//
//  TopPhotosTableViewController.h
//  CS63AFlickrCD
//
//  Created by Viet Trinh on 6/17/15.
//  Copyright (c) 2015 VietTrinh. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface TopPhotosTableViewController : CoreDataTableViewController
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@end
