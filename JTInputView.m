//
//  JTInputView.m
//  JapanDrama
//
//  Created by tmy on 14-8-9.
//  Copyright (c) 2014年 nobuta. All rights reserved.
//

#import "JTInputView.h"

#define MAX_LINE_NUMBER 5
#define ACCESORY_VIEW_HORIZAONTAL_MARGIN 10
#define ACCESORY_VIEW_VERTICAL_MARGIN 10

@implementation JTInputView
{
    float                   _singleLineInputHeight;
    float                   _singleLineHeight;
    float                   _singleSendButtonOriginY;
    float                   _originalHeight;
    float                   _totalInputViewHeight;
    float                   _totalTranslationY;
    float                   _currentKeyboardHeight;
    int                     _lineNumber;
    UIScrollView            *_attachedScrollView;
    CGRect                  _originalStartFrame;
    UIEdgeInsets            _originalScrollViewContentInsets;
    BOOL                    _hasInitedViews;
    BOOL                    _firstShowKeyboard;
}
@synthesize attachedScrollView = _attachedScrollView;

- (void)setShowSendButton:(BOOL)showSendButton {
    _showSendButton = showSendButton;
    
    if (showSendButton) {
        if (!_sendButton) {
            [self addSendButton];
        }
    }else {
        if (_sendButton) {
            [_sendButton removeFromSuperview];
            _sendButton = nil;
        }
    }
    
    [self updateInputLayout];
}

- (void)setHorizontalTextViewMargin:(CGFloat)horizontalTextViewMargin {
    _horizontalTextViewMargin = horizontalTextViewMargin;
    [self updateInputLayout];
}

- (void)setVerticalTextViewMargin:(CGFloat)verticalTextViewMargin {
    _verticalTextViewMargin = verticalTextViewMargin;
    [self updateInputLayout];
}

- (void)setHorizontalAccessoryMargin:(CGFloat)horizontalAccessoryMargin {
    _horizontalAccessoryMargin = horizontalAccessoryMargin;
    [self updateInputLayout];
}

- (void)setVerticalAccessoryMargin:(CGFloat)verticalAccessoryMargin {
    _verticalAccessoryMargin = verticalAccessoryMargin;
    [self updateInputLayout];
}

- (void)updateInputLayout {
    CGFloat textViewWidth = self.frame.size.width - self.horizontalTextViewMargin * 2;
    if (self.showSendButton) {
        textViewWidth -= (_sendButton.frame.size.width + 10);
    }
    
    if (self.accessoryViews && self.accessoryViews.count > 0) {
        CGFloat accessoryRightX = self.showSendButton ? (_sendButton.frame.size.width + self.horizontalAccessoryMargin) : 0;
        
        for (UIView *accesoryView in self.accessoryViews) {
            textViewWidth -= (accesoryView.frame.size.width + self.horizontalAccessoryMargin);
        }
    }
    
    CGRect textViewFrame = _textView.frame;
    textViewFrame.size.width = textViewWidth;
    _textView.frame = textViewFrame;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (backgroundView != _backgroundView) {
        [_backgroundView removeFromSuperview];
        _backgroundView = backgroundView;
        [self insertSubview:_backgroundView atIndex:0];
    }
}

- (NSString *)inputText {
    return _textView.text;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self internalInit];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self internalInitViews];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        [self internalInit];
    }
    
    return self;
}

- (void)internalInit {
    _showSendButton = true;
    _horizontalTextViewMargin = 10;
    _verticalTextViewMargin = 7;
    _horizontalAccessoryMargin = ACCESORY_VIEW_HORIZAONTAL_MARGIN;
    _verticalAccessoryMargin = ACCESORY_VIEW_VERTICAL_MARGIN;
    self.maxLineNumber = MAX_LINE_NUMBER;
    self.autoFollowKeyboard = YES;
    self.enableWrapByReturn = YES;
}

