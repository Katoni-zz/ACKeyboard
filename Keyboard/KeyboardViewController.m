//
//  KeyboardViewController.m
//  Keyboard
//
//  Created by Arnaud Coomans on 8/16/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "KeyboardViewController.h"
#import "Key.h"
#import "LockKey.h"

static NSTimeInterval kDeleteTimerInterval = 0.1;


@interface KeyboardViewController ()

@property (nonatomic, strong) NSMutableArray *constraints;

@property (nonatomic, strong) Key *nextKeyboardButton;
@property (nonatomic, strong) Key *spaceButton;
@property (nonatomic, strong) Key *returnButton;
@property (nonatomic, strong) Key *yoButton;
@property (nonatomic, strong) Key *deleteButton;
@property (nonatomic, strong) LockKey *leftShiftButton;
@property (nonatomic, strong) LockKey *rightShiftButton;

@property (nonatomic, strong) NSRegularExpression *endOfSentenceRegularExpression;
@property (nonatomic, strong) NSRegularExpression *beginningOfSentenceRegularExpression;
@property (nonatomic, strong) NSRegularExpression *beginningOfWordRegularExpression;

@property (nonatomic, strong) NSTimer *deleteTimer;
@end


@implementation KeyboardViewController

#pragma mark - View

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateFont];
    
    // animating somehow reduces some jerkiness
    [UIView animateWithDuration:0.0 delay:0.0 options:0 animations:^{
        [self layoutViewForSize:self.view.frame.size];
    } completion:^(BOOL finished) {}];
}

