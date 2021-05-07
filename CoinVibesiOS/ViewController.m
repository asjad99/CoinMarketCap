//
//  ViewController.m
//  CoinVibesiOS
//
//  Created by Muhammad Asjad on 12/5/13.
//  Copyright (c) 2013 Muhammad Asjad. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize Tile_title_1l;
@synthesize Tile_title_1r;
@synthesize Tile_title_2l;
@synthesize Tile_title_2r;
@synthesize Tile_title_3l;
@synthesize Tile_title_3r;

@synthesize Tile_price_1l;
@synthesize Tile_price_1r;
@synthesize Tile_price_2l;
@synthesize Tile_price_2r;
@synthesize Tile_price_3l;
@synthesize Tile_price_3r;

@synthesize Tile_unit_1l;
@synthesize Tile_unit_1r;
@synthesize Tile_unit_2l;
@synthesize Tile_unit_2r;
@synthesize Tile_unit_3l;
@synthesize Tile_unit_3r;

@synthesize exchangesntickers_global;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];

    [self refresh_screen];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:self
                                   selector:@selector(onTick:)
                                   userInfo:nil
                                    repeats:YES];

}


-(void)onTick:(NSTimer *)timer {
    [self refresh_screen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) refresh_screen{
    
    NSMutableArray *exchange_names = [[NSMutableArray alloc] init];
    NSMutableArray *exchange_slugs = [[NSMutableArray alloc] init];
    NSMutableArray *temp_baseCode = [[NSMutableArray alloc] init];
    NSMutableArray *temp_quoteCode = [[NSMutableArray alloc] init];
    
    NSMutableArray *exchange_prices = [[NSMutableArray alloc] init];
    NSMutableArray *exchange_unit = [[NSMutableArray alloc] init];
    
    
    NSDictionary *response =  [self make_APICallwithURL:@"http://www.coinvibes.com/api/v1/tickers"];
    NSArray* exchanges;
    if (response == nil) {
        return;
    }
    
    //update the global Array
    exchanges = [response objectForKey:@"exchanges"];
    self.exchangesntickers_global =[[NSMutableArray alloc] initWithArray:exchanges];
    
    //retrieve saved preferences
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *exchange_names_saved = [[NSMutableArray alloc] init];
    NSMutableArray *exchange_baseCurr_saved = [[NSMutableArray alloc] init];
    NSMutableArray *exchange_quoteCurr_saved = [[NSMutableArray alloc] init];
    
    exchange_names_saved = [[NSUserDefaults standardUserDefaults] objectForKey:@"exNameArray"];
    exchange_baseCurr_saved = [[NSUserDefaults standardUserDefaults] objectForKey:@"base_currCode"];
    exchange_quoteCurr_saved = [[NSUserDefaults standardUserDefaults] objectForKey:@"quote_currCode"];
    
    
    if ([exchange_names_saved count] > 0) {
        /*Do a quick search using names and units
         Fetch latest price based on that title and unit*/
        exchange_names = exchange_names_saved;
        NSString *unit;
        for (int tile_index=0; tile_index<=5;tile_index++){
            [exchange_prices addObject: [self returnPriceforSavedPreference:tile_index]];
            if ([[exchange_baseCurr_saved objectAtIndex:tile_index] isEqualToString:@""]){
                //pass the current index to onTap_NextExchangeWithIndex
                //and update the unit and price.
                unit = @"N/A";
            }
            else{
                unit = [[NSString alloc] initWithFormat:@"%@/%@",[exchange_baseCurr_saved objectAtIndex:tile_index],[exchange_quoteCurr_saved objectAtIndex:tile_index]];
            }
            [exchange_unit addObject:[unit uppercaseString]];
        }
        
    }
    //initialize App and User Settings When App is Run first Run
    else
    {
        for (int index=0; index<=5;index++){
            
            NSDictionary* exchange_info = [exchanges objectAtIndex:index];
            NSString* name = [exchange_info objectForKey:@"name"];
            [exchange_names addObject:name];
            NSLog(@"name: %@", name);
            NSString* slug = [exchange_info objectForKey:@"slug"];
            [exchange_slugs addObject:slug];
            
            NSArray *tickers = [exchange_info objectForKey:@"tickers"];
            NSDictionary* tickers_dict = [tickers objectAtIndex:0];
            
            NSString *url_temp = [tickers_dict objectForKey:@"url"];
            NSString *url = [NSString stringWithFormat:@"http://www.coinvibes.com%@",url_temp];
            //NSLog(url);
            
            NSDictionary *exchangeInfo_response =  [self make_APICallwithURL:url];
            
            if (exchangeInfo_response !=nil) {
                NSString *price = [exchangeInfo_response objectForKey:@"bid"];
                [exchange_prices addObject:price];
                //NSLog(@"price: %@", price);
                
                NSDictionary *base_currency_dict = [exchangeInfo_response objectForKey:@"base_currency"];
                NSString *base_currency = [base_currency_dict objectForKey:@"code"];
                [temp_baseCode addObject:base_currency];
                
                NSDictionary *quote_currency_dict = [exchangeInfo_response objectForKey:@"quote_currency"];
                NSString *quote_currency = [quote_currency_dict objectForKey:@"code"];
                [temp_quoteCode addObject:quote_currency];
                
                NSString *unit = [[NSString alloc] initWithFormat:@"%@/%@",base_currency,quote_currency];
                [exchange_unit addObject:[unit uppercaseString]];
                // NSLog(@"unit: %@", unit);
            }
            else {
                [exchange_prices addObject:@"0"];
                [exchange_unit addObject:@"N/A"];
                [temp_baseCode addObject:@""];
                [temp_quoteCode addObject:@""];
                
            }
        }
        
        // NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:exchange_names forKey:@"exNameArray"];
        [prefs setObject:exchange_slugs forKey:@"ex_slugArray"];
        [prefs setObject:temp_baseCode forKey:@"base_currCode"];
        [prefs setObject:temp_quoteCode forKey:@"quote_currCode"];
        [prefs synchronize];
        
    }
    //set-up the values on screen
    [self SetupScreenValuesWithNamesArray:exchange_names andUnitsArray:exchange_unit andExchangePrices:exchange_prices];
}

-(void) SetupScreenValuesWithNamesArray:(NSMutableArray*)exchange_names andUnitsArray:(NSMutableArray *)exchange_unit andExchangePrices:(NSMutableArray *)exchange_prices{
    [Tile_title_1l setTitle:[exchange_names objectAtIndex:0] forState: UIControlStateNormal];
    [Tile_title_1r setTitle:[exchange_names objectAtIndex:1] forState: UIControlStateNormal];
    [Tile_title_2l setTitle:[exchange_names objectAtIndex:2] forState: UIControlStateNormal];
    [Tile_title_2r setTitle:[exchange_names objectAtIndex:3] forState: UIControlStateNormal];
    [Tile_title_3l setTitle:[exchange_names objectAtIndex:4] forState: UIControlStateNormal];
    [Tile_title_3r setTitle:[exchange_names objectAtIndex:5] forState: UIControlStateNormal];
    
    [Tile_unit_1l setTitle:[exchange_unit objectAtIndex:0] forState: UIControlStateNormal];
    [Tile_unit_1r setTitle:[exchange_unit objectAtIndex:1] forState: UIControlStateNormal];
    [Tile_unit_2l setTitle:[exchange_unit objectAtIndex:2] forState: UIControlStateNormal];
    [Tile_unit_2r setTitle:[exchange_unit objectAtIndex:3] forState: UIControlStateNormal];
    [Tile_unit_3l setTitle:[exchange_unit objectAtIndex:4] forState: UIControlStateNormal];
    [Tile_unit_3r setTitle:[exchange_unit objectAtIndex:5] forState: UIControlStateNormal];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:3];
    
    Tile_price_1l.text = [formatter stringFromNumber:[exchange_prices objectAtIndex:0]];
    Tile_price_1r.text = [formatter stringFromNumber:[exchange_prices objectAtIndex:1]];
    Tile_price_2l.text = [formatter stringFromNumber:[exchange_prices objectAtIndex:2]];
    Tile_price_2r.text = [formatter stringFromNumber:[exchange_prices objectAtIndex:3]];
    Tile_price_3l.text = [formatter stringFromNumber:[exchange_prices objectAtIndex:4]];
    Tile_price_3r.text = [formatter stringFromNumber:[exchange_prices objectAtIndex:5]];
    
    self.Tile_price_1l.font = [UIFont fontWithName:@"OpenSans-Light" size:35.0];
    self.Tile_price_1r.font = [UIFont fontWithName:@"OpenSans-Light" size:35.0];
    self.Tile_price_2l.font = [UIFont fontWithName:@"OpenSans-Light" size:35.0];
    self.Tile_price_2r.font = [UIFont fontWithName:@"OpenSans-Light" size:35.0];
    self.Tile_price_3l.font = [UIFont fontWithName:@"OpenSans-Light" size:35.0];
    self.Tile_price_3r.font = [UIFont fontWithName:@"OpenSans-Light" size:35.0];
    
}

