#  magField

A SwiftUI app for taaking magnetic field measurements using the device's built in magnetometer.

Built for iOS 16.1 onwards. 


## Usage

1. Readings begin when the app is launched.
1. Press pause to freeze at the current measurement.
1. The readings can be zeroed to cancel out ambient fields; typically the device's + Earth's field.
1. when zeroed the compass arrow will hide until a significant field is present.

### Recording
1. Press record.
1. Wait.
1. Press stop.
1. Tap share to share the data as a CSV file.

The data will look like this:

```
time (ms), x (μT), y (μT), z (μT), magnitude (μT), direction (rad)
76088656, 42.370391845703125, 2.5179443359375, -66.14413452148438, 78.59158148576428, -0.05935645758151682
76088691, 41.82176208496094, 2.47576904296875, -66.32456970214844, 78.44831268051816, -0.05912839480731112
```
