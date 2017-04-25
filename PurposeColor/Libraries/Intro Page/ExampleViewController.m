#import "ExampleViewController.h"
#import "IntroControll.h"

@implementation ExampleViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    return self;
}

- (void) loadView {
    [super loadView];
    
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:@"" description:@"" image:@"image1.jpg"];
    
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:@"" description:@"" image:@"image2.jpg"];
    
    IntroModel *model3 = [[IntroModel alloc] initWithTitle:@"" description:@"" image:@"image3.jpg"];
    
    self.view = [[IntroControll alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) pages:@[model1, model2, model3]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    CGSize size = [UIScreen mainScreen].bounds.size;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    else {
        size = CGSizeMake(size.width, size.height);
    }

    IntroControll *introControll = (IntroControll *)self.view;
    [self.view setFrame:CGRectMake(0, 0, size.width, size.height)];
    [introControll updateView:CGRectMake(0, 0, size.width, size.height)];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