-(NSDictionary *) make_APICallwithURL:(NSString *)url
{
    
    // NSLog(@"the toke is %@",self.emailobj_settings.auth_token);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSDictionary *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        if([responseCode statusCode] == 0){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                            message:@"Make sure you are connected to the internet"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            //pause and try again here...
            
            return nil;
        }
        else{
            /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
             message:@"Opps...something went wrong."
             delegate:nil
             cancelButtonTitle:@"Dimiss"
             otherButtonTitles:nil];
             [alert show];
             NSLog(@"Error... %@, HTTP status code %i", url, [responseCode statusCode]);*/
            return nil;
        }
    }
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:oResponseData
                                                             options:kNilOptions
                                                               error:&error];
    return jsonDict;
    // NSString *mystring;
    //[mystring isEqualToString:@"sometext"];
}

-(NSMutableArray *) getNextExchange:(int)index{
    NSMutableArray *exchange_info_array = [[NSMutableArray alloc] init];
    
    NSDictionary* exchange_info = [self.exchangesntickers_global objectAtIndex:index];
    NSString* name = [exchange_info objectForKey:@"name"];
    [exchange_info_array addObject:name];
    NSLog(@"name: %@", name);
    
    NSString* slug = [exchange_info objectForKey:@"slug"];
    [exchange_info_array addObject:slug];
    
    
    NSArray *tickers = [exchange_info objectForKey:@"tickers"];
    
    NSDictionary* tickers_dict = [tickers objectAtIndex:0];
    NSString *url_temp = [tickers_dict objectForKey:@"url"];
    
    NSString *url = [NSString stringWithFormat:@"http://www.coinvibes.com%@",url_temp];
    NSLog(url);
    
    NSDictionary *exchangeInfo_response =  [self make_APICallwithURL:url];
    //NSString *myString = [[NSString alloc] init];
    if (exchangeInfo_response !=nil) {
        NSString *price = [exchangeInfo_response objectForKey:@"bid"];
        [exchange_info_array addObject:price];
        NSLog(@"price: %@", price);
        
        NSDictionary *base_currency_dict = [exchangeInfo_response objectForKey:@"base_currency"];
        // NSLog(@"price: %@", base_currency_dict);
        NSString *base_currency = [base_currency_dict objectForKey:@"code"];
        
        NSDictionary *quote_currency_dict = [exchangeInfo_response objectForKey:@"quote_currency"];
        NSString *quote_currency = [quote_currency_dict objectForKey:@"code"];
        
        NSString *unit = [[NSString alloc] initWithFormat:@"%@/%@",base_currency,quote_currency];
        [exchange_info_array addObject:[unit uppercaseString]];
        
        [exchange_info_array addObject:base_currency];
        [exchange_info_array addObject:quote_currency];
        
        NSLog(@"unit: %@", unit);
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Opps...something went wrong."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dimiss"
                                              otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    //return name,slug,price,unit,basecurr,quote_currency....
    return exchange_info_array;
    
}

-(NSMutableArray *) getNextUnit:(int)index andtickers:(NSMutableArray*)tickers{
    NSMutableArray *exchange_info_array = [[NSMutableArray alloc] init];
    
    //  NSArray *tickers = [exchange_info objectForKey:@"tickers"];
    
    NSDictionary* tickers_dict = [tickers objectAtIndex:index];
    
    NSString *url_temp = [tickers_dict objectForKey:@"url"];
    
    NSString *url = [NSString stringWithFormat:@"http://www.coinvibes.com%@",url_temp];
    NSLog(url);
    NSDictionary *exchangeInfo_response =  [self make_APICallwithURL:url];
    if (exchangeInfo_response !=nil) {
        
        NSString *price = [exchangeInfo_response objectForKey:@"bid"];
        [exchange_info_array addObject:price];
        NSLog(@"price: %@", price);
        
        NSDictionary *base_currency_dict = [exchangeInfo_response objectForKey:@"base_currency"];
        // NSLog(@"price: %@", base_currency_dict);
        NSString *base_currency = [base_currency_dict objectForKey:@"code"];
        [exchange_info_array addObject:base_currency];
        
        NSDictionary *quote_currency_dict = [exchangeInfo_response objectForKey:@"quote_currency"];
        NSString *quote_currency = [quote_currency_dict objectForKey:@"code"];
        [exchange_info_array addObject:quote_currency];
        
        NSString *unit = [[NSString alloc] initWithFormat:@"%@/%@",base_currency,quote_currency];
        //[exchange_info_array addObject:[unit uppercaseString]];
        NSLog(@"unit: %@", unit);
        //return price,base_currency and quote_currency
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Opps...something went wrong."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dimiss"
                                              otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    return exchange_info_array;
}


-(NSMutableArray *) onTap_NextExchangeWithIndex:(int)tile_index {
    
    NSMutableArray *exchange_slugs_saved = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"ex_slugArray"]];
    NSString * saved_slug = [exchange_slugs_saved objectAtIndex:tile_index];
    int index;
    NSLog(@"global count is %d",[self.exchangesntickers_global count]);
    for (index=0; index<[self.exchangesntickers_global count];index++){
        
        NSDictionary* exchange_info = [self.exchangesntickers_global objectAtIndex:index];
        NSString* slug = [exchange_info objectForKey:@"slug"];
        if ([slug isEqualToString:saved_slug])
            break;
    }
    NSLog(@"index is %d",index);
    NSMutableArray *Exinfo = [[NSMutableArray alloc] init];
    if ((index+1) < [self.exchangesntickers_global count]){
        Exinfo = [self getNextExchange:index+1];
    }
    else {
        Exinfo = [self getNextExchange:0];
    }
    if (Exinfo == nil){
        return nil;
    }
    
    //[exchange_slugs_saved insertObject:[Exinfo objectAtIndex:1] atIndex:tile_index];
    [exchange_slugs_saved replaceObjectAtIndex:tile_index withObject:[Exinfo objectAtIndex:1]];
    
    NSMutableArray *exchange_names_saved = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"exNameArray"]];
    NSMutableArray *saved_baseCurrCode = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"base_currCode"]];
    NSMutableArray *saved_quoteCurrCode = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"quote_currCode"]];
    
    [exchange_names_saved replaceObjectAtIndex:tile_index withObject:[Exinfo objectAtIndex:0]];
    [saved_baseCurrCode replaceObjectAtIndex:tile_index withObject:[Exinfo objectAtIndex:4]];
    [saved_quoteCurrCode replaceObjectAtIndex:tile_index withObject:[Exinfo objectAtIndex:5]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:exchange_names_saved forKey:@"exNameArray"];
    [prefs setObject:exchange_slugs_saved forKey:@"ex_slugArray"];
    [prefs setObject:saved_baseCurrCode forKey:@"base_currCode"];
    [prefs setObject:saved_quoteCurrCode forKey:@"quote_currCode"];
    [prefs synchronize];
    
    [prefs synchronize];
    
    return Exinfo;
    
}
//routine for handling taps on exchange units
-(NSMutableArray *) onTap_NextUnitwithindex:(int)tile_index {
    int index;
    int index_unit;
    NSMutableArray* tickers = [[NSMutableArray alloc] init];
    
    NSMutableArray *exchange_slugs_saved = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"ex_slugArray"]];
    NSString * saved_slug = [exchange_slugs_saved objectAtIndex:tile_index];
    //NSLog(@"global count is %d",[self.exchangesntickers_global count]);
    
    for (index=0; index<[self.exchangesntickers_global count];index++){
        NSDictionary* exchange_info = [self.exchangesntickers_global objectAtIndex:index];
        NSString* slug = [exchange_info objectForKey:@"slug"];
        if ([slug isEqualToString:saved_slug]){
            tickers  = [exchange_info objectForKey:@"tickers"];
            break;
        }
    }
    //retrieve the saved units
    NSMutableArray *saved_baseCurrCode = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"base_currCode"]];
    NSMutableArray *saved_quoteCurrCode = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"quote_currCode"]];
    
    NSString * baseCode_saved = [saved_baseCurrCode objectAtIndex:tile_index];
    NSString * quoteCode_saved = [saved_quoteCurrCode objectAtIndex:tile_index];
    
    //Do a quick search and to find them in the tickers array, fetch the index
    for(index_unit=0; index_unit<[tickers count];index_unit++){
        NSDictionary* exchange_info = [tickers objectAtIndex:index_unit];
        NSDictionary* base_currency = [exchange_info objectForKey:@"base_currency"];
        NSString *base_currency_code = [base_currency objectForKey:@"code"];
        
        NSDictionary *quote_currency = [exchange_info objectForKey:@"quote_currency"];
        NSString *quote_currency_code = [quote_currency objectForKey:@"code"];
        if ([base_currency_code isEqualToString:baseCode_saved] && [quote_currency_code isEqualToString:quoteCode_saved]){
            // tickers  = [exchange_info objectForKey:@"tickers"];
            //NSLog(@"--found index--");
            break;
        }
    }
    NSMutableArray *next_unitArray = [[NSMutableArray alloc] init];
    
    if ((index_unit+1) < [tickers count]){
        //next_unitArray = [self getNextExchange:index+1];
        //pass index + 1 to a new function, which then retrives the url of that index
        next_unitArray = [self getNextUnit:index_unit+1 andtickers:tickers];
        
    }
    else {
        //pass index + 1 to a new function, which then retrives the url of that index
        next_unitArray = [self getNextUnit:0 andtickers:tickers];
    }
    if (next_unitArray == nil){
        return nil;
    }
    
    [saved_quoteCurrCode replaceObjectAtIndex:tile_index withObject:[next_unitArray objectAtIndex:2]];
    [saved_baseCurrCode replaceObjectAtIndex:tile_index withObject:[next_unitArray objectAtIndex:1]];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:saved_baseCurrCode forKey:@"base_currCode"];
    [prefs setObject:saved_quoteCurrCode forKey:@"quote_currCode"];
    [prefs synchronize];
    
    return next_unitArray;
    
}