- (void)internalInitViews {
    _hasInitedViews = YES;
    _totalInputViewHeight = self.frame.size.height;
    _lineNumber = 0;
    _originalHeight = 0;
    
    CGFloat textViewWidth = self.frame.size.width - self.horizontalTextViewMargin * 2;
    
    if (self.showSendButton) {
        [self addSendButton];
        textViewWidth -= (_sendButton.frame.size.width + self.horizontalAccessoryMargin);
    }
    
    if (self.accessoryViews && self.accessoryViews.count > 0) {
        CGFloat accessoryRightX = self.showSendButton ? (_sendButton.frame.size.width + self.horizontalAccessoryMargin) : 0;
        
        for (UIView *accesoryView in self.accessoryViews) {
            accessoryRightX += (accesoryView.frame.size.width + self.horizontalAccessoryMargin);
            CGRect accesoryFrame = accesoryView.frame;
            accesoryFrame.origin.x = self.frame.size.width - accessoryRightX;
            accesoryView.frame = accesoryFrame;
            CGPoint accesoryCenter = accesoryView.center;
            accesoryCenter.y = self.frame.size.height / 2;
            accesoryView.center = accesoryCenter;
            [self addSubview:accesoryView];
            
            textViewWidth -= (accesoryView.frame.size.width + self.horizontalAccessoryMargin);
        }
    }
    
    _textView = [[JTFixedTextView alloc] initWithFrame:CGRectMake(self.horizontalTextViewMargin, self.verticalTextViewMargin,  textViewWidth, self.frame.size.height - self.verticalTextViewMargin * 2)];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.showsHorizontalScrollIndicator = NO;
    _textView.showsVerticalScrollIndicator = NO;
    _textView.scrollsToTop = NO;
    _textView.contentInset = UIEdgeInsetsZero;
    _textView.layer.cornerRadius = 2;
    _textView.delegate = self;
    //        _textView.textContainerInset = UIEdgeInsetsMake(0, 0, -2, 0);
    
    [self addSubview:_textView];
    
    
    
    self.autoresizingMask = UIViewAutoresizingNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeText:) name:UITextViewTextDidChangeNotification object:_textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
    
    [self initViews];
}


- (void)initViews {
    //for subclass
}

- (void)addSendButton {
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    CGFloat defaultButtonWidth = 52;
    CGFloat defaultButtonHeight = 30;
    _sendButton.frame = CGRectMake(self.frame.size.width - self.horizontalTextViewMargin - defaultButtonWidth, self.frame.size.height - self.verticalTextViewMargin - defaultButtonHeight, defaultButtonWidth, defaultButtonHeight);
    _sendButton.enabled = NO;
    [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendButton];
}

- (void)adjustAccesoryViewsFrameWithY:(CGFloat)frameY{
    if (self.accessoryViews && self.accessoryViews.count > 0) {
        for (UIView *accesoryView in self.accessoryViews) {
            CGRect accesoryFrame = accesoryView.frame;
            accesoryFrame.origin.y += frameY;
            accesoryView.frame = accesoryFrame;
        }
    }
}

- (void)resetAccesoryViewsFrame {
    if (self.accessoryViews && self.accessoryViews.count > 0) {
        for (UIView *accesoryView in self.accessoryViews) {
            CGPoint accesoryCenter = accesoryView.center;
            accesoryCenter.y = _originalStartFrame.size.height / 2;
            accesoryView.center = accesoryCenter;
        }
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview && !_hasInitedViews) {
        [self internalInitViews];
        
        _originalStartFrame = self.frame;
        _singleLineHeight = _textView.frame.size.height;
        _singleLineInputHeight = self.frame.size.height;
        _singleSendButtonOriginY = self.sendButton.frame.origin.y;
        [_textView setContentOffset:CGPointMake(0, 2) animated:NO];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sendButtonDidPress:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(JTInputViewDidPressSendButton:)]) {
        [self.delegate JTInputViewDidPressSendButton:self];
    }
}

- (void)clearInput {
    _textView.text = @"";
    
    _originalHeight = 0;
    _lineNumber = 0;
    CGRect textViewFrame = _textView.frame;
    textViewFrame.size.height = _singleLineHeight;
    _textView.frame = textViewFrame;
    CGRect frame = self.frame;
    frame.size.height = _singleLineInputHeight;
    self.frame = frame;
    
    if (self.showSendButton) {
        _sendButton.enabled = NO;
        CGRect sendBtnFrame = _sendButton.frame;
        sendBtnFrame.origin.y = _singleSendButtonOriginY;
        _sendButton.frame = sendBtnFrame;
    }
    
    [self resetAccesoryViewsFrame];
    
    _totalInputViewHeight = _singleLineInputHeight;
    _totalTranslationY = 0;
    
    if (_backgroundView) {
        CGRect backgroundFrame = _backgroundView.frame;
        backgroundFrame.size.height = _singleLineInputHeight;
        _backgroundView.frame = backgroundFrame;
    }
    
    [_textView resignFirstResponder];
}

- (void)setScrollViewBottomInset:(float)bottomInset {
    UIEdgeInsets contentInsets = _attachedScrollView.contentInset;
    contentInsets.bottom = bottomInset;
    _attachedScrollView.contentInset = contentInsets;
    
    UIEdgeInsets indicatorInsets = _attachedScrollView.scrollIndicatorInsets;
    indicatorInsets.bottom = bottomInset;
    _attachedScrollView.scrollIndicatorInsets = indicatorInsets;
}
 

