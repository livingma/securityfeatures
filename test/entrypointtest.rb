require_relative 'autodeploymentAPI'

puts "Testing"
mark = EncryptData.new '/Users/Mark/workspace/rubyTest/encrypt.properties'
mark.generatekeys('oimt','rqst')
value = mark.encryptValue('mark','oimt','rqst')
mark.decryptValue(value,'oimt','rqst')