//Fetch Price using saved user preference (slug and UNIT)
-(NSString *) returnPriceforSavedPreference:(int)tile_index {
    
    int index;
    int index_unit;
    NSMutableArray* tickers = [[NSMutableArray alloc] init];
    
    NSMutableArray *exchange_slugs_saved = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"ex_slugArray"]];
    NSString * saved_slug = [exchange_slugs_saved objectAtIndex:tile_index];
    //NSLog(@"global count is %d",[self.exchangesntickers_global count]);
    
    for (index=0; index<[self.exchangesntickers_global count];index++){
        NSDictionary* exchange_info = [self.exchangesntickers_global objectAtIndex:index];
        NSString* slug = [exchange_info objectForKey:@"slug"];
        if ([slug isEqualToString:saved_slug]){
            tickers  = [exchange_info objectForKey:@"tickers"];
            break;
        }
    }
    //retrieve the saved units
    NSMutableArray *saved_baseCurrCode = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"base_currCode"]];
    NSMutableArray *saved_quoteCurrCode = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"quote_currCode"]];
    
    NSString * baseCode_saved = [saved_baseCurrCode objectAtIndex:tile_index];
    NSString * quoteCode_saved = [saved_quoteCurrCode objectAtIndex:tile_index];
    NSLog(@"saved base %@",baseCode_saved);
    NSLog(@"saved quote%@", quoteCode_saved);
    
    
    //Do a quick search and to find them in the tickers array, fetch the index
    for(index_unit=0; index_unit<[tickers count];index_unit++){
        NSDictionary* exchange_info = [tickers objectAtIndex:index_unit];
        NSDictionary* base_currency = [exchange_info objectForKey:@"base_currency"];
        NSString *base_currency_code = [base_currency objectForKey:@"code"];
        
        NSDictionary *quote_currency = [exchange_info objectForKey:@"quote_currency"];
        NSString *quote_currency_code = [quote_currency objectForKey:@"code"];
        
        NSLog(@"found base %@",base_currency_code);
        NSLog(@"found quote%@", quote_currency_code);
        
        
        if ([base_currency_code isEqualToString:baseCode_saved] && [quote_currency_code isEqualToString:quoteCode_saved]){
            // tickers  = [exchange_info objectForKey:@"tickers"];
            NSLog(@"--found index!!!");
            break;
        }
    }
    if (index_unit == [tickers count])
        return @"";
    
    NSDictionary* tickers_dict = [tickers objectAtIndex:index_unit];
    
    NSString *url_temp = [tickers_dict objectForKey:@"url"];
    NSString *url = [NSString stringWithFormat:@"http://www.coinvibes.com%@",url_temp];
    // NSLog(url);
    
    NSDictionary *exchangeInfo_response =  [self make_APICallwithURL:url];
    if (exchangeInfo_response != nil){
        NSString *price = [exchangeInfo_response objectForKey:@"bid"];
        
        return price;
    }
    else{
        return @"";
    }
    
    
}