- (void)layoutViewForSize:(CGSize)size {
    
    CGFloat x, y, width, height, edgeMargin, bottomMargin, columnMargin, rowMargin, letterKeyWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        // p 768 * x + y = 6
        // l 1024 * x + y = 7
        edgeMargin = size.width * 1.0/256.0 + 3.0;
        
        // p 264 * x + y = 7
        // l 352 * x + y = 9
        bottomMargin = size.height * 1.0/44.0 + 1.0;
        
        // p 768 * x + y = 12
        // l 1024 * x + y = 14
        columnMargin = size.width * 1.0/128.0 + 6.0;
        
        // p 264 * x + y = 8
        // l 352 * x + y = 11
        rowMargin = size.height * 3.0/88.0 - 1.0;
        
        // p 264 * x + y = 56
        // l 352 * x + y = 75
        height = size.height * 19.0/88.0 - 1.0;
        
        // p 768 * x + y = 57
        // l 1024 * x + y = 78
        letterKeyWidth = size.width * 21.0/256.0 - 6.0;
        
        // p 768 * x + y = 56
        // l 1024 * x + y = 144
        width = size.width * 5.0/64.0 - 4.0;
        x = edgeMargin;
        y = size.height - bottomMargin - height;
        self.nextKeyboardButton.frame = CGRectMake(x, y, width, height);
        
        // p 768 * x + y = 106
        // l 1024 * x + y = 144
        width = size.width *  19.0/128.0 - 8.0;
        x = size.width - edgeMargin - width;
        y = size.height - bottomMargin - 2 * rowMargin - 3 * height;
        self.returnButton.frame = CGRectMake(x, y, width, height);
        
        width = size.width - 2 * edgeMargin - columnMargin - self.nextKeyboardButton.frame.size.width;
        x = self.nextKeyboardButton.frame.origin.x + self.nextKeyboardButton.frame.size.width + columnMargin;
        y = size.height - bottomMargin - height;
        self.spaceButton.frame = CGRectMake(x, y, width, height);
        
        // p 768 * x + y = 56
        // l 1024 * x + y = 77
        width = size.width * 21.0/256.0 - 7.0;
        x = edgeMargin;
        y = size.height - bottomMargin - rowMargin - 2 * height;
        self.leftShiftButton.frame = CGRectMake(x, y, width, height);
        
        // p 768 * x + y = 76
        // l 1024 * x + y = 105
        width = size.width * 29.0/256.0 - 11.0;
        x = size.width - edgeMargin - width;
        y = size.height - bottomMargin - rowMargin - 2 * height;
        self.rightShiftButton.frame = CGRectMake(x, y, width, height);
        
        width = letterKeyWidth;
        x = (size.width - width)/2;
        y = size.height - bottomMargin - 2 * rowMargin - 3 * height;
        self.yoButton.frame = CGRectMake(x, y, width, height);
        
        // p 264 * x + y = 2
        // l 352 * x + y = 0
        CGFloat lastRowExtraMargin = size.height * -1.0/44.0 + 8.0;
        
        
        // p 264 * x + y = 58
        // l 352 * x + y = 75
        CGFloat lastRowHeight = size.height * 17.0/88.0 + 7.0;
        
        // p 768 * x + y = 61
        // l 1024 * x + y = 80
        width = size.width * 19.0/256.0 + 4.0;
        x = size.width - edgeMargin - width;
        y = size.height - bottomMargin - 3 * rowMargin - 4 * height - lastRowExtraMargin;
        self.deleteButton.frame = CGRectMake(x, y, width, lastRowHeight);
    
    } else { //UIUserInterfaceIdiomPhone
        
        edgeMargin = 3.0;
        bottomMargin = 3.0;
        
        // p 320 * x + y = 6
        // l 568 * x + y = 7
        columnMargin = size.width * 1.0/248.0 + 146.0/31.0;
        
        // p 216 * x + y = 15
        // l 162 * x + y = 7
        rowMargin = size.height * 4.0/27.0 - 17.0;
        
        // p 216 * x + y = 39
        // l 162 * x + y = 33
        height = size.height * 1.0/9.0 + 15.0;
        
        // p 320 * x + y = 26
        // l 568 * x + y = 52
        letterKeyWidth = size.width * 13.0/124.0 - 234.0/31.0;
        
        // p 320 * x + y = 34
        // l 568 * x + y = 50
        width = size.width * 2.0/31.0 + 414.0/31.0;
        x = edgeMargin;
        y = size.height - bottomMargin - height;
        self.nextKeyboardButton.frame = CGRectMake(x, y, width, height);
        
        // p 320 * x + y = 74
        // l 568 * x + y = 107
        width = size.width * 33.0/248.0 + 974.0/31.0;
        x = size.width - edgeMargin - width;
        y = size.height - bottomMargin - height;
        self.returnButton.frame = CGRectMake(x, y, width, height);
        
        width = size.width - 2 * edgeMargin - 2 * columnMargin - self.nextKeyboardButton.frame.size.width - self.returnButton.frame.size.width;
        x = self.nextKeyboardButton.frame.origin.x + self.nextKeyboardButton.frame.size.width + columnMargin;
        y = size.height - bottomMargin - height;
        self.spaceButton.frame = CGRectMake(x, y, width, height);
        
        // p 320 * x + y = 36
        // l 568 * x + y = 69
        width = size.width * 33.0/248.0 - 204.0/31.0;
        x = size.width - edgeMargin - width;
        y = size.height - bottomMargin - rowMargin - 2 * height;
        self.deleteButton.frame = CGRectMake(x, y, width, height);
        
        // p 320 * x + y = 36
        // l 568 * x + y = 68
        width = size.width * 4.0/31.0 - 164.0/31.0;
        x = edgeMargin;
        y = size.height - bottomMargin - rowMargin - 2 * height;
        self.leftShiftButton.frame = CGRectMake(x, y, width, height);
        
        width = letterKeyWidth;
        x = (size.width - width)/2;
        y = size.height - bottomMargin - 2 * rowMargin - 3 * height;
        self.yoButton.frame = CGRectMake(x, y, width, height);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Keys

- (Key*)nextKeyboardButton {
    if (!_nextKeyboardButton) {
        _nextKeyboardButton = [Key keyWithStyle:KeyStyleDark image:[UIImage imageNamed:@"global_portrait"]];
        [_nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nextKeyboardButton];
    }
    return _nextKeyboardButton;
}

- (Key*)returnButton {
    if (!_returnButton) {
        _returnButton = [Key keyWithStyle:KeyStyleDark title:@"return"];
        [_returnButton addTarget:self action:@selector(returnButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_returnButton];
    }
    return _returnButton;
}

- (Key*)spaceButton {
    if (!_spaceButton) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _spaceButton = [Key keyWithStyle:KeyStyleLight];
        } else {
            _spaceButton = [Key keyWithStyle:KeyStyleLight title:@"space"];
        }
        [_spaceButton addTarget:self action:@selector(spaceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_spaceButton];
    }
    return _spaceButton;
}

- (Key*)yoButton {
    if (!_yoButton) {
        _yoButton = [Key keyWithStyle:KeyStyleLight title:@"YO"];
        [_yoButton addTarget:self action:@selector(yoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_yoButton];
    }
    return _yoButton;
}

- (Key*)deleteButton {
    if (!_deleteButton) {
        UIImage *image = [[UIImage imageNamed:@"delete_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _deleteButton = [Key keyWithStyle:KeyStyleDark image:image];
        [_deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [_deleteButton addTarget:self action:@selector(deleteButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteButton addTarget:self action:@selector(deleteButtonReleased:) forControlEvents:UIControlEventTouchUpOutside];
        [self.view addSubview:_deleteButton];
    }
    return _deleteButton;
}

- (LockKey*)leftShiftButton {
    if (!_leftShiftButton) {
        _leftShiftButton = [LockKey keyWithStyle:KeyStyleDark];
        _leftShiftButton.image = [[UIImage imageNamed:@"shift_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _leftShiftButton.lockImage = [[UIImage imageNamed:@"shift_lock_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_leftShiftButton addTarget:self action:@selector(shiftButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [_leftShiftButton addTarget:self action:@selector(shiftButtonDoubleTapped:) forControlEvents:UIControlEventTouchDownRepeat];
        [self.view addSubview:_leftShiftButton];
    }
    return _leftShiftButton;
}

- (LockKey*)rightShiftButton {
    if (!_rightShiftButton) {
        _rightShiftButton = [LockKey keyWithStyle:KeyStyleDark];
        _rightShiftButton.image = [[UIImage imageNamed:@"shift_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _rightShiftButton.lockImage = [[UIImage imageNamed:@"shift_lock_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_rightShiftButton addTarget:self action:@selector(shiftButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [_rightShiftButton addTarget:self action:@selector(shiftButtonDoubleTapped:) forControlEvents:UIControlEventTouchDownRepeat];
        [self.view addSubview:_rightShiftButton];
    }
    return _rightShiftButton;
}


#pragma mark - Regular expressions

- (NSRegularExpression*)endOfSentenceRegularExpression {
    if (!_endOfSentenceRegularExpression) {
        NSError* error = nil;
        _endOfSentenceRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[a-z0-9] \\z"
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:&error];
        
        if (!_endOfSentenceRegularExpression) {
            NSLog(@"cannot create regular expression: %@", [error description]);
        }
    }
    return _endOfSentenceRegularExpression;
}

- (NSRegularExpression*)beginningOfSentenceRegularExpression {
    if (!_beginningOfSentenceRegularExpression) {
        NSError* error = nil;
        _beginningOfSentenceRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"!\\s+\\z"
                                                                                          options:0
                                                                                            error:&error];
        
        if (!_beginningOfSentenceRegularExpression) {
            NSLog(@"cannot create regular expression: %@", [error description]);
        }
    }
    return _beginningOfSentenceRegularExpression;
}

- (NSRegularExpression*)beginningOfWordRegularExpression {
    if (!_beginningOfWordRegularExpression) {
        NSError* error = nil;
        _beginningOfWordRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\s+\\z"
                                                                                      options:NSRegularExpressionCaseInsensitive
                                                                                        error:&error];
        
        if (!_beginningOfWordRegularExpression) {
            NSLog(@"cannot create regular expression: %@", [error description]);
        }
    }
    return _beginningOfWordRegularExpression;
}


#pragma mark - UITextInputDelegate

- (void)textWillChange:(id<UITextInput>)textInput {
    
}

- (void)textDidChange:(id<UITextInput>)textInput {
    
    [self updateReturnButtonStyle];
    [self updateReturnButtonEnabled];
    [self updateShiftButtonState];
    [self updateFont];
    
    //    UIColor *textColor = nil;
    //    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
    //        textColor = [UIColor whiteColor];
    //    } else {
    //        textColor = [UIColor blackColor];
    //    }
    //    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)selectionWillChange:(id<UITextInput>)textInput {
    
}

- (void)selectionDidChange:(id<UITextInput>)textInput {
    
}


#pragma mark - Keys state

- (void)updateReturnButtonStyle {
    
    switch (self.textDocumentProxy.returnKeyType) {
        case UIReturnKeyDefault:
        case UIReturnKeyDone:
            self.returnButton.title = @"return";
            break;
        case UIReturnKeyEmergencyCall:
            self.returnButton.title = @"Emergency Call";
            break;
        case UIReturnKeyGo:
            self.returnButton.title = @"Go";
            break;
        case UIReturnKeySearch:
        case UIReturnKeyGoogle:
        case UIReturnKeyYahoo:
            self.returnButton.title = @"Search";
            break;
        case UIReturnKeyJoin:
            self.returnButton.title = @"Join";
            break;
        case UIReturnKeyNext:
            self.returnButton.title = @"Next";
            break;
        case UIReturnKeyRoute:
            self.returnButton.title = @"Route";
            break;
        case UIReturnKeySend:
            self.returnButton.title = @"Send";
            break;
        default:;
    }
    
    switch (self.textDocumentProxy.returnKeyType) {
        case UIReturnKeyDefault:
        case UIReturnKeyNext:
            self.returnButton.keyStyle = KeyStyleDark;
            break;
        default:
            self.returnButton.keyStyle = KeyStyleBlue;
            break;
    }
}

- (void)updateReturnButtonEnabled {
    if (self.textDocumentProxy.enablesReturnKeyAutomatically &&
        self.textDocumentProxy.documentContextBeforeInput.length == 0 &&
        self.textDocumentProxy.documentContextAfterInput.length == 0) {
        
        self.returnButton.enabled = NO;
    } else {
        self.returnButton.enabled = YES;
    }
}

- (void)updateShiftButtonState {
    if (self.leftShiftButton.isLocked) {
        return;
    }
    
    BOOL selected = NO;
    
    NSString *beforeInput = self.textDocumentProxy.documentContextBeforeInput;
    
    switch (self.textDocumentProxy.autocapitalizationType) {
            
        case UITextAutocapitalizationTypeAllCharacters: {
            selected = YES;
            break;
        }
            
        case UITextAutocapitalizationTypeSentences: {
            if (beforeInput.length == 0 ||
                [[self.beginningOfSentenceRegularExpression matchesInString:beforeInput
                                                                    options:0
                                                                      range:NSMakeRange(0, beforeInput.length)] count]) {
                selected = YES;
            }
            break;
        }
            
        case UITextAutocapitalizationTypeWords: {
            if (beforeInput.length == 0 ||
                [[self.beginningOfWordRegularExpression matchesInString:beforeInput
                                                                options:0
                                                                  range:NSMakeRange(0, beforeInput.length)] count]) {
                selected = YES;
            }
            break;
        }
            
        case UITextAutocapitalizationTypeNone:
        default:
            break;
    }
    
    self.leftShiftButton.selected = _rightShiftButton.selected = selected;
}

- (void)updateFont {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        for (Key *key in @[self.returnButton, self.yoButton]) {
            if ([key isKindOfClass:[Key class]]) {
                if (self.view.frame.size.width >= 1024) {
                    key.titleFont = [UIFont systemFontOfSize:kKeyPadLandscapeTitleFontSize];
                } else {
                    key.titleFont = [UIFont systemFontOfSize:kKeyPadPortraitTitleFontSize];
                }
            }
        }
    }
}

#pragma mark - Text actions

- (void)deleteBackward {
    
    NSString *beforeInput = self.textDocumentProxy.documentContextBeforeInput;
    
    if (beforeInput.length > 1) {
        NSString *coupleOfLastCharacters = [beforeInput substringWithRange:NSMakeRange(beforeInput.length-2, 2)];
        if( [@"yo" caseInsensitiveCompare:coupleOfLastCharacters] == NSOrderedSame ) {
            [self.textDocumentProxy deleteBackward];
        }
    }
    [self.textDocumentProxy deleteBackward];
    [self updateReturnButtonEnabled];
    [self updateShiftButtonState];
}

- (void)insertText:(NSString*)text {
    [self.textDocumentProxy insertText:text];
    [self updateReturnButtonEnabled];
    [self updateShiftButtonState];
}


#pragma mark - Keys actions

- (IBAction)returnButtonTapped:(id)sender {
    [self insertText:@"\n"];
}

- (IBAction)spaceButtonTapped:(id)sender {
    
    NSString *beforeInput = self.textDocumentProxy.documentContextBeforeInput;
    if (beforeInput.length &&
        ([[self.endOfSentenceRegularExpression matchesInString:beforeInput
                                                     options:0
                                                       range:NSMakeRange(0, beforeInput.length)] count] > 0)
        ) {
        [self.textDocumentProxy deleteBackward];
        [self insertText:@"! "];
    } else {
        [self insertText:@" "];
    }
}

- (IBAction)yoButtonTapped:(id)sender {
    if (self.leftShiftButton.isLocked || self.leftShiftButton.selected) {
        [self insertText:@"YO"];
    } else {
        [self insertText:@"yo"];
    }
}

- (IBAction)deleteButtonTapped:(id)sender {
    [self deleteBackward];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kDeleteTimerInterval
                                                      target:self
                                                    selector:@selector(deleteTimerFireMethod:)
                                                    userInfo:nil
                                                     repeats:YES];
    self.deleteTimer = timer;
    
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        if (timer == self.deleteTimer) {
            [weakSelf.deleteTimer fire];
        }
    });
}

- (void)deleteTimerFireMethod:(NSTimer *)timer {
    if (self.deleteButton.highlighted) {
        [self deleteBackward];
    } else {
        [timer invalidate];
        self.deleteTimer = nil;
    }
}

- (IBAction)deleteButtonReleased:(id)sender {
    [self.deleteTimer invalidate];
    self.deleteTimer = nil;
}

- (void)shiftButtonTapped:(id)sender {
    if (self.leftShiftButton.isLocked) {
        self.leftShiftButton.selected = _rightShiftButton.selected = NO;
        self.leftShiftButton.locked = _rightShiftButton.locked = NO;
    } else {
        self.leftShiftButton.selected = _rightShiftButton.selected = ! self.leftShiftButton.selected;
    }
}

- (void)shiftButtonDoubleTapped:(id)sender {
    self.leftShiftButton.selected = _rightShiftButton.selected = YES;
    self.leftShiftButton.locked = _rightShiftButton.locked = ! self.leftShiftButton.isLocked;
}

@end
