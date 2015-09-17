//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "JTFixedTextView.h"

@interface JTFixedTextView () <UITextViewDelegate>
@property (nonatomic, weak) id<UITextViewDelegate> realDelegate;
@end

@implementation JTFixedTextView


#pragma mark - init & dealloc


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}


- (void)initialize
{
    _placeholderColor = [UIColor lightGrayColor];
    [self layoutGUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
}


- (void)dealloc
{
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification center


- (void)textChanged:(NSNotification *)notification
{
    if (notification.object == self)
        [self layoutGUI];
}


#pragma mark - layoutGUI


- (void)layoutGUI
{
    _placeholderLabel.alpha = [self.text length] > 0 || [_placeholderText length] == 0 ? 0 : 1;
}


#pragma mark - Setters


//- (void)setText:(NSString *)text
//{
//    [super setText:text];
//    [self layoutGUI];
//}


- (void)setPlaceholderText:(NSString*)placeholderText
{
	_placeholderText = placeholderText;
	[self setNeedsDisplay];
}


- (void)setPlaceholderColor:(UIColor*)color
{
	_placeholderColor = color;
	[self setNeedsDisplay];
}


#pragma mark - drawRect


- (void)drawRect:(CGRect)rect
{
    if ([_placeholderText length] > 0)
    {
        if (!_placeholderLabel)
        {
            _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.bounds.size.width - 16, self.font.lineHeight)];
            _placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            _placeholderLabel.numberOfLines = 0;
            _placeholderLabel.adjustsFontSizeToFitWidth = NO;
            _placeholderLabel.font = self.font;
            _placeholderLabel.backgroundColor = [UIColor clearColor];
            _placeholderLabel.alpha = 0;
            _placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_placeholderLabel];
        }
        
        _placeholderLabel.text = _placeholderText;
        _placeholderLabel.textColor = _placeholderColor;
        [_placeholderLabel setNeedsDisplay];
        [self sendSubviewToBack:_placeholderLabel];
    }
    
    [self layoutGUI];
    
    [super drawRect:rect];
}


#pragma mark -

/////////
- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        [self customInit];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self customInit];
}

- (void)customInit{
    if (YES) {
        [super setDelegate:self];
    }
}


- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    if (YES) {
        // UIScrollView delegate keeps some flags that mark whether the delegate implements some methods (like scrollViewDidScroll:)
        // setting *the same* delegate doesn't recheck the flags, so it's better to simply nil the previous delegate out
        // we have to setup the realDelegate at first, since the flag check happens in setter
        [super setDelegate:nil];
        self.realDelegate = delegate != self ? delegate : nil;
        [super setDelegate:delegate ? self : nil];
    }else {
        [super setDelegate:delegate];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextView

- (void)setText:(NSString *)text {
    _settingText = YES;
    [super setText:text];
    _settingText = NO;
    [self layoutGUI];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _settingText = YES;
    [super setAttributedText:attributedText];
    _settingText = NO;
}

- (void)setSelectedRange:(NSRange)selectedRange {
    _settingSelection = YES;
    [super setSelectedRange:selectedRange];
    _settingSelection = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Caret Scrolling

- (void)scrollRectToVisibleConsideringInsets:(CGRect)rect animated:(BOOL)animated {
    if (YES) {
        // Don't scroll if rect is currently visible.
        UIEdgeInsets insets = UIEdgeInsetsMake(self.contentInset.top + self.textContainerInset.top,
                                               self.contentInset.left + self.textContainerInset.left,
                                               self.contentInset.bottom + self.textContainerInset.bottom,
                                               self.contentInset.right + self.textContainerInset.right);
        CGRect visibleRect = UIEdgeInsetsInsetRect(self.bounds, insets);
        if (!CGRectContainsRect(visibleRect, rect)) {
            // Calculate new content offset.
            CGPoint contentOffset = self.contentOffset;
            if (CGRectGetMinY(rect) < CGRectGetMinY(visibleRect)) { // scroll up
                contentOffset.y = CGRectGetMinY(rect) - insets.top;
            }else { // scroll down
                contentOffset.y = CGRectGetMaxY(rect) + insets.bottom - CGRectGetHeight(self.bounds);
            }
            [self setContentOffset:contentOffset animated:animated];
        }
    }
    else {
        [self scrollRectToVisible:rect animated:animated];
    }
}

- (void)scrollRangeToVisibleConsideringInsets:(NSRange)range animated:(BOOL)animated {
    if (YES) {
        // Calculate text position and scroll, considering insets.
        UITextPosition *startPosition = [self positionFromPosition:self.beginningOfDocument offset:range.location];
        UITextPosition *endPosition = [self positionFromPosition:startPosition offset:range.length];
        UITextRange *textRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
        [self scrollRectToVisibleConsideringInsets:[self firstRectForRange:textRange] animated:animated];
    }
    else {
        [self scrollRangeToVisible:range];
    }
}

- (void)ensureCaretIsVisibleWithReplacementText:(NSString *)text {
    // No action is required on iOS 6, everything's working as intended there.
    if (YES) {
        // We need to give UITextView some time to fix it's calculation if this is a newline and we're at the end.
        if ([text isEqualToString:@"\n"] || [text isEqualToString:@""]) {
            // We schedule scrolling and don't animate, since UITextView doesn't animate these changes as well.
            [self scheduleScrollToVisibleCaretWithDelay:0.1f]; // Smaller delays are unreliable.
        }else {
            // Whenever the user enters text, see if we need to scroll to keep the caret on screen.
            // If it's not a newline, we don't need to add a delay to scroll.
            // We don't animate since this sometimes ends up on the wrong position then.
            [self scrollToVisibleCaret];
        }
    }
}

- (void)scheduleScrollToVisibleCaretWithDelay:(NSTimeInterval)delay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollToVisibleCaret) object:nil];
    [self performSelector:@selector(scrollToVisibleCaret) withObject:nil afterDelay:delay];
}

