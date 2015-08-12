# securityfeatures
OpenSSL Encryption Application

*****Welcome to the Automated Deployment Encryption Tools*****

This tools will prompt the user for the center and application name.

 Generate Keys - this is a one time only command that will generate public and private keys.
   Usage: ruby autodeploymentAPI generatekeys

 Encrypt Data - you pass a string argument and it encrypt it then encodes the value then dumps it to the screen.
 For example, if it is a password simply copy the output to the LST/CFG for the value of that property.
   Usage: ruby autodeploymentAPI encrypt "stringValue

 Decrypt Data - you pass a string argument representing the encrypted/encoded value and it will decode/decrypt it giving you the original password.
   Usage: ruby autodeploymentAPI decrypt
