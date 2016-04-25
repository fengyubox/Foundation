#import <TomboKit/TomboKit.h>
#import <TomboAFNetworking/TomboAFNetworking.h>

NSString * const TomboKitTomboPaymentsURL = @"https://api.tom.bo/payments";
NSString * const TomboKitTomboProductsURL = @"https://api.tom.bo/products";

@implementation TomboKitAPI {
    // TODO: Split _URLSessionManager
    TomboAFURLSessionManager *_URLSessionManager;
}

- (void)postPayments:(NSString *)productIdentifier
            quantity:(NSInteger)quantity
         requestData:(NSData *)requestData
 applicationUsername:(NSString *)applicationUsername
             success:(void (^)(NSDictionary *))success
             failure:(void (^)(NSError *))failure
{
    // TODO: show detailed log
    TomboKitDebugLog(@"TomboAPI::postPayments");

    if (_URLSessionManager) {
        failure([[NSError alloc] initWithDomain:@"TomboKitErrorDomain"
                                           code:0
                                       userInfo:@{}
        ]);
    }

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _URLSessionManager = [[TomboAFURLSessionManager alloc] initWithSessionConfiguration:configuration];
#ifdef DEBUG
    _URLSessionManager.securityPolicy.validatesDomainName = NO;
    _URLSessionManager.securityPolicy.allowInvalidCertificates = YES;
    TomboKitDebugLog(@"ALLOW INVALID CERTIFICATES");
#endif

    NSObject *appUsername = applicationUsername;
    if (appUsername == nil) {
        appUsername = [NSNull null];
    }

    NSDictionary *parameters = @{@"payments": @[@{
                                                    @"productIdentifier": productIdentifier,
                                                    @"quantity": [NSNumber numberWithInteger:quantity],
                                                    @"requestData": [NSNull null],
                                                    @"applicationUsername": appUsername
                                                    }]};
    NSError *serializerError = nil;
    NSMutableURLRequest *request = [[TomboAFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:TomboKitTomboPaymentsURL parameters:parameters error:&serializerError];
    _URLSessionManager.responseSerializer = [TomboAFJSONResponseSerializer serializer];

    NSURLSessionDataTask *dataTask = [_URLSessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        _URLSessionManager = nil;

        TomboKitDebugLog(@"TomboAPI::postPayments error: %@ response: %@", error, response);
        if (error) {
            NSLog(@"Error(%@): %@", NSStringFromClass([self class]), error);
            failure(error);
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *posixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            [dateFormatter setLocale:posixLocale];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

            NSDictionary *data = [responseObject objectForKey:@"data"];
            success(data);
        }
    }];

    [dataTask resume];
}

- (void)getProducts:(NSArray *)productIdentifiers
           quantity:(NSInteger)quantity
        requestData:(NSData *)requestData
applicationUsername:(NSString *)applicationUsername
            success:(void (^)(NSDictionary *))success
            failure:(void (^)(NSError *))failure
{
    TomboKitDebugLog(@"TomboAPI::getProducts productIdentifiers: %@", productIdentifiers);

    if (_URLSessionManager) {
        failure([[NSError alloc] initWithDomain:@"TomboKitErrorDomain"
                                           code:0
                                       userInfo:@{}
        ]);
    }

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _URLSessionManager = [[TomboAFURLSessionManager alloc] initWithSessionConfiguration:configuration];
#ifdef DEBUG
    _URLSessionManager.securityPolicy.validatesDomainName = NO;
    _URLSessionManager.securityPolicy.allowInvalidCertificates = YES;
    TomboKitDebugLog(@"ALLOW INVALID CERTIFICATES");
#endif

    NSArray *sortedProductIdentifiers = [productIdentifiers sortedArrayUsingSelector:@selector(compare:)];

    NSDictionary *parameters = @{@"product_identifier": [sortedProductIdentifiers componentsJoinedByString: @","]};
    NSError *serializerError = nil;
    NSMutableURLRequest *request = [[TomboAFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:TomboKitTomboProductsURL parameters:parameters error:&serializerError];

    _URLSessionManager.responseSerializer = [TomboAFJSONResponseSerializer serializer];

    NSURLSessionDataTask *dataTask = [_URLSessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        _URLSessionManager = nil;
        TomboKitDebugLog(@"TomboAPI::getProducts error: %@ response: %@", error, response);
        if (error) {
            NSLog(@"Error(%@): %@", NSStringFromClass([self class]), error);
            failure(error);
        } else {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            success(data);
        }
    }];

    [dataTask resume];
}

@end