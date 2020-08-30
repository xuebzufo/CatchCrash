//
//  NSArray+CatchArray.m
//  CatchCrash
//
//  Created by Sem on 2020/8/28.
//  Copyright © 2020 SEM. All rights reserved.
//

#import "NSArray+CatchArray.h"
#import <objc/runtime.h>

@implementation NSArray (CatchArray)
+(void)load{
//    [self SQ_HookOriInstanceMethod:@selector(objectAtIndexedSubscript:) NewInstanceMethod:@selector(objectAtIndexedSubscriptNew:)];
    
}
+(BOOL)SQ_HookOriInstanceMethod:(SEL)oriSel NewInstanceMethod:(SEL)newSel{
    Class class = objc_getRequiredClass("__NSArrayI");
    Method origMethod = class_getInstanceMethod(class, oriSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if(!origMethod||!newMethod){
        return NO;
    }
    method_exchangeImplementations(origMethod, newMethod);
    return YES;
    
}
-(id)objectAtIndexedSubscriptNew:(NSUInteger)index{
    if(index>=self.count){
        //代码处理 上传服务器.
        return nil;
    }
    return [self objectAtIndexedSubscriptNew:index] ;
}
@end