-(IBAction)Tile_title_1l:(id)sender{
    
    
    NSMutableArray *NextExchange_info= [[NSMutableArray alloc] initWithArray:[self onTap_NextExchangeWithIndex:0]];
    
    if (NextExchange_info != nil){
        [Tile_title_1l setTitle:[NextExchange_info objectAtIndex:0] forState: UIControlStateNormal];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_1l.text = [formatter stringFromNumber:[NextExchange_info objectAtIndex:2]];
        [Tile_unit_1l setTitle:[NextExchange_info objectAtIndex:3] forState: UIControlStateNormal];
    }
}

-(IBAction)Tile_title_1r:(id)sender{
    NSMutableArray *NextExchange_info= [[NSMutableArray alloc] initWithArray:[self onTap_NextExchangeWithIndex:1]];
    if (NextExchange_info != nil){
        [Tile_title_1r setTitle:[NextExchange_info objectAtIndex:0] forState: UIControlStateNormal];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_1r.text = [formatter stringFromNumber:[NextExchange_info objectAtIndex:2]];
        [Tile_unit_1r setTitle:[NextExchange_info objectAtIndex:3] forState: UIControlStateNormal];
    }
}

-(IBAction)Tile_title_2l:(id)sender{
    
    
    NSMutableArray *NextExchange_info= [[NSMutableArray alloc] initWithArray:[self onTap_NextExchangeWithIndex:2]];
    if (NextExchange_info != nil){
        [Tile_title_2l setTitle:[NextExchange_info objectAtIndex:0] forState: UIControlStateNormal];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_2l.text = [formatter stringFromNumber:[NextExchange_info objectAtIndex:2]];
        [Tile_unit_2l setTitle:[NextExchange_info objectAtIndex:3] forState: UIControlStateNormal];
        
    }
}

