//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//

@import UIKit;

@interface JTFixedTextView : UITextView
{
    UILabel *_placeholderLabel;
    BOOL _settingText;
    BOOL _settingSelection;
}


@property (strong, nonatomic) NSString *placeholderText;
@property (strong, nonatomic) UIColor *placeholderColor;


@end