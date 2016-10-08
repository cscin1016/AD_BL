//
//  VideoViewController.m
//  ADM_Lights
//
//  Created by admin on 14-4-24.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "VideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoViewController (){
    NSArray *mediaItems;
}
- (void)loadMediaItemsForMediaType:(MPMediaType)mediaType;
@end

@implementation VideoViewController
- (void)loadMediaItemsForMediaType:(MPMediaType)mediaType
{
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    NSNumber *mediaTypeNumber= [NSNumber numberWithInt:mediaType];
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber forProperty:MPMediaItemPropertyMediaType];
    [query addFilterPredicate:predicate];
    mediaItems = [query items];
    NSLog(@"mediaItems:%@",mediaItems);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadMediaItemsForMediaType:MPMediaTypeMusic];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return  mediaItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
    MPMediaItem *item = [mediaItems objectAtIndex:row];
    cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
    cell.tag = row;
    
    return cell;
    
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger index = [indexPath row];
    MPMediaItem *item = [mediaItems objectAtIndex:index];
    NSURL* assetUrl = [[mediaItems objectAtIndex:index] valueForProperty:MPMediaItemPropertyAssetURL];
    NSLog(@"%@",assetUrl);
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:assetUrl,@"the",[item valueForProperty:MPMediaItemPropertyTitle],@"songName", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"update" object:nil userInfo:dic];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
