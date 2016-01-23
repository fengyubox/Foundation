#import <StoreKit/StoreKit.h>
#import "AFNetworking.h"

NSString * const SKReceiptPropertyIsExpired = @"expired";
NSString * const SKReceiptPropertyIsRevoked = @"revoked";
NSString * const SKReceiptPropertyIsVolumePurchase = @"vpp";
NSString * const SKTomboProductsURL = @"http://tombo.titech.ac/products";

@implementation SKRequest

- (void)start
{
    // SKRequest is an abstract class.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)cancel
{
    // SKRequest is an abstract class.
    [self doesNotRecognizeSelector:_cmd];
}

@end

@implementation SKProductsRequest {
    NSSet *_productIdentifiers;
    SKProductsResponse *_productsResponse;
    AFURLSessionManager *_URLSessionManager;
}

@dynamic delegate;

// Initializes the request with the set of product identifiers.
- (instancetype)initWithProductIdentifiers:(NSSet/*<NSString *>*/ *)productIdentifiers
{
    _productIdentifiers = [productIdentifiers mutableCopy];
    return [super init];
}


// Sends the request to the Apple App Store.
- (void)start
{
    _productsResponse = nil;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _URLSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSDictionary *parameters = @{@"productIdentifiers": [[_productIdentifiers allObjects] mutableCopy]};
    NSError *serializerError = nil;
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:SKTomboProductsURL parameters:parameters error:&serializerError];
    _URLSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];

    NSURLSessionDataTask *dataTask = [_URLSessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        _URLSessionManager = nil;
        if (error) {
            NSLog(@"Error(%@): %@", NSStringFromClass([self class]), error);
            [self.delegate request:self didFailWithError:error];
        } else {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            NSArray *productsArray = [data objectForKey:@"products"];
            NSMutableArray *products = [[NSMutableArray alloc] init];
            for (NSDictionary *productDict in productsArray) {
                NSString *productIdentifier = [productDict objectForKey:@"productIdentifier"];
                NSString *localizedTitle = [productDict objectForKey:@"localizedTitle"];
                NSString *localizedDescription = [productDict objectForKey:@"localizedDescription"];
                NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:[productDict objectForKey:@"price"]];
                NSLocale *priceLocale = [[NSLocale alloc] initWithLocaleIdentifier:[productDict objectForKey:@"priceLocale"]];

                SKProduct *product = [[SKProduct alloc] initWithProductIdentifier:productIdentifier localizedTitle:localizedTitle localizedDescription:localizedDescription price:price priceLocale:priceLocale];
                [products addObject:product];
            }
            _productsResponse = [[SKProductsResponse alloc] initWithProducts:products];

            // NOTE: I don't know the sequence of calling these notification methods
            [self.delegate productsRequest:self didReceiveResponse:_productsResponse];
            [self.delegate requestDidFinish:self];
        }
    }];

    [dataTask resume];
}

// Cancels a previously started request.
- (void)cancel
{
    [_URLSessionManager.operationQueue cancelAllOperations];
}

@end

@implementation SKReceiptRefreshRequest

@dynamic delegate;

// Initialized a receipt refresh request with optional properties.
- (instancetype)initWithReceiptProperties:(NSDictionary/*<NSString *, id>*/ *)properties
{
    // FIXME: implement
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// Sends the request to the Apple App Store.
- (void)start
{
    // FIXME: implement
    [self doesNotRecognizeSelector:_cmd];
}

// Cancels a previously started request.
- (void)cancel
{
    // FIXME: implement
    [self doesNotRecognizeSelector:_cmd];
}

@end