- (void)keyboardWillAppear:(NSNotification *)notification {
    if (!self.autoFollowKeyboard) return;
    
    [self.layer removeAllAnimations];
    
    if (!_firstShowKeyboard) {
        _firstShowKeyboard = YES;
        if (self.attachedScrollView) {
            _originalScrollViewContentInsets = self.attachedScrollView.contentInset;
        }
    }
    
    CGRect keyboardStartFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _currentKeyboardHeight = frame.size.height;
    
    BOOL shouldAnimation = (keyboardStartFrame.origin.y == [UIScreen mainScreen].bounds.size.height);
    
    void(^updateFrame)() = ^(){
        if (self.superview) {
            CGRect parentFrame = self.superview.frame;
            CGRect inputFrame = self.frame;
            inputFrame.origin.y = parentFrame.size.height - frame.size.height - self.frame.size.height;
            self.frame = inputFrame;
        }

    };
    
    if (shouldAnimation) {
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
        
        updateFrame();
        
        [UIView commitAnimations];
    }else {
        updateFrame();
    }
    
    if (_attachedScrollView) {
        [self setScrollViewBottomInset:frame.size.height + self.frame.size.height];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    if (!self.autoFollowKeyboard) return;
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    if (self.superview) {
        CGRect inputFrame = self.frame;
        inputFrame.origin.y = _originalStartFrame.origin.y;
        self.frame = inputFrame;
    }
    [UIView commitAnimations];
    
    if (_attachedScrollView) {
        [self setScrollViewBottomInset:_originalScrollViewContentInsets.bottom];
    }
}

- (void)keyboardDidDisappear:(NSNotification *)notification {
    if (!self.autoFollowKeyboard) return;
}


- (void)textViewDidChangeText:(NSNotification *)notification {
    if (self.showSendButton) {
        if([_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].length == 0) {
            _sendButton.enabled = NO;
        }else {
            _sendButton.enabled =  YES;
        }
    }
    
    CGRect frame = [_textView.text boundingRectWithSize:CGSizeMake(_textView.frame.size.width - 10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: _textView.font} context:nil];
    
    float height = frame.size.height;
    
    if(_originalHeight == 0) {
        _originalHeight = height;
        _lineNumber= 1;
        [_textView setContentOffset:CGPointMake(0, _textView.textContainerInset.top/2) animated:NO];
    }else if(height != _originalHeight) {
        if(height > _originalHeight) {
            ++_lineNumber;
        }else {
            --_lineNumber;
        }
        
        _originalHeight = height;
        
        if (_lineNumber > self.maxLineNumber) {
            return;
        }
        
        float oldHeight = _textView.frame.size.height;
        float diff = (height - oldHeight) + 8;
        CGRect textFrame = _textView.frame;
        textFrame.size.height += diff;
  
        CGRect sendBtnFrame;
        if (self.showSendButton) {
            sendBtnFrame = _sendButton.frame;
            sendBtnFrame.origin.y += diff;
        }
        
        [self adjustAccesoryViewsFrameWithY:diff];
        
        CGRect frame = self.frame;
        frame.size.height += diff;
        frame.origin.y -= diff;
        _totalTranslationY -= diff;
        
        if (_lineNumber == 1) {
            textFrame.size.height = _singleLineHeight;
            frame.size.height = _singleLineInputHeight;
            frame.origin.y = self.superview.frame.size.height - _currentKeyboardHeight - frame.size.height;
            sendBtnFrame.origin.y = _singleSendButtonOriginY;
            _totalTranslationY = 0;
            
            [self resetAccesoryViewsFrame];
        }
        
        if (self.showSendButton) {
            _sendButton.frame = sendBtnFrame;
        }
        
        _textView.frame = textFrame;
        self.frame = frame;
        _totalInputViewHeight = frame.size.height;
        
        
        if(self.backgroundView) {
            CGRect backgroundFrame = self.backgroundView.frame;
            backgroundFrame.size.height = frame.size.height;
            self.backgroundView.frame = backgroundFrame;
        }
        
        float maxOffsetY = _textView.contentSize.height - _textView.frame.size.height;

        if(_lineNumber <= self.maxLineNumber) {
            [_textView setContentOffset:CGPointMake(0, maxOffsetY/2) animated:NO];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(JTInputViewDidChangeHeight:)]) {
            [self.delegate JTInputViewDidChangeHeight:self];
        }
    } 
    
    if(_textView.text.length == 0) {
        [_textView setContentOffset:CGPointMake(0, 2) animated:NO];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
      return  [self.delegate textViewShouldBeginEditing:textView];
    }else {
        return YES;
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return  [self.delegate textViewShouldEndEditing:textView];
    }else {
        return YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
       [self.delegate textViewDidBeginEditing:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
       [self.delegate textViewDidEndEditing:textView];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(JTInputViewDidEndEdit:)]) {
        [self.delegate JTInputViewDidEndEdit:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return  [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }else {
        if (self.enableWrapByReturn) {
            return YES;
        }else {
            if ([text isEqualToString:@"\n"]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(JTInputViewDidPressSendButton:)]) {
                    [self.delegate JTInputViewDidPressSendButton:self];
                }
                
                return NO;
            }else {
                return YES;
            }
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:textView];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [self.delegate textViewDidChangeSelection:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)]) {
        return  [self.delegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
    }else {
        return YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)]) {
        return  [self.delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    }else {
        return YES;
    }
}

@end
