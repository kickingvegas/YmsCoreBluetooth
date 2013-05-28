<link rel="stylesheet" type="text/css" href="css/book.css" />

# YmsCoreBluetooth Tutorial

**YmsCoreBluetooth** is a framework for building Bluetooth LE capability to an iOS app. It extends the CoreBluetooth framework by implementing functionality to manage BLE peripherals, their services, and the characteristics of those services. 

The communication patterns used by **YmsCoreBluetooth** are as follows:

* Notifications are handled by implementing a handler method.

* Read/Write requests are handled using callback functions implemented as ObjectiveC blocks.

This tutorial will describe how to build a Bluetooth LE peripheral driver based on YmsCoreBluetooth.

# Building a *SensorTag* Peripheral

Shown below is a partial file hierarchy of *Deanna* to help illustrate the organization and construction of TI SensorTag peripheral using the **YmsCoreBluetooth** framework. There are two directories of interest:

* `YmsCoreBluetooth/` which contains all files for this framework
* `Deanna/Services/` which contains an implementation of the *SensorTag* peripheral

![YMSCB File Hierarchy](images/ymscb_project_hierarchy.jpg)

With the above figure, let's walk through building a *SensorTag* peripheral.

## Subclass YMSCBCentralManager to make DEACentralManager

The class DEACentralManager in `Deanna/Services/DEACentralManager.[hm]` is an application service to manage all known peripherals as defined by you the implementer. In this case we're only concerning ourselves with *SensorTag* peripherals.
It is typically implemented as a singleton instance and contains the following method implementations:

* `sharedService`
* `startScan`
* `handleFoundPeripheral`
* `managerPoweredOnHandler`

The `sharedService` method is a singleton constructor for DEACentralManager. In this implementation, the property [YMSCBCentralManager knownPeripheralNames] is set using [YMSCBCentralManager initWithKnownPeripheralNames:queue:userStoredPeripherals:] to help identify and filter the peripherals you care to communicate with.

	+ (DEACentralManager *)sharedService {
		if (sharedCentralManager == nil) {
			NSArray *nameList = @[@"TI BLE Sensor Tag", @"SensorTag"];
			sharedCentralManager = [[super allocWithZone:NULL] initWithKnownPeripheralNames:nameList
																					queue:nil
																	 useStoredPeripherals:YES];
		}
		return sharedCentralManager;
	}

The `startScan` method lets you define how to go about scanning for peripherals. Within its implementation should be a call to `scanForPeripheralsWithServices:options:withBlock:` to tell the `CBCentralManager` property `manager` to start scanning.

	- (void)startScan {
		NSDictionary *options = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
		
		__weak DEACentralManager *this = self;
		[self scanForPeripheralsWithServices:nil
									 options:options
								   withBlock:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error) {
									   if (error) {
										   NSLog(@"Something bad happened with scanForPeripheralWithServices:options:withBlock:");
										   return;
									   }

									   NSLog(@"DISCOVERED: %@, %@, %@ db", peripheral, peripheral.name, RSSI);
									   [this handleFoundPeripheral:peripheral];
								   }];

	}

Note that a weak pointer named `this` is set to `self`. This is done to handle retain issues with referencing self within an ObjectiveC block.

The callback block is executed upon a response from a BLE peripheral that is advertising. A discovered BLE peripheral will pass a pointer to itself (`peripheral`), advertisement data (`advertisementData`), its RSSI value (`RSSI`), and in the event of a failure, an error object (`error`) to the callback block. In this implementation, the execution of the callback block will call `handleFoundPeripheral:`. Note that the statements in `handleFoundPeripheral:` could just as easily be located within the block statement.

The `handleFoundPeripheral:` method defines what to do once you've found a peripheral via scanning. In the case of a *SensorTag* it is to instantiate `DEASensorTag`, a subclass of `YMSCBPeripheral`. 

    - (void)handleFoundPeripheral:(CBPeripheral *)peripheral {
        YMSCBPeripheral *yp = [self findPeripheral:peripheral];
		
        if (yp == nil) {
            BOOL isUnknownPeripheral = YES;
            for (NSString *pname in self.knownPeripheralNames) {
                if ([pname isEqualToString:peripheral.name]) {
                    DEASensorTag *sensorTag = [[DEASensorTag alloc] initWithPeripheral:peripheral
                                                                                baseHi:kSensorTag_BASE_ADDRESS_HI
                                                                                baseLo:kSensorTag_BASE_ADDRESS_LO
                                                                            updateRSSI:YES];
                    [self.ymsPeripherals addObject:sensorTag];
                    isUnknownPeripheral = NO;
                    break;
                }
            }

            if (isUnknownPeripheral) {
                //TODO: Handle unknown peripheral
                yp = [[YMSCBPeripheral alloc] initWithPeripheral:peripheral baseHi:0 baseLo:0 updateRSSI:NO];
                [self.ymsPeripherals addObject:yp];
            }
        }
    }


