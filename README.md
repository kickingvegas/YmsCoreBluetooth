# YmsCoreBluetooth
A framework for building Bluetooth 4.0 Low Energy (aka Smart or LE) iOS applications using the CoreBluetooth API. Includes Deanna, an iOS application using YmsCoreBluetooth to communicate with a [TI SensorTag](http://processors.wiki.ti.com/index.php/Bluetooth_SensorTag).

[YmsCoreBluetooth API Reference](http://kickingvegas.github.io/YmsCoreBluetooth/appledoc/hierarchy.html)

## Notes

Code tested on:

* iPhone 4S, iOS 6.1.3
* TI SensorTag firmware 1.2, 1.3.

### On Using the iOS Simulator
No support is offered for the iOS simulator due to the instability of the CoreBluetooth implementation on it. Use this code only on iOS hardware that supports CoreBluetooth. Given that Apple does not provide technical support for CoreBluetooth behavior on the iOS simulator [TN2295](http://developer.apple.com/library/ios/#technotes/tn2295/_index.html), I feel this is a reasonable position to take. Hopefully in time the iOS simulator will exhibit better CoreBluetooth fidelity.

## Changes
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





