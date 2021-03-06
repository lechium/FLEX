//
//  FLEXFieldEditorViewController.m
//  FLEX
//
//  Created by Tanner on 11/22/18.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXFieldEditorViewController.h"
#import "FLEXFieldEditorView.h"
#import "FLEXArgumentInputViewFactory.h"
#import "FLEXPropertyAttributes.h"
#import "FLEXRuntimeUtility.h"
#import "FLEXUtility.h"
#import "FLEXColor.h"
#import "UIBarButtonItem+FLEX.h"
#import <TargetConditionals.h>
#import "FLEXArgumentInputDateView.h"

@interface FLEXFieldEditorViewController () <FLEXArgumentInputViewDelegate>

@property (nonatomic) FLEXProperty *property;
@property (nonatomic) FLEXIvar *ivar;

@property (nonatomic, readonly) id currentValue;
@property (nonatomic, readonly) const FLEXTypeEncoding *typeEncoding;
@property (nonatomic, readonly) NSString *fieldDescription;

@end

@implementation FLEXFieldEditorViewController

#pragma mark - Initialization

+ (instancetype)target:(id)target property:(nonnull FLEXProperty *)property commitHandler:(void(^_Nullable)())onCommit {
    id value = [property getValue:target];
    if (![self canEditProperty:property onObject:target currentValue:value]) {
        return nil;
    }

    FLEXFieldEditorViewController *editor = [self target:target data:property commitHandler:onCommit];
    editor.title = [@"Property: " stringByAppendingString:property.name];
    editor.property = property;
    return editor;
}

+ (instancetype)target:(id)target ivar:(nonnull FLEXIvar *)ivar commitHandler:(void(^_Nullable)())onCommit {
    FLEXFieldEditorViewController *editor = [self target:target data:ivar commitHandler:onCommit];
    editor.title = [@"Ivar: " stringByAppendingString:ivar.name];
    editor.ivar = ivar;
    return editor;
}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = FLEXColor.groupedBackgroundColor;
#if !TARGET_OS_TV
    // Create getter button
    _getterButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Get"
        style:UIBarButtonItemStyleDone
        target:self
        action:@selector(getterButtonPressed:)
    ];

    self.toolbarItems = @[
        UIBarButtonItem.flex_flexibleSpace, self.getterButton, self.actionButton
    ];
    
#else
    _getterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_getterButton setTitle:@"Get" forState:UIControlStateNormal];
    [_getterButton addTarget:self action:@selector(getterButtonPressed:) forControlEvents:UIControlEventPrimaryActionTriggered];
    _getterButton.frame = CGRectMake(100, 600, 200, 70);
    [self.view addSubview:_getterButton];
    UIFocusGuide *focusGuide = [[UIFocusGuide alloc] init];
    [self.view addLayoutGuide:focusGuide];
    [focusGuide.topAnchor constraintEqualToAnchor:self.actionButton.topAnchor].active = true;
    [focusGuide.bottomAnchor constraintEqualToAnchor:self.getterButton.bottomAnchor].active = true;
    focusGuide.preferredFocusEnvironments = self.preferredFocusEnvironments;
#endif

    // Configure input view
    self.fieldEditorView.fieldDescription = self.fieldDescription;
    FLEXArgumentInputView *inputView = [FLEXArgumentInputViewFactory argumentInputViewForTypeEncoding:self.typeEncoding];
    inputView.inputValue = self.currentValue;
    inputView.delegate = self;
    self.fieldEditorView.argumentInputViews = @[inputView];
    // Don't show a "set" button for switches; we mutate when the switch is flipped
    if ([inputView isKindOfClass:[FLEXArgumentInputSwitchView class]]) {
        self.actionButton.enabled = NO;
#if !TARGET_OS_TV
        self.actionButton.title = @"Flip the switch to call the setter";
        // Put getter button before setter button
        self.toolbarItems = @[
            UIBarButtonItem.flex_flexibleSpace, self.actionButton, self.getterButton
        ];
#endif
    }
}

