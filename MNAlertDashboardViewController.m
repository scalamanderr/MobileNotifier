/*
Copyright (c) 2010-2011, Peter Hajas
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Peter Hajas nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PETER HAJAS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <QuartzCore/QuartzCore.h>
#import "MNAlertDashboardViewController.h"

@implementation MNAlertDashboardViewController

@synthesize window;
@synthesize delegate = _delegate;

-(id)initWithDelegate:(id)__delegate;
{
	self = [super init];
	if(self)
	{	
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		
		//window:
		window = [[UIWindow alloc] 
		initWithFrame:CGRectMake(0,0,screenBounds.size.width,screenBounds.size.height - 92)];
		
		window.windowLevel = UIWindowLevelAlert+102.0f;
		window.userInteractionEnabled = YES;
		window.hidden = YES;
		
		//button to return to the application
		returnToApplicationButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    	returnToApplicationButton.frame = CGRectMake(0.0, 0.0, 320.0, 20.0);
    	[returnToApplicationButton setBackgroundImage:[UIImage imageWithContentsOfFile: @"/Library/Application Support/MobileNotifier/returnToApplication.png"] 
    						   forState:UIControlStateNormal];
    	[returnToApplicationButton setAlpha:0.0];
    	
    	//wire up the button!
    	[returnToApplicationButton addTarget:self action:@selector(dismissSwitcher:)
    			 forControlEvents:UIControlEventTouchUpInside];
		
		//Create the tableview
		alertListView = [[UITableView alloc] initWithFrame:CGRectMake(16,45,287,297) style:UITableViewStylePlain];
		alertListView.delegate = self;
		alertListView.dataSource = self;
		[alertListView setAlpha:0.0];
        alertListView.backgroundColor = [UIColor clearColor];
        alertListView.layer.cornerRadius = 10;
		
		//Background for the alertListView
        alertListViewBackground = [[UIImageView alloc] initWithFrame:CGRectMake(15,45,290,297)];
        alertListViewBackground.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/listViewBackground.png"];
        [alertListViewBackground setAlpha:0.0];
		
		//Dashboard background image
		dashboardBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,20,320,366)];
		dashboardBackground.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/dashboardBackground.png"];
		[dashboardBackground setAlpha:0.0];
		
		//MobileNotifier title label
        mobileNotifierTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,349,320,22)];
        mobileNotifierTextLabel.text = @"MobileNotifier";
        mobileNotifierTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        mobileNotifierTextLabel.textAlignment = UITextAlignmentCenter;
    	mobileNotifierTextLabel.textColor = [UIColor whiteColor];
    	mobileNotifierTextLabel.shadowColor = [UIColor blackColor];
    	mobileNotifierTextLabel.shadowOffset = CGSizeMake(0,-1);
        mobileNotifierTextLabel.backgroundColor = [UIColor clearColor];
        [mobileNotifierTextLabel setAlpha:0.0];
        
        //Statusbar label
        statusBarTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,20)];
        statusBarTextLabel.text = @"Touch to return to where you were";
        statusBarTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        statusBarTextLabel.textAlignment = UITextAlignmentCenter;
    	statusBarTextLabel.textColor = [UIColor whiteColor];
    	statusBarTextLabel.shadowColor = [UIColor blackColor];
    	statusBarTextLabel.shadowOffset = CGSizeMake(0,-1);
        statusBarTextLabel.backgroundColor = [UIColor clearColor];
        [statusBarTextLabel setAlpha:0.0];
        
        /*statusBar = [[UIStatusBar alloc] initWithFrame:CGRectMake(0,0,320,20)];
        [statusBar requestStyle:1];
        [statusBar setAlpha:0.0];*/
		
		//Badge for alerts
        //badge = [[SBIconBadge alloc] init];
		
		_delegate = __delegate;
	    
		//Add everything to the view
		dashboardShowing = NO;
		[window addSubview:dashboardBackground];
        [window addSubview:alertListViewBackground];
		[window addSubview:alertListView];
        [window addSubview:returnToApplicationButton];
        [window addSubview:mobileNotifierTextLabel];
        [window addSubview:statusBarTextLabel];
        //[window addSubview:statusBar];
		
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:didFinish:inContext:)];
	}
	return self;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Dismiss the alert
        [_delegate dismissedAlertAtIndex:indexPath.row];
        //Delete row from tableview
        [alertListView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        //Update ourselves
        [alertListView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Take action on the alert
    [_delegate actionOnAlertAtIndex:indexPath.row];
    //Update ourselves
    [alertListView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MNTableViewCell *cell = [[MNTableViewCell alloc] init];
	
	MNAlertData *dataObj = [[_delegate getPendingAlerts] objectAtIndex:indexPath.row];
	
	cell.iconImageView.image = [_delegate iconForBundleID:dataObj.bundleID];
	cell.headerLabel.text = dataObj.header;
	cell.alertTextLabel.text = dataObj.text;
	
	//If this is the last item, then let's set the shadow of it
    if(indexPath.row == ([[_delegate getPendingAlerts] count] - 1))
    {
        //Don't do this yet - we want to show this BELOW the last alert
        //cell.backgroundShadowImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/last-element-shadow.png"];
    }
	
	return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_delegate getPendingAlerts] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60.0;
}

-(void)refresh
{
    [alertListView reloadData];
}

-(void)dismissSwitcher:(id)sender
{
    [_delegate dismissSwitcher];
}

-(void)toggleDashboard
{
	if(dashboardShowing)
	{
		[self showDashboard];
	}
	else
	{
		[self hideDashboard];
	}
}

-(void)hideDashboard
{
	//Fade it all away
	window.userInteractionEnabled = NO;
	[UIView beginAnimations:@"fadeOut" context:NULL];
	[UIView setAnimationDuration:0.3];
	
    [dashboardBackground        setAlpha:0.0];
    [returnToApplicationButton  setAlpha:0.0];
    [alertListView              setAlpha:0.0];
    [mobileNotifierTextLabel    setAlpha:0.0];
    [alertListViewBackground    setAlpha:0.0];
    [mobileNotifierTextLabel    setAlpha:0.0];
    [statusBarTextLabel         setAlpha:0.0];
    //[statusBar                  setAlpha:0.0];
	
	[UIView commitAnimations];
}

-(void)showDashboard
{
	//Fade it all in
	window.hidden = NO;
	window.userInteractionEnabled = YES;
	[UIView beginAnimations:@"fadeIn" context:NULL];
	[UIView setAnimationDuration:0.3];
	
	[dashboardBackground        setAlpha:1.0];
    [returnToApplicationButton  setAlpha:1.0];
    [alertListView              setAlpha:1.0];
    [mobileNotifierTextLabel    setAlpha:1.0];
    [alertListViewBackground    setAlpha:1.0];
    [mobileNotifierTextLabel    setAlpha:1.0];
    [statusBarTextLabel         setAlpha:1.0];
    //[statusBar                  setAlpha:1.0];

	[UIView commitAnimations];
}

-(void)animationDidStop:(NSString*)animationID didFinish:(NSNumber*)finished inContext:(id)context
{
	if([animationID isEqualToString:@"fadeIn"])
	{
		window.userInteractionEnabled = YES;
	}
	if([animationID isEqualToString:@"fadeOut"])
	{
		window.userInteractionEnabled = NO;
		window.hidden = YES;
	}
}

-(bool)isShowing
{
    return dashboardShowing;
}

@end