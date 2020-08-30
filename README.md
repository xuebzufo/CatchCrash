# CatchCrash
IOS系统闪退异常(Crash)捕获处理
我们的程序经常出现异常造成闪退的现象，对于已经发布的APP，如何捕捉到这些异常，及时进行更新解决闪退，提高体验感呢？
对于一些简单，比如一些后台数据的处理，容易重现数组越界,字典空指针错误的，我们用oc的runtime方法进行捕获。比如NSArray的数组越界问题。
```
//
//  ViewController.m
//  CatchCrash
//
//  Created by Sem on 2020/8/28.
//  Copyright © 2020 SEM. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSArray *dd =@[@"1",@"2"];
       NSString *z =dd[3];
       NSLog(@"~~~~~%@",z);
}
@end

```
我们可以通过runtime进行方法替换，比如我们捕获NSArray的数组越界问题,注意NSArray 是个类簇所以不能简单添加类目,我们
```
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
```
当然这种捕获只能捕获单一的问题，还有其他的报错，那就要写很多的分类处理,如何进行统一的捕捉呢，我们查看下报错信息看下能不找到有用的信息。
![image.png](https://upload-images.jianshu.io/upload_images/13002035-3780085994f2cc4f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
如图我们看了报错的方法栈。看到有libobjc的调用。这个就很熟悉了，去看下runtime的源码。可以找到set_terminate设置中止的回调，也就是如果出现报错，系统会通过会回调这个函数，如果外界没有传这个函数objc_setUncaightExceptionHandler，系统会使用默认的实现。 我们只要调用NSSetUncaughtExceptionHandler就可以设置这个方法，系统出现报错时候，回调这个方法，我们处理这个错误.
在AppDelegate里面设置这个方法句柄
```
NSSetUncaughtExceptionHandler(&HandleException);
```
然后就可以捕捉异常 ，上传服务或者保存在本地。
```
void HandleException(NSException *exception)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	//获取方法调用栈
	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	NSMutableDictionary *userInfo =
		[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[[[UncaughtExceptionHandler alloc] init] autorelease]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:[exception name]
				reason:[exception reason]
				userInfo:userInfo]
		waitUntilDone:YES];
}

```