- (NSArray *)preferredFocusEnvironments {
    if ([self actionButton] && _getterButton){
        return @[[self actionButton],_getterButton];
    } else {
        if ([self actionButton]){
            return @[[self actionButton]];
        } else if (_getterButton){
            return @[_getterButton];
        }
    }
    return nil;
}

- (void)actionButtonPressed:(id)sender {
    if (self.property) {
        id userInputObject = self.firstInputView.inputValue;
        NSArray *arguments = userInputObject ? @[userInputObject] : nil;
        SEL setterSelector = self.property.likelySetter;
        NSError *error = nil;
        [FLEXRuntimeUtility performSelector:setterSelector onObject:self.target withArguments:arguments error:&error];
        if (error) {
            [FLEXAlert showAlert:@"Property Setter Failed" message:error.localizedDescription from:self];
            sender = nil; // Don't pop back
        }
    } else {
        // TODO: check mutability and use mutableCopy if necessary;
        // this currently could and would assign NSArray to NSMutableArray
        [self.ivar setValue:self.firstInputView.inputValue onObject:self.target];
    }
    
    // Dismiss keyboard and handle committed changes
    [super actionButtonPressed:sender];

    // Go back after setting, but not for switches.
    if (sender) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.firstInputView.inputValue = self.currentValue;
    }
}

- (void)getterButtonPressed:(id)sender {
    [self.fieldEditorView endEditing:YES];

    [self exploreObjectOrPopViewController:self.currentValue];
}

- (void)argumentInputViewValueDidChange:(FLEXArgumentInputView *)argumentInputView {
    if ([argumentInputView isKindOfClass:[FLEXArgumentInputSwitchView class]]) {
        [self actionButtonPressed:nil];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
#if TARGET_OS_TV
    
    FLEXArgumentInputView *inputView = [FLEXArgumentInputViewFactory argumentInputViewForTypeEncoding:self.typeEncoding];
    if ([inputView isKindOfClass:[FLEXArgumentInputDateView class]]){
        [self actionButton].frame = CGRectMake(100, 350, 200, 60);
        [self getterButton].frame = CGRectMake(100, 550, 200, 60);
        return;
    }
    
    CGRect getterFrame = _getterButton.frame;
    CGFloat actionOffset = [[self actionButton] frame].origin.y;
    //CGRect fieldEditorFrame = self.fieldEditorView.frame;
    //CGFloat buttonOffset = (fieldEditorFrame.origin.y + fieldEditorFrame.size.height) + (130 + 67);
    getterFrame.origin.y = actionOffset;
    _getterButton.frame = getterFrame;
    
#endif
}

#pragma mark - Private

- (id)currentValue {
    if (self.property) {
        return [self.property getValue:self.target];
    } else {
        return [self.ivar getValue:self.target];
    }
}

- (const FLEXTypeEncoding *)typeEncoding {
    if (self.property) {
        return self.property.attributes.typeEncoding.UTF8String;
    } else {
        return self.ivar.typeEncoding.UTF8String;
    }
}

- (NSString *)fieldDescription {
    if (self.property) {
        return self.property.fullDescription;
    } else {
        return self.ivar.description;
    }
}

+ (BOOL)canEditProperty:(FLEXProperty *)property onObject:(id)object currentValue:(id)value {
    const FLEXTypeEncoding *typeEncoding = property.attributes.typeEncoding.UTF8String;
    BOOL canEditType = [FLEXArgumentInputViewFactory canEditFieldWithTypeEncoding:typeEncoding currentValue:value];
    return canEditType && [object respondsToSelector:property.likelySetter];
}

+ (BOOL)canEditIvar:(Ivar)ivar currentValue:(id)value {
    return [FLEXArgumentInputViewFactory canEditFieldWithTypeEncoding:ivar_getTypeEncoding(ivar) currentValue:value];
}

@end
