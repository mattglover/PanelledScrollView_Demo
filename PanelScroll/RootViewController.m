//
//  RootViewController.m
//  PanelScroll
//
//  Created by Matt Glover on 04/01/2013.
//  Copyright (c) 2013 Duchy Software. All rights reserved.
//

#import "RootViewController.h"
#import "UIColor+MoreColors.h"

#define SCROLLVIEW_WIDTH 260
#define SCROLLVIEW_HEIGHT self.view.bounds.size.height - 80
#define PANEL_HORIZONAL_INSET 5
#define PANEL_VERTICAL_INSET 40

@interface RootViewController () <UIScrollViewDelegate>
//@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSMutableArray *dataObjects;

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) NSMutableDictionary *loadedScrollviewSubviews;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation RootViewController
@synthesize displayPageControl = _displayPageControl;
//@synthesize colors = _colors;
@synthesize dataObjects = _dataObjects;
@synthesize scrollview = _scrollview;
@synthesize pageControl = _pageControl;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.loadedScrollviewSubviews = [NSMutableDictionary dictionary];
  
  [self.view setBackgroundColor:[UIColor bondiBlue]];
  //[self initColors];
  [self initDataObjects];
  
  [self initScrollView];
  
  self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.scrollview.bounds.size.width, 30)];
  [self.pageControl setCenter:CGPointMake(self.scrollview.center.x, self.scrollview.frame.origin.y + self.scrollview.bounds.size.height - self.pageControl.bounds.size.height /2)];
  [self.pageControl setCurrentPage:0];
  [self.pageControl setNumberOfPages:[self.dataObjects count]];
  if (self.displayPageControl) {
    [self.view addSubview:self.pageControl];
  }
  
  [self lazyLoadViewsForPageNumber:0];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
  NSMutableArray *excludedViewFromMemoryRelease = [NSMutableArray array];
  [excludedViewFromMemoryRelease addObject:[NSString stringWithFormat:@"%d", self.pageControl.currentPage-1]];
  [excludedViewFromMemoryRelease addObject:[NSString stringWithFormat:@"%d", self.pageControl.currentPage]];
  [excludedViewFromMemoryRelease addObject:[NSString stringWithFormat:@"%d", self.pageControl.currentPage+1]];
  
  NSMutableDictionary *enumeratedDictionary = [self.loadedScrollviewSubviews copy];
  for (NSString *key in enumeratedDictionary) {
    if (![excludedViewFromMemoryRelease containsObject:key]) {
      UIView *viewToRemove = [self.loadedScrollviewSubviews objectForKey:key];
      [viewToRemove removeFromSuperview];
      viewToRemove = nil;
      [self.loadedScrollviewSubviews removeObjectForKey:key];
    }
  }
  
  enumeratedDictionary = nil;
  excludedViewFromMemoryRelease = nil;
}

- (void)initScrollView {
  
  self.scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
  [self.scrollview setDelegate:self];
  [self.scrollview setShowsHorizontalScrollIndicator:NO];
  [self.scrollview setShowsVerticalScrollIndicator:NO];
  [self.scrollview setBackgroundColor:[UIColor bondiBlue]];
  [self.scrollview setPagingEnabled:YES];
  [self.scrollview setClipsToBounds:NO];
  [self.scrollview setCenter:self.view.center];
  
  [self.scrollview setContentSize:CGSizeMake(SCROLLVIEW_WIDTH * [self.dataObjects count] , SCROLLVIEW_HEIGHT)];
  
  [self.view addSubview:self.scrollview];
}

