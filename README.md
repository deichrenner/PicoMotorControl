# PicoMotorConnect
This Matlab package provides a connection to the NewFocus PicoMotor control unit 8752 via a TCP/IP connection. 
The package uses the underlying Java features directly accessible in Matlab to provided the TCP/IP socket connection to the PicoMotor controller.
Even though the manufacturer does not provide too much information out this controller there is a [blog arctile](https://blog.philippklaus.de/2012/09/new-focus-picomotor-ethernet-controller-8752-tcpip-control) by Philipp Klaus which actually gives some idea about how it works and provides the manual for the controller as well. 

The most important functions are implemented in PicoMotor.m. Have a look at the [User's Guide](https://blog.philippklaus.de/wp-content/uploads/Manual-15242.pdf) for a better reference of the individual commands implemented in this toolbox. 

## Cross Platform Compatibility
The JavaSocket implementation should work on Windows, OSX and Linux likewise. However, the communication has only been tested under Windows so far. 

## Known bugs
* None so far. Please file a bug report in case you find one.

## Example
Make the PicoMotorConnect package known to your Matlab installation by adding it to the path. 

Connect the 8752 controller to your computer via Ethernet. 

Instantiate a PicoMotor object:
`PM = PicoMotor();`

Get the firmware version:
`PM.fwversion % returns the actual firmware version of the controller`

Define the axis to be used:
`PM.setMotor(1) % sets the current axis to axis 1`

Move 5 steps in positive direction with the selected axis:
`PM.rel(5) % relative move`

## Scientific Usage
If you use this code for scientific purpose, please cite it.

## Licensing
Author: Klaus Hueck (e-mail: khueck (at) physik (dot) uni-hamburg (dot) de)
Version: 0.1
Changes tracker:  26.02.2017  - First version
License: GPL v3
