//
//  rlt_deflate.m
//  rlt-analytics-tests
//
//  Created by Alexey Chirkov on 10/02/2020.
//  Copyright © 2020 Rubylight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLTDeflate.h"

static NSData *createArc4RandomNSDataWithSize(NSUInteger size) {
    NSMutableData *result = [NSMutableData dataWithCapacity:size];
    size_t iSize = sizeof(u_int32_t);
    NSUInteger length = size / iSize;
    for (u_int32_t i = 0; i < length; ++i) {
        u_int32_t randomBits = arc4random();
        [result appendBytes:(void *) &randomBits length:iSize];
    }
    return result;
}

@interface rlt_deflate : XCTestCase

@end

@implementation rlt_deflate

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSimpleData {
    NSString *in = @"RLT Test!";
    NSData *inputData = [in dataUsingEncoding:NSUTF8StringEncoding];
    NSData *compressed = [RLTDeflate rlt_compress:inputData];
    NSData *decompressed = [RLTDeflate rlt_decompress:compressed];
    NSString *out = [[NSString alloc] initWithData:decompressed encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(out, in);

    XCTAssertEqualObjects(compressed, [RLTDeflate rlt_compress:compressed]);
    XCTAssertEqualObjects(decompressed, [RLTDeflate rlt_decompress:decompressed]);

    NSData *nilData = nil;
    XCTAssertNil([RLTDeflate rlt_compress:nilData]);
    XCTAssertNil([RLTDeflate rlt_decompress:nilData]);

    NSData *emptyData = [NSData data];
    XCTAssertEqualObjects(emptyData, [RLTDeflate rlt_compress:emptyData]);
    XCTAssertEqualObjects(emptyData, [RLTDeflate rlt_decompress:emptyData]);
    XCTAssertEqual(0, [RLTDeflate rlt_compress:emptyData].length);
    XCTAssertEqual(0, [RLTDeflate rlt_decompress:emptyData].length);
}

- (void)testLongData {
    NSData *inputData = createArc4RandomNSDataWithSize(10 * 1024 * 1024);
    NSData *compressed = [RLTDeflate rlt_compress:inputData];
    NSData *decompressed = [RLTDeflate rlt_decompress:compressed];
    XCTAssertEqualObjects(inputData, decompressed);
}

@end
