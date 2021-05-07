//
//  ViewController.h
//  CoinVibesiOS
//
//  Created by Muhammad Asjad on 12/5/13.
//  Copyright (c) 2013 Muhammad Asjad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

-(IBAction)Tile_title_1l:(id)sender;
-(IBAction)Tile_title_1r:(id)sender;
-(IBAction)Tile_title_2l:(id)sender;
-(IBAction)Tile_title_2r:(id)sender;
-(IBAction)Tile_title_3l:(id)sender;
-(IBAction)Tile_title_3r:(id)sender;

-(IBAction)Tile_unit_1l:(id)sender;
-(IBAction)Tile_unit_1r:(id)sender;
-(IBAction)Tile_unit_2l:(id)sender;
-(IBAction)Tile_unit_2r:(id)sender;
-(IBAction)Tile_unit_3l:(id)sender;
-(IBAction)Tile_unit_3r:(id)sender;

@property IBOutlet UIButton* Tile_title_1l;
@property IBOutlet UIButton* Tile_title_1r;
@property IBOutlet UIButton* Tile_title_2l;
@property IBOutlet UIButton* Tile_title_2r;
@property IBOutlet UIButton* Tile_title_3l;
@property IBOutlet UIButton* Tile_title_3r;

@property IBOutlet UIButton* Tile_unit_1l;
@property IBOutlet UIButton* Tile_unit_1r;
@property IBOutlet UIButton* Tile_unit_2l;
@property IBOutlet UIButton* Tile_unit_2r;
@property IBOutlet UIButton* Tile_unit_3l;
@property IBOutlet UIButton* Tile_unit_3r;

@property IBOutlet UILabel* Tile_price_1l;
@property IBOutlet UILabel* Tile_price_1r;
@property IBOutlet UILabel* Tile_price_2l;
@property IBOutlet UILabel* Tile_price_2r;
@property IBOutlet UILabel* Tile_price_3l;
@property IBOutlet UILabel* Tile_price_3r;

@property (strong,nonatomic) NSArray *exchangesntickers_global;


//-(void) set_exchange_info:(NSMutableArray *)exchanges;
//-(NSString *) getnext_ticker:(int)index url:(NSString *)url;

-(void) refresh_screen;
-(void) SetupScreenValuesWithNamesArray:(NSMutableArray*)exchange_names andUnitsArray:(NSMutableArray *)exchange_unit andExchangePrices:(NSMutableArray *)exchange_prices;
-(NSDictionary *) make_APICallwithURL:(NSString *)url;

-(NSMutableArray *) getNextExchange:(int)index;
-(NSMutableArray *) getNextUnit:(int)index andtickers:(NSMutableArray*)tickers;

-(NSMutableArray *) onTap_NextUnit:(int)index;
-(NSMutableArray *) onTap_NextExchangeWithIndex:(int)tile_index;

-(NSString *) returnPriceforSavedPreference:(int)tile_index;

@end