- (void)scrollToVisibleCaretAnimated:(BOOL)animated {
    const CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
    // The caret is sometimes off by a pixel. When this happens, scrolling to its rect produces a little bounce.
    // To avoid this, we scroll to its center instead.
    const CGRect caretCenterRect = CGRectMake(CGRectGetMidX(caretRect), CGRectGetMidY(caretRect), 0, 0);
    [self scrollRectToVisibleConsideringInsets:caretCenterRect animated:animated];
}

- (void)scrollToVisibleCaret {
    [self scrollToVisibleCaretAnimated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextViewDelegate

- (void)textViewDidChangeSelection:(UITextView *)textView {
    id<UITextViewDelegate> delegate = self.realDelegate;
    if ([delegate respondsToSelector:_cmd]) {
        [delegate textViewDidChangeSelection:textView];
    }
    
    if (!_settingText && !_settingSelection) {
        // Ensure caret stays visible when we change the caret position (e.g. via keyboard)
        [self scrollToVisibleCaretAnimated:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    id<UITextViewDelegate> delegate = self.realDelegate;
    if ([delegate respondsToSelector:_cmd]) {
        [delegate textViewDidChange:textView];
    }
    
    // Ensure we scroll to the caret position when changing text (e.g. pasting)
    [self scrollToVisibleCaretAnimated:NO];
    
    CGRect line = [self caretRectForPosition:self.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( self.contentOffset.y + self.bounds.size.height
       - self.contentInset.bottom - self.contentInset.top );
    if ( overflow > 0 ) {
        [self setContentOffset:CGPointMake(0, self.contentOffset.y + overflow + 2) animated:NO];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL returnVal = YES;
    id<UITextViewDelegate> delegate = self.realDelegate;
    if ([delegate respondsToSelector:_cmd]) {
        returnVal = [delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    // Ensure caret stays visible while we type.
    [self ensureCaretIsVisibleWithReplacementText:text];
    return returnVal;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegate Forwarder

- (BOOL)respondsToSelector:(SEL)s {
    return [super respondsToSelector:s] || [self.realDelegate respondsToSelector:s];
}

- (id)forwardingTargetForSelector:(SEL)s {
    id delegate = self.realDelegate;
    return [delegate respondsToSelector:s] ? delegate : [super forwardingTargetForSelector:s];
}

@end