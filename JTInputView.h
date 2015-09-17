//
//  JTInputView.h
//  JapanDrama
//
//  Created by tmy on 14-8-9.
//  Copyright (c) 2014年 nobuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTFixedTextView.h"

@protocol JTInputViewDelegate;

@interface JTInputView : UIView<UITextViewDelegate>

@property (nonatomic, weak) id<JTInputViewDelegate, UITextViewDelegate> delegate;
@property (nonatomic, readonly) NSString *inputText;
@property (nonatomic, readonly) JTFixedTextView *textView;
@property (nonatomic, readonly) UIButton    *sendButton;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSArray  *accessoryViews;
@property (nonatomic, strong) IBOutlet UIScrollView *attachedScrollView;
@property (nonatomic) CGFloat horizontalTextViewMargin;
@property (nonatomic) CGFloat verticalTextViewMargin;
@property (nonatomic) CGFloat horizontalAccessoryMargin;
@property (nonatomic) CGFloat verticalAccessoryMargin;

@property (nonatomic) BOOL showSendButton;
@property (nonatomic) NSUInteger maxLineNumber;
@property (nonatomic) BOOL autoFollowKeyboard;
@property (nonatomic) BOOL enableWrapByReturn;

- (void)initViews;
- (void)clearInput;

@end

@protocol JTInputViewDelegate <NSObject>
@optional
- (void)JTInputViewDidChangeHeight:(JTInputView *)inputView;
- (void)JTInputViewDidPressSendButton:(JTInputView *)inputView;
- (void)JTInputViewDidEndEdit:(JTInputView *)inputView;

@end