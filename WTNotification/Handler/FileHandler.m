//
//  FileHandler.m
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/21/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "FileHandler.h"

@implementation FileHandler

+(FileHandler*)sharedHandler{
    static FileHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[FileHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}

- (instancetype)init{
    
    if(self = [super init]){
        
        
    }
    return self;
}

#pragma mark - Path Helper

+ (NSString*) getFileNameOfType:(int) type{
    
    NSString *extension = @"";
    
    switch (type) {
        case kFileTypeAudio:
            extension = @".caf";
            break;
        case kFileTypeVideo:
            extension = @".mp4";
            break;
        case kFileTypePhoto:
            extension = @".png";
            break;
        case kFileTypeOthers:
            extension = @"";
            break;
            
        default:
            break;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyyMMddHHmmss"];
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@%@",stringFromDate, extension];
    
    return fileName;
}

- (NSString *)pathToWalkieTalkieDirectory {
 
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask,
                                                                        YES) lastObject];
    
    NSString *fileFolder = [documentsDirectory stringByAppendingPathComponent:@"WTNotifiactionFile"];
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:fileFolder isDirectory:&isDir] && isDir == NO) {
        
        [fileManager createDirectoryAtPath:fileFolder
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
    }
    
    return fileFolder;
}



- (NSString *)pathToFileFolderOfType:(int)type {
    
    NSString *fileFolder;
    NSString *walkieTakieDirectory = [self pathToWalkieTalkieDirectory];
    
    
    switch (type) {
        case kFileTypeAudio:
            fileFolder = [walkieTakieDirectory stringByAppendingPathComponent:@"Audio"];
            break;
        case kFileTypeVideo:
            fileFolder = [walkieTakieDirectory stringByAppendingPathComponent:@"Video"];
            break;
        case kFileTypePhoto:
            fileFolder = [walkieTakieDirectory stringByAppendingPathComponent:@"Photo"];
            break;
        case kFileTypeOthers:
            fileFolder = [walkieTakieDirectory stringByAppendingPathComponent:@"Others"];
            break;
            
        default:
            return @"";
            break;
    }
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:fileFolder isDirectory:&isDir] && isDir == NO) {
        
        [fileManager createDirectoryAtPath:fileFolder
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
    }
    
    return fileFolder;
}

- (NSString *)pathToFileWithFileName:(NSString *)fileName OfType:(int)type {
    
    return [[self pathToFileFolderOfType:type] stringByAppendingPathComponent:fileName];
}

#pragma mark - Delete

- (BOOL)deleteWalkieTalkieDirectory {
    
    NSString *walkieTalkieDirectory = [self pathToWalkieTalkieDirectory];
    
    return [[NSFileManager defaultManager] removeItemAtPath:walkieTalkieDirectory error:nil];
}

- (BOOL)deleteFileWithFileName:(NSString *)fileName OfType:(int)type {
    
    NSString *filePath = [self pathToFileWithFileName:fileName OfType:type];
    
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}


#pragma mark - Write & Read Data

- (NSString *)writeData:(NSData *)fileData toFileName:(NSString *)fileName ofType:(int)type {
    
    NSString *filePath = [self pathToFileWithFileName:fileName OfType:type];
    
    BOOL success = [fileData writeToFile:filePath atomically:YES];
    
    if(!success){
        //show Alert
        
    }
    
    return filePath;
}

-(NSData *)dataFromFilePath:(NSString *)filePath{
    
    NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
    NSData *myData = [NSData dataWithContentsOfURL:filePathURL];
    
    return myData;
}



-(NSArray *)encodedStringChunksWithFile:(NSString *)fileName OfType:(int)type{
    
    
    switch (type) {
        case kFileTypeAudio:
            
            break;
        case kFileTypeVideo:

            break;
        case kFileTypePhoto:
            
            break;
        case kFileTypeOthers:
            
            break;
            
        default:

            break;
    }
    
    
    NSString *filePath = [self pathToFileWithFileName:fileName OfType:type];
    NSData *fileData = [self dataFromFilePath:filePath];
    
    printf("File Data Lenth : %lu", (unsigned long)[fileData length]);
    
    
    int index = 0;
    int totalLen = (int)[fileData length];
    
    NSMutableArray *dataChunks = [[NSMutableArray alloc ]init];
    NSMutableArray *chunkStringArray = [[NSMutableArray alloc] init];
    
    while (index < totalLen) {
        
        int space = (totalLen - index > CHUNKSIZE) ? CHUNKSIZE : totalLen - index;
        
        NSData *chunk = [fileData subdataWithRange:NSMakeRange(index, space)];
        [dataChunks addObject:chunk];
        index += CHUNKSIZE;
    }
    
    for (int i =0; i < dataChunks.count; i++) {
        [chunkStringArray addObject:[[dataChunks objectAtIndex:i] base64EncodedStringWithOptions:0]];
    }
    
    return chunkStringArray;
}


#pragma mark - Image Helper

-(NSString *)saveBase64Image:(NSString *)base64Image ofDeviceID:(NSString *)deviceID{
    
    NSString *imageName;
    if(base64Image.length){
        
        UIImage *receivedImage = [[FileHandler sharedHandler] decodeBase64ToImage:base64Image];
        imageName = [NSString stringWithFormat:@"%@.png", deviceID];
        
        NSData *imageData = UIImagePNGRepresentation(receivedImage);
        NSString *imagePath = [[FileHandler sharedHandler] writeData:imageData toFileName:imageName ofType:kFileTypePhoto];
        
    }else{
        
        imageName = @"";
    }
    
    return imageName;
}

-(UIImage *)resizeImage:(UIImage *)image {
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 50.0;
    float maxWidth = 50.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
    
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}


@end