/*
- (void)initColors {
  
  self.colors = @[[UIColor lightBlue],
  [UIColor lightKhaki],
  [UIColor lightPink],
  [UIColor atomicTangerine],
  [UIColor auburn],
  [UIColor azure],
  [UIColor azureWeb],
  [UIColor britishRacingGreen],
  [UIColor bronze],
  [UIColor brown],
  [UIColor buff],
  [UIColor burgundy],
  [UIColor burntOrange],
  [UIColor burntSienna],
  [UIColor darkBlue],
  [UIColor darkBrown],
  [UIColor darkCerulean],
  [UIColor darkChestnut],
  [UIColor darkCoral],
  [UIColor darkGoldenrod],
  [UIColor darkGreen],
  [UIColor darkKhaki],
  [UIColor darkPastelGreen],
  [UIColor darkPink],
  [UIColor darkScarlet],
  [UIColor darkSalmon],
  [UIColor darkSlateGray],
  [UIColor darkSpringGreen],
  [UIColor darkTan],
  [UIColor darkTurquoise],
  [UIColor darkViolet],
  [UIColor deepCerise],
  [UIColor deepChestnut],
  [UIColor deepFuchsia],
  [UIColor deepLilac],
  [UIColor deepMagenta],
  [UIColor deepPeach],
  [UIColor deepPink],
  [UIColor denim]
  ];
  
}
*/

- (void)initDataObjects {
  self.dataObjects = [NSMutableArray array];
  for (int index = 0; index <= 200; index++) {
    [self.dataObjects addObject:[NSNumber numberWithInt:index]];
  }
}
 
#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
  
  // Switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = sender.frame.size.width;
  int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  self.pageControl.currentPage = page;
  
  [self lazyLoadViewsForPageNumber:self.pageControl.currentPage];
}

#pragma mark - View Helpers

- (void)lazyLoadViewsForPageNumber:(NSInteger)currentPage {
  
  if (currentPage > 1) {
    UIView *previousView = [self viewForPage:currentPage -1];
    if (!previousView.superview) {
      [self.scrollview addSubview:previousView];
    }
  }
  
  UIView *currentView  = [self viewForPage:currentPage];
  if (!currentView.superview) {
    [self.scrollview addSubview:currentView];
  }
  
  if (currentPage < [self.dataObjects count] -1) {
    UIView *nextView     = [self viewForPage:currentPage +1];
    if (!nextView.superview) {
      [self.scrollview addSubview:nextView];
    }
  }
}

- (UIView *)viewForPage:(NSInteger)pageNumber {
  
  UIView *view = nil;
  if ([self.loadedScrollviewSubviews objectForKey:[NSString stringWithFormat:@"%d", pageNumber]]) {
    view = [self.loadedScrollviewSubviews objectForKey:[NSString stringWithFormat:@"%d", pageNumber]];
  }
  
  if (!view) {
    view = [[UIView alloc] initWithFrame:CGRectMake(PANEL_HORIZONAL_INSET + (SCROLLVIEW_WIDTH * pageNumber),
                                                    PANEL_VERTICAL_INSET,
                                                    SCROLLVIEW_WIDTH - (PANEL_HORIZONAL_INSET * 2),
                                                    SCROLLVIEW_HEIGHT - (PANEL_VERTICAL_INSET * 2))];
    
   // [view setBackgroundColor:self.colors[pageNumber]];
    
    [self.loadedScrollviewSubviews setObject:view forKey:[NSString stringWithFormat:@"%d", pageNumber]];
    UIImage *panelBG = [UIImage imageNamed:@"listBG"];
    UIImage *stretchablePanelBG = [panelBG resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
    UIImageView *bg = [[UIImageView alloc] initWithFrame:view.bounds];
    [bg setImage:stretchablePanelBG];
    [view addSubview:bg];
    
    CGRect nameLabelRect = UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(0, 10, 0, 10));
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:172]];
    [nameLabel setAdjustsFontSizeToFitWidth:YES];
    [nameLabel setText:[NSString stringWithFormat:@"%d", pageNumber]];
    [nameLabel setShadowColor:[UIColor whiteColor]];
    [nameLabel setShadowOffset:CGSizeMake(0, 1)];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [nameLabel setTextColor:[UIColor charcoal]];
    [view addSubview:nameLabel];
  }
  
  return view;
}

@end
