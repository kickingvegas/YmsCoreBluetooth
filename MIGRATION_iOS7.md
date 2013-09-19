# YmsCoreBluetooth iOS7 Migration Guide

Listed below are the API changes for YmsCoreBluetooth. Please note this for any subclasses you have implemented based on the `YMSCB`-prefixed classes.

## YMSCBCentralManager

The following methods are now obsolete. 

		/**
		 Retrieves a list of known peripherals by their UUIDs.
		 */
		- (void)retrieveConnectedPeripherals;

		/**
		 Retrieves a list of known peripherals by their UUIDs and handles them using a callback block.

		 @param retrieveCallback Callback block to handle each retrieved peripheral.
		 */
		- (void)retrieveConnectedPeripheralswithBlock:(void (^)(CBPeripheral *peripheral))retrieveCallback;

		/**
		 Retrieves a list of the peripherals currently connected to the system and handles them using
		 handleFoundPeripheral:


		 @param peripheralUUIDs An array of CFUUIDRef objects from which CBPeripheral objects can be retrieved.
		 */
		- (void)retrievePeripherals:(NSArray *)peripheralUUIDs;


		/**
		 Retrieves a list of the peripherals currently connected to the system and handles them using
		 a callback block.

		 @param peripheralUUIDs An array of CFUUIDRef objects from which CBPeripheral objects can be retrieved. 
		 @param retrieveCallback Callback block to handle each retrieved peripheral.
		 The parameter of retrieve callback are:

		 * `peripheral` - the retrieved peripheral.

		 */
		- (void)retrievePeripherals:(NSArray *)peripheralUUIDs
						  withBlock:(void (^)(CBPeripheral *peripheral))retrieveCallback;

In place of the above methods use the following:


	  /**
	   Retrieves a list of known peripherals by their UUIDs.

	   @param identifiers A list of NSUUID objects.
	   @return A list of peripherals.

	   */
	  - (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;

	  /**
	   Retrieves a list of the peripherals currently connected to the system and handles them using
	   handleFoundPeripheral:


	   Retrieves all peripherals that are connected to the system and implement 
	   any of the services listed in <i>serviceUUIDs</i>.
	   Note that this set can include peripherals which were connected by other 
	   applications, which will need to be connected locally
	   via connectPeripheral:options: before they can be used.

	   @param identifiers A list of NSUUID services
	   @return A list of CBPeripheral objects.
	   */
	  - (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDS;


## YMSCBPeripheral

The following property has been added:

		/**
		 Flag to indicate if the watchdog timer has expired and forced a disconnect.
		 */
		@property (nonatomic, assign) BOOL watchdogRaised;

The following method has been added:

		/**
		 Return array of CBUUIDs for YMSCBService instances in serviceDict whose key is included in keys.

		 @param keys array of NSString keys, where each key must exist in serviceDict

		 @return array of CBUUIDs
		 */
		- (NSArray *)servicesSubset:(NSArray *)keys;


## YMSCBService

The following property has been added:

		/// Service UUID
		@property (nonatomic, strong) CBUUID *uuid;


Support for the property `uuid` has changed the constructor with the addition of the `serviceOffset` parameter.

         /**
          Initialize class instance.
          @param oName name of service
          @param pObj parent object which owns this service
          @param hi top 64 bits of 128-bit base address value
          @param lo bottom 64 bits of 128-bit base address value
          @param serviceOffset offset address of service
          @return YMSCBCharacteristic
          */
         - (instancetype)initWithName:(NSString *)oName
                               parent:(YMSCBPeripheral *)pObj
                               baseHi:(int64_t)hi
                               baseLo:(int64_t)lo
                        serviceOffset:(int)serviceOffset;

Please take note that this will change any subclasses of `YMSCBService` that you have.

The following method has been added:

		/**
		 Return array of CBUUIDs for YMSCBCharacteristic instances in characteristicDict whose key is included in keys.

		 @param keys array of NSString keys, where each key must exist in characteristicDict.

		 @return array of CBUUIDs
		 */
		- (NSArray *)characteristicsSubset:(NSArray *)keys;


## YMSCBStoredPeripherals

This method now maniuplates `NSUUID` instances instead of `CFUUIDRef` instances.