-(IBAction)Tile_title_2r:(id)sender{
    NSMutableArray *NextExchange_info= [[NSMutableArray alloc] initWithArray:[self onTap_NextExchangeWithIndex:3]];
    if (NextExchange_info != nil){
        [Tile_title_2r setTitle:[NextExchange_info objectAtIndex:0] forState: UIControlStateNormal];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_2r.text = [formatter stringFromNumber:[NextExchange_info objectAtIndex:2]];
        [Tile_unit_2r setTitle:[NextExchange_info objectAtIndex:3] forState: UIControlStateNormal];
    }
}


-(IBAction)Tile_title_3l:(id)sender{
    NSMutableArray *NextExchange_info = [[NSMutableArray alloc] initWithArray:[self onTap_NextExchangeWithIndex:4]];
    if (NextExchange_info != nil){
        [Tile_title_3l setTitle:[NextExchange_info objectAtIndex:0] forState: UIControlStateNormal];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_3l.text = [formatter stringFromNumber:[NextExchange_info objectAtIndex:2]];
        [Tile_unit_3l setTitle:[NextExchange_info objectAtIndex:3] forState: UIControlStateNormal];
    }
}

-(IBAction)Tile_title_3r:(id)sender{
    NSMutableArray *NextExchange_info= [[NSMutableArray alloc] initWithArray:[self onTap_NextExchangeWithIndex:5]];
    if (NextExchange_info != nil){
        [Tile_title_3r setTitle:[NextExchange_info objectAtIndex:0] forState: UIControlStateNormal];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_3r.text = [formatter stringFromNumber:[NextExchange_info objectAtIndex:2]];
        [Tile_unit_3r setTitle:[NextExchange_info objectAtIndex:3] forState: UIControlStateNormal];
    }
    
}

