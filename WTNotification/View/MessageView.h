
#import <UIKit/UIKit.h>

@class MessageData;

// TAG used in our custom table view cell to retreive this view
#define MESSAGE_VIEW_TAG (100)

@interface MessageView : UIView

@property (nonatomic, assign) MessageData *messageData;

// Class method for computing a view height based on a given message Data
+ (CGFloat)viewHeightForTranscript:(MessageData *)messageData;
@end
