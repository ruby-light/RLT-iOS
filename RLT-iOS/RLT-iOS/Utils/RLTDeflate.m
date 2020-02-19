//
// Created by Alexey Chirkov on 10/02/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTDeflate.h"
#import "zlib.h"

@implementation RLTDeflate

+ (NSData *)rlt_compress:(NSData *)data {
    if (data.length == 0 || [self rlt_isCompressed:data]) {
        return data;
    }

    z_stream zStream;
    zStream.next_in = (Bytef *) data.bytes;
    zStream.avail_in = (uInt) data.length;
    zStream.total_out = 0;
    zStream.avail_out = 0;
    zStream.opaque = Z_NULL;
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;

    if (deflateInit2(&zStream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) != Z_OK) {
        return nil;
    }
    NSUInteger chunkSize = 16384;
    NSMutableData *compressed = [NSMutableData dataWithLength:chunkSize];
    do {
        if (zStream.total_out >= compressed.length) {
            [compressed increaseLengthBy:chunkSize];
        }
        zStream.next_out = compressed.mutableBytes + zStream.total_out;
        zStream.avail_out = (uInt) (compressed.length - zStream.total_out);
        deflate(&zStream, Z_FINISH);

    } while (zStream.avail_out == 0);
    deflateEnd(&zStream);
    [compressed setLength:zStream.total_out];
    return compressed;
}

+ (NSData *)rlt_decompress:(NSData *)data {
    if (data.length == 0 || ![self rlt_isCompressed:data]) {
        return data;
    }

    z_stream zStream;
    zStream.next_in = (Bytef *) data.bytes;
    zStream.avail_in = (uInt) data.length;
    zStream.total_out = 0;
    zStream.avail_out = 0;
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;

    if (inflateInit2(&zStream, 47) != Z_OK) {
        return nil;
    }

    NSMutableData *decompressed = [NSMutableData dataWithLength:data.length * 2];

    int status = 0;
    do {
        if (zStream.total_out >= decompressed.length) {
            [decompressed increaseLengthBy:data.length / 2];
        }
        zStream.next_out = decompressed.mutableBytes + zStream.total_out;
        zStream.avail_out = (uInt) (decompressed.length - zStream.total_out);
        status = inflate(&zStream, Z_SYNC_FLUSH);
    } while (status == Z_OK);

    if (inflateEnd(&zStream) != Z_OK) {
        return nil;
    }

    if (status != Z_STREAM_END) {
        return nil;
    }

    [decompressed setLength:zStream.total_out];
    return decompressed;
}

+ (BOOL)rlt_isCompressed:(NSData *)data {
    if (data.length < 2) {
        return NO;
    }
    const UInt8 *bytes = (const UInt8 *) data.bytes;
    UInt8 first = 0x1f;
    UInt8 second = 0x8b;
    return bytes[0] == first && bytes[1] == second;
}

@end