-(IBAction)Tile_unit_1l:(id)sender{
    
    NSMutableArray *next_unitArray = [[NSMutableArray alloc] initWithArray:[self onTap_NextUnitwithindex:0]];
    if (next_unitArray != nil){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_1l.text = [formatter stringFromNumber:[next_unitArray objectAtIndex:0]];
        NSString *unit = [[NSString alloc] initWithFormat:@"%@/%@",[next_unitArray objectAtIndex:1],[next_unitArray objectAtIndex:2]];
        
        [Tile_unit_1l setTitle:[unit uppercaseString] forState: UIControlStateNormal];
    }
}
-(IBAction)Tile_unit_1r:(id)sender{
    
    
    NSMutableArray *next_unitArray = [[NSMutableArray alloc] initWithArray:[self onTap_NextUnitwithindex:1]];
    if (next_unitArray != nil){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_1r.text = [formatter stringFromNumber:[next_unitArray objectAtIndex:0]];
        NSString *unit = [[NSString alloc] initWithFormat:@"%@/%@",[next_unitArray objectAtIndex:1],[next_unitArray objectAtIndex:2]];
        
        [Tile_unit_1r setTitle:[unit uppercaseString] forState: UIControlStateNormal];
    }
    
}

-(IBAction)Tile_unit_2l:(id)sender{
    NSMutableArray *next_unitArray = [[NSMutableArray alloc] initWithArray:[self onTap_NextUnitwithindex:2]];
    if (next_unitArray != nil){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_2l.text = [formatter stringFromNumber:[next_unitArray objectAtIndex:0]];
        NSString *unit = [[NSString alloc] initWithFormat:@"%@/%@",[next_unitArray objectAtIndex:1],[next_unitArray objectAtIndex:2]];
        
        [Tile_unit_2l setTitle:[unit uppercaseString] forState: UIControlStateNormal];
    }
}


