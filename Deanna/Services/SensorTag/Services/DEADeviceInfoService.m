//
// Copyright 2013-2014 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
//


#import "DEADeviceInfoService.h"
#import "YMSCBCharacteristic.h"


@implementation DEADeviceInfoService

- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
               serviceOffset:(int)serviceOffset {
    
    self = [super initWithName:oName
                        parent:pObj
                        baseHi:hi
                        baseLo:lo
                 serviceOffset:serviceOffset];
    
    if (self) {
        [self addCharacteristic:@"system_id" withAddress:kSensorTag_DEVINFO_SYSTEM_ID];
        [self addCharacteristic:@"model_number" withAddress:kSensorTag_DEVINFO_MODEL_NUMBER];
        [self addCharacteristic:@"serial_number" withAddress:kSensorTag_DEVINFO_SERIAL_NUMBER];
        [self addCharacteristic:@"firmware_rev" withAddress:kSensorTag_DEVINFO_FIRMWARE_REV];
        [self addCharacteristic:@"hardware_rev" withAddress:kSensorTag_DEVINFO_HARDWARE_REV];
        [self addCharacteristic:@"software_rev" withAddress:kSensorTag_DEVINFO_SOFTWARE_REV];
        [self addCharacteristic:@"manufacturer_name" withAddress:kSensorTag_DEVINFO_MANUFACTURER_NAME];
        [self addCharacteristic:@"ieee11073_cert_data" withAddress:kSensorTag_DEVINFO_11073_CERT_DATA];
        // TODO: Undocumented what PnP characteristic address is. Stubbing here for now.
        //[self addCharacteristic:@"pnpid_data" withAddress:kSensorTag_DEVINFO_PNPID_DATA];
    }
    
    return self;
}




- (void)readDeviceInfo {
    
    YMSCBCharacteristic *system_idCt = self.characteristicDict[@"system_id"];
    __weak DEADeviceInfoService *this = self;
    [system_idCt readValueWithBlock:^(NSData *data, NSError *error) {
        NSMutableString *tmpString = [NSMutableString stringWithFormat:@""];
        unsigned char bytes[data.length];
        [data getBytes:bytes];
        for (int ii = (int)data.length; ii >= 0;ii--) {
            [tmpString appendFormat:@"%02hhx",bytes[ii]];
            if (ii) {
                [tmpString appendFormat:@":"];
            }
        }
        
        NSLog(@"system id: %@", tmpString);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.system_id = tmpString;
        });
        
    }];
    
    YMSCBCharacteristic *model_numberCt = self.characteristicDict[@"model_number"];
    [model_numberCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"model number: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.model_number = payload;
        });
    }];
    
    
    YMSCBCharacteristic *serial_numberCt = self.characteristicDict[@"serial_number"];
    [serial_numberCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"serial number: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.serial_number = payload;
        });
    }];
    
    
    YMSCBCharacteristic *firmware_revCt = self.characteristicDict[@"firmware_rev"];
    [firmware_revCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"firmware rev: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.firmware_rev = payload;
        });

    }];
    
    YMSCBCharacteristic *hardware_revCt = self.characteristicDict[@"hardware_rev"];
    [hardware_revCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"hardware rev: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.hardware_rev = payload;
        });

    }];

    YMSCBCharacteristic *software_revCt = self.characteristicDict[@"software_rev"];
    [software_revCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"software rev: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.software_rev = payload;
        });

    }];
    
    YMSCBCharacteristic *manufacturer_nameCt = self.characteristicDict[@"manufacturer_name"];
    [manufacturer_nameCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"manufacturer name: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.manufacturer_name = payload;
        });

    }];
    
    YMSCBCharacteristic *ieeeCt = self.characteristicDict[@"ieee11073_cert_data"];
    [ieeeCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"IEEE 11073 Cert Data: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.ieee11073_cert_data = payload;
        });

    }];
    
}

@end
