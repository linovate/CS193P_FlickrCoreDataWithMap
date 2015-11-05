//
//  TopPhotosTableViewController.h
//  CS63AFlickrCD
//
//  Created by lordofming on 6/17/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface TopPhotosTableViewController : CoreDataTableViewController
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@end
