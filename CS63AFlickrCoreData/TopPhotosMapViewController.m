//
//  TopPhotosMapViewController.m
//  CS63AFlickrCD
//
//  Created by Viet Trinh on 6/17/15.
//  Copyright (c) 2015 VietTrinh. All rights reserved.
//

#import "TopPhotosMapViewController.h"
#import <MapKit/MapKit.h>
#import "ImageViewController.h"
#import "PhotoDatabaseAvailability.h"
#import "Photo.h"

@interface TopPhotosMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray* photos;
@end

@implementation TopPhotosMapViewController

#pragma mark - View Controller life-cycle
-(void)viewDidLoad{
    [super viewDidLoad];
    [self fetchPhotos];
}

-(void)awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
    NSLog(@"Notification is received in Map View Controller");
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    _managedObjectContext = managedObjectContext;
    [self fetchPhotos];
}

-(void)fetchPhotos{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.fetchBatchSize = 20;
    request.fetchLimit = 100;
    request.predicate = nil;
    self.photos = [self.managedObjectContext executeFetchRequest:request error:NULL];
}

#pragma mark - Properties
-(void)setPhotos:(NSArray *)photos{
    _photos = photos;
    [self updateMapView];
}

-(void)setMapView:(MKMapView *)mapView{
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapView];
}

#pragma mark - MKMapView Delegate
-(void)updateMapView{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.photos];
    [self.mapView showAnnotations:self.photos animated:YES];
}

/*
 * self.mapView is a MKMapView that contains a set of MKAnnotationViews
 * MKAnnotationView is a MKPinAnnotationView which is a red pin on a map
 * Each of this pin contains information of a Photo which is id<MKAnnotation>
 */
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    static NSString* reuseId = @"Photo Annotation";
    MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        UIButton* disclosureButton = [[UIButton alloc] init];
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"disclosure"] forState:UIControlStateNormal];
        [disclosureButton sizeToFit];
        view.leftCalloutAccessoryView = imageView;
        view.rightCalloutAccessoryView = disclosureButton;
    }
    view.annotation = annotation;
    return view;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    [self updateLeftCalloutAccessoryViewInAnnotationView:view];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    [self performSegueWithIdentifier:@"Show Photo" sender:view];
}

-(void)updateLeftCalloutAccessoryViewInAnnotationView:(MKAnnotationView*)annotationView{
    UIImageView* thumbnailView = nil;
    Photo* photo = nil;
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        thumbnailView = (UIImageView*)annotationView.leftCalloutAccessoryView;
        if (thumbnailView) {
            if ([annotationView.annotation isKindOfClass:[Photo class]]) {
                photo = (Photo*)annotationView.annotation;
                if (photo) {
                    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]]];
                    thumbnailView.image = image;
                }
            }
        }
    }
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([sender isKindOfClass:[MKAnnotationView class]]) {
        if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
            ImageViewController* ivc = (ImageViewController*)segue.destinationViewController;
            id <MKAnnotation> annotation = ((MKAnnotationView*)sender).annotation;
            if ([annotation isKindOfClass:[Photo class]]) {
                Photo* photo = (Photo*)annotation;
                if (photo) {
                    if ([segue.identifier isEqualToString:@"Show Photo"]){
                        ivc.title = photo.title;
                        ivc.imgURL = [NSURL URLWithString:photo.imgURL];
                    }
                }
            }
        }
    }
}

@end
