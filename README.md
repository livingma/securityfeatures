*****Welcome to the Automated Deployment Encryption Tools*****

This tools will prompt the user for the center and application name.

 Generate Keys - this is a one time only command that will generate public and private keys.
 This functionality has two commands, the _alt version allows you to pass arguments while bypassing prompts.
   Usage: ruby autodeploymentAPI.rb generatekeys
   Usage: ruby autodeploymentAPI.rb generatekeys_alt <center> <application>

 Encrypt Data - you pass a string argument and it encrypt it then encodes the value then dumps it to the screen.
 For example, if it is a password simply copy the output to the LST/CFG for the value of that property.
   Usage: ruby autodeploymentAPI.rb encrypt <stringValue>

 Decrypt Data - you pass a string argument representing the encrypted, encoded value and it will decode and decry
   Usage: ruby autodeploymentAPI.rb decrypt <stringValue>

 API Usage: see the following steps

 1. place autodeploymentAPI.rb in a directory (ex. /var/lib/peadmin)
 2. export RUBYLIB=/var/lib/peadmin
 3. Add require 'autodeploymentAPI' to existing ruby applicatio to extend functionality to another ruby program