An alternate implementation of `startScan` without using a block callback is to use `scanForPeripheralsWithServices:options:`. In this case, you then *must* implement `handleFoundPeripheral:` to handle the discovered peripheral.

A common task is to define program behavior upon a change in the state of `CBCentralManager`. This is accomplished by implementing the methods which are named after their respective states:

* `managerPoweredOnHandler`
* `managerUnknownHandler`
* `managerPoweredOffHandler`
* `managerResettingHandler`
* `managerUnauthorizedHandler`
* `managerUnsupportedHandler`

For our purpose, we are interested on retrivieving previously discovered peripherals whose UUIDs have been persisted from a previous run of the app upon `CBCentralManager` being powered on:

	- (void)managerPoweredOnHandler {
		if (self.useStoredPeripherals) {
			NSArray *peripheralUUIDs = [YMSCBStoredPeripherals genPeripheralUUIDs];
			__weak DEACentralManager *this = self;
			[self retrievePeripherals:peripheralUUIDs
							withBlock:^(CBPeripheral *peripheral) {
								[this handleFoundPeripheral:peripheral];
							}];
		}
	}


## Subclass YMSCBPeripheral to make DEASensorTag

The class implementation of `DEASensorTag` in `Deanna/Services/SensorTag/DEASensorTag.[hm]` is where the top-level behavior of the *SensorTag* peripheral is captured. Two methods are implemented:

* `initWithPeripheral:central:baseHi:baseLo:updateRSSI:` - the constructor for DEASensorTag
* `connect` - the method to initiate a connection request for the peripheral.

The class constructor for `DEASensorTag` is responsible for instantiating subclasses of `YMSCBService` to capture the behavior of the different BLE services offered by the *SensorTag*. The source for this constructor, `initWithPeripheral:central:baseHi:baseLo:updateRSSI:` is shown below:

	- (id)initWithPeripheral:(CBPeripheral *)peripheral
					 central:(YMSCBCentralManager *)owner
					  baseHi:(int64_t)hi
					  baseLo:(int64_t)lo
				  updateRSSI:(BOOL)update {


		self = [super initWithPeripheral:peripheral central:owner baseHi:hi baseLo:lo updateRSSI:update];

		if (self) {
			DEATemperatureService *ts = [[DEATemperatureService alloc] initWithName:@"temperature" parent:self baseHi:hi 	baseLo:lo];
			DEAAccelerometerService *as = [[DEAAccelerometerService alloc] initWithName:@"accelerometer" parent:self 	baseHi:hi baseLo:lo];
			DEASimpleKeysService *sks = [[DEASimpleKeysService alloc] initWithName:@"simplekeys" parent:self baseHi:hi 	baseLo:lo];
			DEAHumidityService *hs = [[DEAHumidityService alloc] initWithName:@"humidity" parent:self baseHi:hi 	baseLo:lo];
			DEABarometerService *bs = [[DEABarometerService alloc] initWithName:@"barometer" parent:self baseHi:hi 	baseLo:lo];
			DEAGyroscopeService *gs = [[DEAGyroscopeService alloc] initWithName:@"gyroscope" parent:self baseHi:hi 	baseLo:lo];
			DEAMagnetometerService *ms = [[DEAMagnetometerService alloc] initWithName:@"magnetometer" parent:self 	baseHi:hi baseLo:lo];
			DEADeviceInfoService *ds = [[DEADeviceInfoService alloc] initWithName:@"devinfo" parent:self baseHi:hi 	baseLo:lo];

			self.serviceDict = @{@"temperature": ts,
								 @"accelerometer": as,
								 @"simplekeys": sks,
								 @"humidity": hs,
								 @"magnetometer": ms,
								 @"gyroscope": gs,
								 @"barometer": bs,
								 @"devinfo": ds};
		}
		return self;

	}

In this implementation, the following BLE services of the *SensorTag* are supported:

* Temperature Service - DEATemperatureService
* Accelerometer Service - DEAAccelerometerService
* Simple Keys Service - DEASimpleKeysService
* Humidity Service - DEAHumidityService
* Barometer Service - DEABarometerService
* Gyroscope Service - DEAGyroscopeService
* Magnetometer Service - DEAMagnetometerService
* Device Information Service - DEADeviceInfoService
* 

The instances of these classes are stored in the dictionary [YMSCBPeripheral serviceDict] where their respective keys are human-readable strings.

The `connect` method implements all the desired behavior involved with connecting to a BLE peripheral. It is here where the utility of ObjectiveC blocks to handle response behavior becomes evident.

In the following implementation the following tasks are undertaken in sequential order:

