# YmsCoreBluetooth Changes

### Sun Sep 27 2015
Removed support for now obsolete iOS 9 CoreBluetooth delegate methods:
* [CBPeripheralDelegate peripheralDidInvalidateServices:]
* [CBCentralManagerDelegate centralManager:didRetrievePeripherals:]
* [CBCentralManagerDelegate centralManager:didRetrieveConnectedPeripherals:]

Administrative changes:
* Updated copyright to 2015
* Use semantic versioning; version is now set to 1.1.0 (4)

### Mon Jan 13 2014
Added methods to support BLE addressing:

- initWithName:parent:baseHi:baseLo:serviceBLEOffset:
- addCharacteristic:withBLEOffset:

### Wed Jan  1 2014
* #97 - Add [YMSCBPeripheral readRSSI] method
* #98 - Make objectForKeyedSubscript: a public method for YMSCBPeripheral and YMSCBService
* #96 - Add [YMSCBPeripheral name] convenience accessor to cbPeripheral.name

### Mon Dec 2 2013
* #92 - Reimplement [YMSCBCentralManager count] to use KVO collection method.
* #94 - Implement [YMSCBCentralManager removeAllPeripherals] method.

### Sat Nov 16 2013

* Partial pull request accept from @tuscland #89. 
  - Group SensorTag service properties so that KVO changes for the properties within each service can be temporally coherent.
  
  - `[YMSCBCentralManager ymsPeripherals]` is now KVO compliant using mutable accessor methods described in:
     <https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/AccessorConventions.html>
     
     - Note that interface to `ymsPeripherals` is now read-only.


  - API Change:

        [DEAAccelerometerService readPeriod] is now [DEAAccelerometerService requestReadPeriod]


### Tue Nov 5 2013
* #87 - Calculate 128-bit address offset to comply to BLE spec.

API changes related to this issue:

YMSCBUtils:

        + (NSString *)genCBUUID:(yms_u128_t *)base withIntBLEOffset:(int)addrOffset;
        + (CBUUID *)createCBUUID:(yms_u128_t *)base withIntBLEOffset:(int)addrOffset;

YMS128.c:

        yms_u128_t yms_u128_genBLEOffset(int value);
        
Removed files:
        DEASensorTagUtils.h, DEASensorTagUtils.m, TISensorTag.c

* #73 - Fixed assignment of connectCallback property to not use extraneous copy.

### Sat Oct 26 2013 - Pull Request Accepted from @coupgar
* Fix reset of watchdog timer for conditions when a peripheral connection has either succeeded or failed.

### Sat Oct 12 2013 - Pull Request Accepted from @coupgar
* Fix centralManager:didRetrieveConnectedPeripherals won't be called when you call retrieveConnectedPeripheralsWithServices

### Wed Sep 25 2013 - Interim Release (ver 1.02)
* Fixed handling of callback properties so that they are set to nil after execution in a thread-safe manner.
* Added #define kYMSCBVersionNumber

