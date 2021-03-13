#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TuyaSmartActivator+BleMesh.h"
#import "TuyaSmartBleMesh+SIGMesh.h"
#import "TuyaSmartSIGMeshDevice.h"
#import "TuyaSmartSIGMeshManager+Activator.h"
#import "TuyaSmartSIGMeshManager+Config.h"
#import "TuyaSmartSIGMeshManager+Group.h"
#import "TuyaSmartSIGMeshManager+OTA.h"
#import "TuyaSmartSIGMeshManager.h"
#import "TuyaSmartBleMesh.h"
#import "TuyaSmartBLEMeshDevice.h"
#import "TuyaSmartBleMeshGroup.h"
#import "TuyaSmartBLEMeshKit.h"
#import "TuyaSmartUser+BleMesh.h"
#import "TYBLEMeshCommand.h"
#import "TYBLEMeshCommandType.h"
#import "TYBleMeshDeviceModel.h"
#import "TYBLEMeshManager.h"
#import "TuyaSmartSIGMeshDiscoverDeviceInfo.h"

FOUNDATION_EXPORT double TuyaSmartBLEMeshKitVersionNumber;
FOUNDATION_EXPORT const unsigned char TuyaSmartBLEMeshKitVersionString[];