* peripheral connection (`connectionWithOptions:withBlock:`)
* discover services for that peripheral (`discoverServices:withBlock:`)
* discover charcteristics for each service (`discoverChararcteristics:withBlock:`)
* discover descriptors for each characteristic (`discoverDescriptors:withBlock:`)

Note that the tasks listed above are accomplished via a nested chain of callbacks.

	- (void)connect {
		// Watchdog aware method
		[self resetWatchdog];

		[self connectWithOptions:nil withBlock:^(YMSCBPeripheral *yp, NSError *error) {
			if (error) {
				return;
			}

			[yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
				if (error) {
					return;
				}

				for (YMSCBService *service in yservices) {
					if ([service.name isEqualToString:@"simplekeys"]) {
						__weak DEASimpleKeysService *thisService = (DEASimpleKeysService *)service;
						[service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, 	NSError *error) {
							[thisService turnOn];
						}];

					} else if ([service.name isEqualToString:@"devinfo"]) {
						__weak DEADeviceInfoService *thisService = (DEADeviceInfoService *)service;
						[service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, 	NSError *error) {
							[thisService readDeviceInfo];
						}];

					} else {
						__weak DEABaseService *thisService = (DEABaseService *)service;
						[service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, 	NSError *error) {
							for (NSString *key in chDict) {
								YMSCBCharacteristic *ct = chDict[key];
								//NSLog(@"%@ %@ %@", ct, ct.cbCharacteristic, ct.uuid);

								[ct discoverDescriptorsWithBlock:^(NSArray *ydescriptors, NSError *error) {
									if (error) {
										return;
									}
									for (YMSCBDescriptor *yd in ydescriptors) {
										NSLog(@"Descriptor: %@ %@ %@", thisService.name, yd.UUID, yd.cbDescriptor);
									}
								}];
							}
						}];
					}
				}
			}];
		}];
	}


## Define BLE services of this peripheral.

The BLE services of a peripheral are described by using subclasses of YMSCBService. For the *SensorTag*, all but the device information service (DEADeviceInfoService) are subclassed from DEABaseService which has support for common configuration and turn on/off behavior.

This subclass is responsible for implementing:

* Properties that are specific to the bluetooth service.
* The class constructor [YMSCBService initWithName:parent:baseHi:baseLo:], defining the BLE characteristics with subclasses of YMSCBCharacteristic via [YMSCBService addCharacteristic:withOffset:].
* `notifyCharacteristicHandler` to handle responses for characteristics whose notifications have been turned on.
* Any processing logic germane to the BLE service (e.g. temperature conversion, data correction/smoothing, etc.).
* Specific read/write transaction sequences germane to the BLE service.

Shown below is the implementation for `DEAAccelerometerService`.

	float calcAccel(int16_t rawV) {
		float v;
		v = ((float)rawV + 1.0) / (256.0/4.0);
		return v;
	}

	@implementation DEAAccelerometerService


	- (id)initWithName:(NSString *)oName
				parent:(YMSCBPeripheral *)pObj
				baseHi:(int64_t)hi
				baseLo:(int64_t)lo {
		self = [super initWithName:oName
							parent:pObj
							baseHi:hi
							baseLo:lo];
		if (self) {
			[self addCharacteristic:@"service" withOffset:kSensorTag_ACCELEROMETER_SERVICE];
			[self addCharacteristic:@"data" withOffset:kSensorTag_ACCELEROMETER_DATA];
			[self addCharacteristic:@"config" withOffset:kSensorTag_ACCELEROMETER_CONFIG];
			[self addCharacteristic:@"period" withOffset:kSensorTag_ACCELEROMETER_PERIOD];
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

			int16_t xx = val[0];
			int16_t yy = val[1];
			int16_t zz = val[2];
			
			self.x = [NSNumber numberWithFloat:calcAccel(xx)];
			self.y = [NSNumber numberWithFloat:calcAccel(yy)];
			self.z = [NSNumber numberWithFloat:calcAccel(zz)];

		}
	}

	@end

The class constructor `initWithName:parent:baseHi:baseLo:` defines four BLE characteristics using [YMSCBService addCharacteristic:withOffset:] which we can reference with the following four strings: ("service", "data", "config", "period").

When the service is turned on using the method [DEABaseService turnOn], notifications for the "data" characteristic are turned on. Handling notification events sent from the *SensorTag* are handled by `notifyCharacteristicHandler`. The acceleration measurements are stored as `NSNumber` properties `x`, `y`, `z`. These properties can then be Key-Value Observed (KVO) by the application, typically to be displayed in user interface.


# Comments
This document can always be improved. Please submit any comments or corrections about this document to the [issue tracker](https://github.com/kickingvegas/YmsCoreBluetooth/issues?state=open) for **YmsCoreBluetooth**.

Thank you for using **YmsCoreBluetooth**!