### Sat Sep 18 2013 - iOS7 Release (ver 1.0)
* Updated codebase to support all iOS7 changes to the CoreBluetooth API.
* DeannaMac will not compile on OS X < 10.9. For OS X 10.8 users, please use the [ios6 branch](https://github.com/kickingvegas/YmsCoreBluetooth/tree/ios6).

### Sat Sep 7 2013 - Interim Release (ver 0.946)
* #25 - Support for accelerometer period
* #73 - Fix declaration of block properties to copy

### Tue Jul 16 2013 - Interim Release (ver 0.945)
* Bugfix #61 - Change all delegate implementations so that the callback is performed on the main thread.

### Sat Jul 6 2013 - Interim Release (ver 0.944)
* Bugfix #69 - Reload peripheralsTableView when dismissing SensorTag view controller
* Bugfix #68 - Handle CoreBluetooth XPC reset
* Issue #32 - Added interim icon design by Wayne Dahlberg

### Mon Jun 24 2013 - Interim Release (ver 0.943)
* Initial work on beautifying Deanna app (Issue #62) based on graphic design work by [Wayne Dahlberg](http://waynedahlberg.com).
* Fixes to updates of RSSI values via scanning or by connection.

### Sat Jun 22 2013 - Interim Release (ver 0.942)
* Reimplemented background thread UI updates to use GCD `dispatch_async()` instead of `performSelectorOnMainThread:` (Issue #61).
* Updated documentation.

### Wed Jun 19 2013 - Interim Release (ver 0.941)
* Support for background thread operation of BLE transactions (Issues #57, #58, #59)

Prior releases ran all BLE transactions off the main UI thread. For a small number of BLE devices (< 5), performance degradation was neglible. However, in an environment with many devices (> 30), support for background operation that does not block the main UI is necessary. Changes so that messages sent to the delegate for `YMSCBCentralManager` and `YMSCBPeripheral` are executed in the main thread.

Similarly, any change to a property of a subclass of `YMSCBService` should be executed in the main thread so that it can be properly key-value observed (KVO) by any UI components.

* API Change: Removed RSSI auto-update functionality from YmsCoreBluetooth.

This directly attributed with background thread operation of BLE transactions. Prior code, if run using a background thread, would not correctly schedule a read of the RSSI value of a peripheral. It is now the responsibility of an application using YmsCoreBluetooth to invoke `readRSSI` and handle the response to update the UI properly.

* Update of Deanna and DeannaMac to support background thread BLE transactions.

#### API Changes

* `[YMSCBPeripheral initWithPeripheral:central:baseHi:baseLo:updateRSSI:]` is obsolete.<br/>Replacing this call is `[YMSCBPeripheral initWithPeripheral:central:baseHi:baseLo:]`

* `[YMSCBPeripheral updateRSSI]` is obsolete.

* `[YMSCBCentralManager initWithKnownPeripheralNames:queue:]` is obsolete.<br/>Replacing this call is `[YMSCBCentralManager initWithKnownPeripheralNames:queue:delegate:]`

* `[YMSCBCentralManager initWithKnownPeripheralNames:queue:useStoredPeripherals:]` is obsolete.<br/>Replacing this call is `[YMSCBCentralManager initWithKnownPeripheralNames:queue:userStoredPeripherals:delegate:]`



### Mon Jun 3 2013 - Disco Release (ver 0.94)
* Issue #9 - OS X Support

YmsCoreBluetooth now supports OS X! Includes app target DeannaMac which replicates functionality found in Deanna for iOS.

Tested Mac Environment:

* OS X 10.8.3
* Cirago Bluetooth 4.0 USB Adapter
* iMac 27 Mid-2010

### Sun May 26 2013 - Rare Groove Release (ver 0.93)
* Issue #47 - rename YMSCBAppService to YMSCBCentralManager. 
  Associated changes include:
    - renaming DEAAppService to DEACentralManager
	- rename variable cbAppService to centralManager

* API change to fully embrace ObjectiveC block-based callbacks.
* API change to map BLE operations to data object hierarchy.

**API 0.93 is a BIG CHANGE.** It is largely a rethink of YmsCoreBluetooth to support the pattern for hierarchical block-based operations. This will very much *break code* written for prior releases of YmsCoreBluetooth. That said, the changes should be fairly comprehensible and address the following points going forward:

* Improved understanding of API behavior: prior releases had too much implicit behavior ("magic") which made involuntary decisions for the developer using the API. Using blocks gives the developer a clearer and more structured view of the BLE transactions to be made.
* With the pattern for hierarchical block-based operations in place, a more structured way to add new API features. Like Winter, characteristic descriptors are coming.

### Sun May 12 2013 - Moombahton Release (ver 0.92)
* Block-based callbacks for central manager scanning, peripheral connection, and peripheral retrieval are now supported.
* Watchdog timeout for unanswered peripheral connection requests are now supported.
* Significant API changes to YMSCBCentralManager and YMSCBPeripheral detailed below.

#### API 0.92 Changes

<table border='1'>
<tbody>
<tr><td colspan='2'><code>YMSCBCentralManager (previously named YSMCBAppService)</code></td></tr>
<tr><td>obsolete</td><td><code>- (void)persistPeripherals</code></td><td>Replaced by YMSCBStoredPeripherals</td></tr>
<tr><td>obsolete</td><td><code>- (void)loadPeripherals</code></td><td>Replaced by YMSCBStoredPeripherals</td></tr>
<tr><td>new</td><td><code>- (id)initWithKnownPeripheralNames:(NSArray *)nameList<br>&nbsp;&nbsp;&nbsp;queue:(dispatch_queue_t)queue<br>&nbsp;&nbsp;&nbsp;useStoredPeripherals:(BOOL)useStore;</code></td><td>Add support to optionally store peripherals.</td></tr>
<tr><td>obsolete</td><td><code>- (void)connectPeripheral:(NSUInteger)index;</code></td><td rowspan='2'>Use more accurate name</td></tr>
<tr><td>replaced by</td><td><code>- (void)connectPeripheralAtIndex:(NSUInteger)index<br>&nbsp;&nbsp;&nbsp;options:(NSDictionary *)options;</code></td></tr>
<tr><td>obsolete</td><td><code>- (void)disconnectPeripheral:(NSUInteger)index;</code></td><td rowspan='2'>Use more accurate name.</td></tr>
<tr><td>replaced by</td><td><code>- (void)disconnectPeripheralAtIndex:(NSUInteger)index;</code></td></tr>
<tr><td>new</td><td><code>- (void)connectPeripheral:(YMSCBPeripheral *)peripheral<br>&nbsp;&nbsp;&nbsp;options:(NSDictionary *)options;</code></td><td>Mirror CBCentralManager method</td></tr>
<tr><td>new</td><td><code>- (void)cancelPeripheralConnection:(YMSCBPeripheral *)peripheral;</code></td><td>Mirror CBCentralManager method</td></tr>
<tr><td>new</td><td><code>- (void)connectPeripheral:(YMSCBPeripheral *)peripheral<br>&nbsp;&nbsp;&nbsp;options:(NSDictionary *)options<br/>&nbsp;&nbsp;&nbsp;withBlock:(void (^)(YMSCBPeripheral *yp, NSError *error))connectCallback</code></td><td>Support block based connection</td></tr>
<tr><td>new</td><td><code>- (void)retrieveConnectedPeripherals</code></td><td>Mirror CBCentralManager method</td></tr>
<tr><td>new</td><td><code>- (void)retrieveConnectedPeripheralsWithBlock:<br>(void (^)(CBPeripheral *peripheral))retrieveCallback</code></td><td>Support block based connection</td></tr>
<tr><td>new</td><td><code>- (void)retrievePeripherals:(NSArray *)peripheralUUIDs</code></td><td>Mirror CBCentralManager method</td></tr>
<tr><td>new</td><td><code>- (void)retrievePeripherals:(NSArray *)peripheralUUIDs<br>&nbsp;&nbsp;&nbsp;withBlock:(void (^)(CBPeripheral *peripheral))retrieveCallback</code></td><td>Support block based connection</td></tr>
<tr><td>new</td><td><code>- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs<br>&nbsp;&nbsp;&nbsp;options:(NSDictionary *)options<br>&nbsp;&nbsp;&nbsp;withBlock:<br>(void (^)(CBPeripheral *,NSDictionary *, NSNumber *, NSError *))discoverCallback</code></td><td>Support block based connection</td></tr>
</tbody>
</table>

<table border='1'>
<tbody>
<tr><td colspan='2'><code>YMSCBPeripheral</code></td></tr>
<tr><td>obsolete</td>
<td><code>
- (id)initWithPeripheral:(CBPeripheral *)peripheral
    <br>&nbsp;&nbsp;&nbsp;baseHi:(int64_t)hi
    <br>&nbsp;&nbsp;&nbsp;baseLo:(int64_t)lo
    <br>&nbsp;&nbsp;&nbsp;updateRSSI:(BOOL)update;
</code></td><td rowspan='2'>Support parent property so that methods on parent can be called directly from an instance of YMSCBPeripheral.</td></tr>
<tr><td>replaced by</td>
<td><code>
- (id)initWithPeripheral:(CBPeripheral *)peripheral
    <br>&nbsp;&nbsp;&nbsp;parent:(YMSCBCentralManager *)owner
    <br>&nbsp;&nbsp;&nbsp;baseHi:(int64_t)hi
    <br>&nbsp;&nbsp;&nbsp;baseLo:(int64_t)lo
    <br>&nbsp;&nbsp;&nbsp;updateRSSI:(BOOL)update;
</code></td></tr>
<tr><td>new</td><td><code>- (void)discoverServices</code></td><td>Convenience method to call behavior from YMSCBCentralManager</td></tr>
<tr><td>new</td><td><code>- (void)connect</code></td><td>Convenience method to call behavior from YMSCBCentralManager</td></tr>
<tr><td>new</td><td><code>- (void)disconnect</code></td><td>Convenience method to call behavior from YMSCBCentralManager</td></tr>
</tbody>
</table>



### Wed May 8 2013
* Issue #37 - UI for SensorTag Device Information Service implemented.

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
* Refactored `DEACBAppService` to support:
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




