//
//  uliblicense.h
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
#import <ulibasn1/ulibasn1.h>
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

UMLicenseDirectory * UMLicense_loadLicensesFromPath(NSString *directory, BOOL debug);
UMLicenseDirectory * UMLicense_newLicenseDirectoryWithDefaultKeys(void);
BOOL    RunningInDocker(void);
