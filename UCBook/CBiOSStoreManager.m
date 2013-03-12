/*
 *  CBiOSStoreManager.mm
 *  CloudBox Cross-Platform Framework Project
 *
 *  Created by Cloud on 2012/10/30.
 *  Copyright 2011 Cloud Hsu. All rights reserved.
 *
 */

#import "CBiOSStoreManager.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@implementation CBiOSStoreManager

static CBiOSStoreManager* _sharedInstance = nil;

+(CBiOSStoreManager*)sharedInstance
{
	@synchronized([CBiOSStoreManager class])
	{
		if (!_sharedInstance)
			[[self alloc] init];
        
		return _sharedInstance;
	}
	return nil;
}

+(id)alloc
{
	@synchronized([CBiOSStoreManager class])
	{
		NSAssert(_sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.\n");
		_sharedInstance = [super alloc];
		return _sharedInstance;
	}
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here
	}
	return self;
}

-(void)initialStore
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}
-(void)releaseStore
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)buy:(NSString*)buyProductIDTag
{
    [self requestProductData:buyProductIDTag];
}

-(bool)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}   

-(void)requestProductData:(NSString*)buyProductIDTag
{
    NSLog(@"---------Request product information------------\n");
    _buyProductIDTag = [buyProductIDTag retain];
    NSArray *product = [[NSArray alloc] initWithObjects:buyProductIDTag,nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
    [product release];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{  
    NSLog(@"-----------Getting product information--------------\n");
    NSArray *myProduct = response.products;
    NSLog(@"Product ID:%@\n",response.invalidProductIdentifiers);
    NSLog(@"Product count: %d\n", [myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"Detail product info\n");
        NSLog(@"SKProduct description: %@\n", [product description]);
        NSLog(@"Product localized title: %@\n" , product.localizedTitle);
        NSLog(@"Product localized descitption: %@\n" , product.localizedDescription);
        NSLog(@"Product price: %@\n" , product.price);
        NSLog(@"Product identifier: %@\n" , product.productIdentifier);
    }
    SKPayment *payment = nil;
    //payment  = [SKPayment paymentWithProductIdentifier:_buyItemIDTag];
    //[_buyItemIDTag autorelease]
//    switch (buyType) {
//        case IAP0p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP0p99];    //支付$0.99
//            break;
//        case IAP1p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP1p99];    //支付$1.99
//            break;
//        case IAP4p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP4p99];    //支付$9.99
//            break;
//        case IAP9p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP9p99];    //支付$19.99
//            break;
//        case IAP24p99:
//            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP24p99];    //支付$29.99
//            break;
//        default:
//            break;
//    }
    if ([response.products count]>0) {
        payment = [SKPayment paymentWithProduct:[response.products objectAtIndex:0]];
        NSLog(@"---------Request payment------------\n");
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    [request autorelease];    
    
}
- (void)requestProUpgradeProductData:(NSString*)buyProductIDTag
{
    NSLog(@"------Request to upgrade product data---------\n");
    NSSet *productIdentifiers = [NSSet setWithObject:buyProductIDTag];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];    
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [SVProgressHUD dismiss]; 
    NSLog(@"-------Show fail message----------\n");
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"网络故障",NULL) message:[error localizedDescription]
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
    [alerView show];
    [alerView release];
}   

-(void) requestDidFinish:(SKRequest *)request
{
    [SVProgressHUD dismiss]; 
    NSLog(@"----------Request finished--------------\n");
    
}   

-(void) purchasedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----Purchased Transaction----\n");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
    [transactions release];
}    

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"-----Payment result--------\n");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                NSLog(@"-----Transaction purchased--------\n");
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"交易成功"
                                                              message:@"付款成功，您可以下载该书了!"
                                                              delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];   
                
                [alerView show];
                [alerView release];
                SharedApp.isPaySuccess = YES;
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                NSLog(@"-----Transaction Failed--------\n");
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"交易失败"
                                                               message:@"对不起，您的交易失败，请重新付费购买！"
                                                               delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];   
                
                [alerView2 show];
                [alerView2 release];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                NSLog(@"----- Already buy this product--------\n");
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"-----Transcation puchasing--------\n");
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction   
{
    NSLog(@"-----completeTransaction--------\n");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {   
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }   
    
    // Remove the transaction from the payment queue.   
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];   
    
}   

-(void)recordTransaction:(NSString *)product
{
    NSLog(@"-----Record transcation--------\n");
    // Todo: Maybe you want to save transaction result into plist.
}   

-(void)provideContent:(NSString *)product
{
    NSLog(@"-----Download product content--------\n");
}   

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Failed\n");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction
{   
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----Restore transaction--------\n");
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"-------Payment Queue----\n");
}

#pragma mark connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@\n",  [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{   
    
}   

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    switch([(NSHTTPURLResponse *)response statusCode]) {
        case 200:
        case 206:
            break;
        case 304:
            break;
        case 400:
            break;
        case 404:
            break;
        case 416:
            break;
        case 403:
            break;
        case 401:
        case 500:
            break;
        default:
            break;
    }
}   

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"test\n");
}   

-(void)dealloc
{
    [super dealloc];
}

@end