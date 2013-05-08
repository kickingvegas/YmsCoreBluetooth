# YmsCoreBluetooth 0.91 (beta)
A framework for building Bluetooth 4.0 Low Energy (aka Smart or LE) iOS applications using the CoreBluetooth API. Includes Deanna, an iOS application using YmsCoreBluetooth to communicate with a [TI SensorTag](http://processors.wiki.ti.com/index.php/Bluetooth_SensorTag).

[YmsCoreBluetooth API Reference](http://kickingvegas.github.io/YmsCoreBluetooth/appledoc/index.html)

## File Naming Conventions

The YmsCoreBluetooth framework is the set of files prefixed with `YMSCB` located in the directory `YmsCoreBluetooth`.

The files for the iOS application **Deanna** are prefixed with `DEA` located in the directory `Deanna`.

## Organizational Structure & Operation

The organizational structure of the YmsCoreBluetooth framework largely mirrors the CoreBluetooth hierarchy:

* YMSCBAppService - An application service which manages multiple BLE peripherals
    * YMSCBPeripheral - A BLE peripheral can have multiple BLE services
        * YMSCBService - A BLE service can have multiple BLE characteristics
             * YMSCBCharacteristic 
	     
	     
With CoreBluetooth, the API to issue read and write requests to a BLE peripheral is accomplished through the CBPeripheral class and the responses sent back are handled via CBPeripheralDelegate methods. For a BLE peripheral with multiple services, this approach requires the developer to write code to manage read/write requests to different services.
        
YmsCoreBluetooth framework offers iOS developers a more natural API that is BLE service-centric: **read and write requests to a BLE peripheral are done from the point of view of a BLE service**. Responses can be handled using a callback block or via a notification handler method.

## YmsCoreBluetooth by Example: DEATemperatureService, a subclass of YMSCBService

To demonstrate the BLE service-centric API in action, below is the implementation of the temperature service for a TI SensorTag. 

	@implementation DEATemperatureService
	- (id)initWithName:(NSString *)oName
				baseHi:(int64_t)hi
				baseLo:(int64_t)lo {
		self = [super initWithName:oName
							baseHi:hi
							baseLo:lo];
		if (self) {
			[self addCharacteristic:@"service" withOffset:kSensorTag_TEMPERATURE_SERVICE];
			[self addCharacteristic:@"data" withOffset:kSensorTag_TEMPERATURE_DATA];
			[self addCharacteristic:@"config" withOffset:kSensorTag_TEMPERATURE_CONFIG];
		}
		return self;
	}
	- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error {
		if (error) {
			return;
		}
		if ([yc.name isEqualToString:@"data"]) {
			NSData *data = yc.cbCharacteristic.value;
			char val[data.length];
			[data getBytes:&val length:data.length];
			int16_t v0 = val[0];
			int16_t v1 = val[1];
			int16_t v2 = val[2];
			int16_t v3 = val[3];
			int16_t amb = ((v2 & 0xff)| ((v3 << 8) & 0xff00));
			int16_t objT = ((v0 & 0xff)| ((v1 << 8) & 0xff00));
			double tempAmb = calcTmpLocal(amb);
			self.ambientTemp = [NSNumber numberWithDouble:tempAmb];
			self.objectTemp = [NSNumber numberWithDouble:calcTmpTarget(objT, tempAmb)];
		}
	}

	- (void)turnOn {
		[self writeByte:0x1 forCharacteristicName:@"config" type:CBCharacteristicWriteWithoutResponse];
		[self setNotifyValue:YES forCharacteristicName:@"data"];
		self.isOn = YES;
	}

	- (void)turnOff {
		[self writeByte:0x0 forCharacteristicName:@"config" type:CBCharacteristicWriteWithoutResponse];
		[self setNotifyValue:NO forCharacteristicName:@"data"];
		self.isOn = NO;
	}

	@end


In the class constructor [DEATemperatureService initWithName:baseHi:baseLo:], three BLE characteristics are specified: `service`, `data`, and `config` using defined address offsets to the 128-bit base address specified by `hi` and `lo`.

DEATemperatureService can be turned on or off via the `turnOn` and `turnOff` methods respectively (these methods are actually found in DEABaseService which DEATemperatureService inherits from, but presented here for convenience).

When notification for the `data` characteristic is turned on, the [DEATemperatureService notifyCharacteristicHandler:error:]
implementation handles the response from the BLE peripheral. With `notifyCharacteristicHandler:error:`, its implementation can be written to arbitrarily handle notifications from any specified notifying-enabled characteristic.


### Callback Block Example

The implementation of DEADeviceInfoService (shown in abbreivated form below) illustrates an example of using an ObjC block to implement a response callback function. This callback is executed upon the response for a request, in this case for the read request of the `system_id` and `model_number` BLE characteristic.

	@implementation DEADeviceInfoService
	- (id)initWithName:(NSString *)oName
				baseHi:(int64_t)hi
				baseLo:(int64_t)lo {
		self = [super initWithName:oName
							baseHi:hi
							baseLo:lo];
		if (self) {
			[self addCharacteristic:@"service" withAddress:kSensorTag_DEVINFO_SERV_UUID];
			[self addCharacteristic:@"system_id" withAddress:kSensorTag_DEVINFO_SYSTEM_ID];
			[self addCharacteristic:@"model_number" withAddress:kSensorTag_DEVINFO_MODEL_NUMBER];
			[self addCharacteristic:@"serial_number" withAddress:kSensorTag_DEVINFO_SERIAL_NUMBER];
			[self addCharacteristic:@"firmware_rev" withAddress:kSensorTag_DEVINFO_FIRMWARE_REV];
			[self addCharacteristic:@"hardware_rev" withAddress:kSensorTag_DEVINFO_HARDWARE_REV];
			[self addCharacteristic:@"software_rev" withAddress:kSensorTag_DEVINFO_SOFTWARE_REV];
			[self addCharacteristic:@"manufacturer_name" withAddress:kSensorTag_DEVINFO_MANUFACTURER_NAME];
			[self addCharacteristic:@"ieee11073_cert_data" withAddress:kSensorTag_DEVINFO_11073_CERT_DATA];
		}
		return self;
	}

	- (void)readDeviceInfo {
		[self readValueForCharacteristicName:@"system_id" withBlock:^(NSData *data, NSError *error) {
			NSMutableString *tmpString = [NSMutableString stringWithFormat:@""];
			unsigned char bytes[data.length];
			[data getBytes:bytes];
			for (int ii = data.length; ii >= 0;ii--) {
				[tmpString appendFormat:@"%02hhx",bytes[ii]];
				if (ii) {
					[tmpString appendFormat:@":"];
				}
			}

			NSLog(@"system id: %@", tmpString);
			self.system_id = tmpString;

		}];

		[self readValueForCharacteristicName:@"model_number" withBlock:^(NSData *data, NSError *error) {
			if (error) {
				NSLog(@"ERROR: %@", error);
				return;
			}

			NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
			self.model_number = payload;
			NSLog(@"model: %@", payload);
		}];
	}
	@end


## Recommended Code Walk Through

To better understand how YmsCoreBluetooth works, it is recommended to first read the source of the following BLE service implementations:

* DEAAccelerometerService, DEABarometerService, DEAGyroscopeService, DEAHumidityService, DEAMagnetometerService, DEASimpleKeysService, DEATemperatureService

Then the BLE peripheral implementation of the TI SensorTag:

* DEASensorTag

Then the application service which manages all known peripherals:

* DEACBAppService

The [Class Hierarchy](http://kickingvegas.github.io/YmsCoreBluetooth/appledoc/hierarchy.html) is very instructive in showing the relationship of the above classes to the YmsCoreBluetooth framework.


## Writing your own Bluetooth LE service with YmsCoreBluetooth

Learn how to write your own Bluetooth LE service by reading the example of how its done for the TI SensorTag in the [Tutorial](http://kickingvegas.github.io/YmsCoreBluetooth/appledoc/docs/tutorial/Tutorial.html).

## Questions

While quite functional, YmsCoreBluetooth is still very much in an early state and there's always room for improvement. Please submit any questions or [issues to the GitHub project for YmsCoreBluetooth](https://github.com/kickingvegas/YmsCoreBluetooth/issues?labels=&milestone=&page=1&state=open).


## Notes

Code tested on:

* iPhone 4S, iOS 6.1.3
* TI SensorTag firmware 1.2, 1.3.

## Known Issues
* No support is offered for the iOS simulator due to the instability of the CoreBluetooth implementation on it. Use this code only on iOS hardware that supports CoreBluetooth. Given that Apple does not provide technical support for CoreBluetooth behavior on the iOS simulator [TN2295](http://developer.apple.com/library/ios/#technotes/tn2295/_index.html), I feel this is a reasonable position to take. Hopefully in time the iOS simulator will exhibit better CoreBluetooth fidelity.

## Changes
### Tue May 7 2013
* Bugfixes: #41, #42

### Mon May 6 2013
* Issue #19 - First draft of Tutorial written
* Added initial support for launching a local notification when *Deanna* app in the background. The view controller for the SensorTag must be presented before going into the background for local notifications to work.

### Wed May 2 2013
* Issue #34 - Updated YmsCoreBluetooth Documentation

### Wed May 1 2013
* Improved API for reads and writes using either blocks or notifications.
* Issue #12 - Callback blocks for service requests implemented.
* Issue #22 - Support for reading SensorTag device info implemented.
* Issue #24 - API version implemented.
* Bugfix #31 - Remove all UI dependencies in YmsCoreBluetooth. Handling CBCentralManager state is an application UX issue.

### Fri Apr 26 2013
* Bugfix #21 - YMSCBService now supports constructor with 128-bit base address.
* Issue #23 - Moved SensorTag specific methods (`requestConfig`, `responseConfig`, `turnOn`, `turnOff`) from YMSCBService.

### Wed Apr 24 2013
* Bugfix #5 to support multiple SensorTags is now in. With many thanks to Texas Instruments, a second SensorTag was donated to YmsCoreBluetooth to test for multiple peripherals.
* Support for deleting discovered peripherals is in.
* Support for discovering unknown peripherals is in.

### Sat Apr 20 2013
* Bugfix #15 where connect button is blocked when scanning.
* Bugfixes on handling peripheral disconnects.

### Thu Apr 18 2013 - Major Revision
* Refactored `DECBAppService` to support:
    * Separation of peripheral discovery by scanning from peripheral retrieval via stored UUID.
    * Removed `NSNotification` messages to use `CBCentralManagerDelegate` methods instead.
* Reorganized physical file directory structure to match that of Xcode project group structure.
* Added RSSI display to both peripheral screen and SensorTag screen.
* Added connect button per peripherals discovered.
* Initial support for multiple SensorTags. (This has not yet been tested, due to the fact that I have only 1 SensorTag to test.)

### Sun Mar 3 2013
* First stable release.
* Support for communication with all sensors/services on a SensorTag.
* Initial documentation for YmsCoreBluetooth API and Deanna source code.


### License

    Copyright 2013 Yummy Melon Software LLC

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Author: Charles Y. Choi <charles.choi@yummymelon.com>





