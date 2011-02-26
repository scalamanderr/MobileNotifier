#import "MNTableViewCell.h"

@implementation MNTableViewCell

@synthesize iconImageView, headerLabel, alertTextLabel;

-(id)init
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	if(self != nil)
	{
		CGRect aframe = self.frame;
		self.frame = CGRectMake(aframe.origin.x,aframe.origin.y,320,60);
		backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 60.0)];
		backgroundImageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/alert_bg.png"];
		
		iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 15.0, 30.0, 30.0)];
		headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 11.0, 216.0, 22.0)];
		alertTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 27.0, 216.0, 22.0)];

		backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/MobileNotifier/alert_bg.png"]];
		//[self addSubview:backgroundImageView];
		[self addSubview:iconImageView];
		[self addSubview:alertTextLabel];
		[self addSubview:headerLabel];
	}
	return self;
}

@end