//
//  TopPhotosTableViewController.m
//  CS63AFlickrCD
//
//  Created by lordofming on 6/17/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "TopPhotosTableViewController.h"
#import "PhotoDatabaseAvailability.h"
#import "ImageViewController.h"
#import "Photo.h"

@interface TopPhotosTableViewController ()

@end

@implementation TopPhotosTableViewController

-(void)awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
    NSLog(@"Notification is received in Table View Controller");
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    _managedObjectContext = managedObjectContext;
    
    NSSortDescriptor* alphabeticalSort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = nil;
    request.sortDescriptors = @[alphabeticalSort];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    Photo* photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [photo.title isEqualToString:@""] ? @"Unknown" : photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]]];
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photo"]) {
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    [self prepareImageViewController:segue.destinationViewController forPhoto:[self.fetchedResultsController objectAtIndexPath:indexPath]];
                }
            }
        }
    }
}

-(void)prepareImageViewController:(ImageViewController*)ivc forPhoto:(Photo*)photo{
    ivc.title = photo.title;
    ivc.imgURL = [NSURL URLWithString:photo.imgURL];
}


@end