-(IBAction)Tile_unit_2r:(id)sender{
    NSMutableArray *next_unitArray = [[NSMutableArray alloc] initWithArray:[self onTap_NextUnitwithindex:3]];
    if (next_unitArray != nil){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_2r.text = [formatter stringFromNumber:[next_unitArray objectAtIndex:0]];
        NSString *unit = [[NSString alloc] initWithFormat:@"%@/%@",[next_unitArray objectAtIndex:1],[next_unitArray objectAtIndex:2]];
        
        [Tile_unit_2r setTitle:[unit uppercaseString] forState: UIControlStateNormal];
    }
}
-(IBAction)Tile_unit_3l:(id)sender{
    
    NSMutableArray *next_unitArray = [[NSMutableArray alloc] initWithArray:[self onTap_NextUnitwithindex:4]];
    if (next_unitArray != nil){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_3l.text = [formatter stringFromNumber:[next_unitArray objectAtIndex:0]];
        NSString *unit = [[NSString alloc] initWithFormat:@"%@/%@",[next_unitArray objectAtIndex:1],[next_unitArray objectAtIndex:2]];
        
        [Tile_unit_3l setTitle:[unit uppercaseString] forState: UIControlStateNormal];
    }
}
-(IBAction)Tile_unit_3r:(id)sender{
    
    NSMutableArray *next_unitArray = [[NSMutableArray alloc] initWithArray:[self onTap_NextUnitwithindex:5]];
    if (next_unitArray != nil){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Tile_price_3r.text = [formatter stringFromNumber:[next_unitArray objectAtIndex:0]];
        NSString *unit = [[NSString alloc] initWithFormat:@"%@/%@",[next_unitArray objectAtIndex:1],[next_unitArray objectAtIndex:2]];
        
        [Tile_unit_3r setTitle:[unit uppercaseString] forState: UIControlStateNormal];
    }
}

@end
