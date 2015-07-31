//
//  UIDevice+Custom.m
//  yingyongshangdian
//
//  Created by 张 成荣 on 13-6-20.
//  Copyright (c) 2013年 PubuTech. All rights reserved.
//

#import "UIDevice+Custom.h"
#import "MyHeader.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>
#import <mach/mach_host.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <mach/mach_host.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/sockio.h>
#include <errno.h>
#import "sys/utsname.h"

static NSString* gCurrentDeviceId = nil;
static NSString *md5MAC=nil;


#define kIODeviceTreePlane		"IODeviceTree"


@implementation UIDevice (Custom)

#define PRIVATE_PATH  "/System/Library/PrivateFrameworks/CoreTelephony.framework/CoreTelephony"

+ (NSString *)macAddress{
	
	int                 mib[6];
	size_t                len;
	char                *buf;
	unsigned char        *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl    *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error\n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1\n");
		return NULL;
	}
	
	if ((buf = (char*)malloc(len)) == NULL) {
		
		printf("Could not allocate memory. error!\n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		free(buf);
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	// NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	
	char dataBuffer[13];
	memset(dataBuffer, 0, 13);
	sprintf(dataBuffer, "%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));
	
	NSString *outstring = [NSString stringWithCString:dataBuffer encoding:NSUTF8StringEncoding];
	free(buf);
	return outstring;
}

+ (NSString*)deviceString
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	return deviceString;
}

+ (BOOL) isIPad{
	NSString *platform=[UIDevice currentDevice].model;
	if ([[platform lowercaseString] rangeOfString:@"ipad"].length>0) {
		return YES;
	}
	return NO;
}

+(BOOL)isIPod{
	NSString *platform=[UIDevice currentDevice].model;
	if ([[platform lowercaseString] rangeOfString:@"ipod"].length>0) {
		return YES;
	}
	return NO;
}

//设备的硬件版本 iphone4还是iphone6
+ (DeviceVerType)deviceVerType{
	if (WIDTH_SCREEN==375) {
		return DeviceVer6;
	}else if (WIDTH_SCREEN==414){
		return DeviceVer6P;
	}else if(HEIGHT_SCREEN==480){
		return DeviceVer4;
	}else if (HEIGHT_SCREEN==568){
		return DeviceVer5;
	}
	return DeviceVer4;
}

+ (CLLocationCoordinate2D) getPostion
{
    CLLocationManager *locManager = [[CLLocationManager alloc] init];
    locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locManager startUpdatingLocation];
    locManager.distanceFilter = 1000.0f;
    return locManager.location.coordinate;
}

@end
