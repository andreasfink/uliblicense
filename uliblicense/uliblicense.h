//
//  uliblicense.h
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
#import <uliblicense/UMSignedLicense.h>
#import <uliblicense/UMLegacyLicense.h>
#import <uliblicense/UMEncryptedLicense.h>
#import <uliblicense/UMLicense.h>
#import <uliblicense/UMLicenseRestriction.h>
#import <uliblicense/UMLicenseProductFeature.h>
#import <uliblicense/UMLicenseProductFeatureList.h>
#import <uliblicense/UMLicenseRestrictionList.h>
#import <uliblicense/UMLicenseProduct.h>
#import <uliblicense/UMLicenseProductList.h>
#import <uliblicense/UMLicenseDirectory.h>
#import <uliblicense/UMLicenseFile.h>
#import <uliblicense/UMLicenseWebConvert.h>
#import <uliblicense/UMLicenseServer.h>
#import <uliblicense/UMLicenseSession.h>
#import <uliblicense/UMLicenseServerCommand.h>
#import <uliblicense/UMLicenseServerCommandError.h>
#import <uliblicense/UMLicenseServerCommandGetLicenseRequest.h>
#import <uliblicense/UMLicenseServerCommandGetLicenseResponse.h>
#import <uliblicense/UMLicenseServerCommandHeartBeatRequest.h>
#import <uliblicense/UMLicenseServerCommandHeartBeatResponse.h>
#import <uliblicense/UMLicenseServerCommandGenericError.h>
#import <uliblicense/UMLicenseSessionCompletionObject.h>


UMLicenseDirectory * UMLicense_loadLicensesFromPath(NSString *directory, BOOL debug);
UMLicenseDirectory * UMLicense_newLicenseDirectoryWithDefaultKeys(void);
BOOL    RunningInDocker(void);
