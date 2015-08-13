require 'openssl'
require 'base64'
require 'optparse'
require 'fileutils'


$publicKey=""
$privateKey=""
$publicKeyFileName=""
$privateKeyFileName=""
$center=nil
$application=nil

def generatekeys()
  key = OpenSSL::PKey::RSA.new(2048)
  _getKeynames()
  # make directories if they do not exist
  if not File.exists?("#{$center}/#{$application}")
    FileUtils::mkdir_p "#{$center}/#{$application}"
    puts "Created directory #{$center}/#{$application}"
  end
  open $privateKeyFileName, 'w' do |io| io.write key.to_pem end
  open $publicKeyFileName, 'w' do |io| io.write key.public_key.to_pem end
  puts "Key generated!"
end

def generatekeys_overloaded(center,application)
  key = OpenSSL::PKey::RSA.new(2048)
  $center = center
  $application = application
  _getKeynames()
  # make directories if they do not exist
  if not File.exists?("#{$center}/#{$application}")
    FileUtils::mkdir_p "#{$center}/#{$application}"
    puts "Created directory #{$center}/#{$application}"
  end
  open $privateKeyFileName, 'w' do |io| io.write key.to_pem end
  open $publicKeyFileName, 'w' do |io| io.write key.public_key.to_pem end
  puts "Key generated!"
end

def _setPublicKeyName(center,application)
  _publickey = "#{$center}/#{$application}/public_" + center + "_" + application + "_key.pem"
  return _publickey
end

def _setPrivateKeyName(center,application)
  _privatekey = "#{$center}/#{$application}/private_" + center + "_" + application + "_key.pem"
  return _privatekey
end

def _getKeynames()
  if $center.nil? || $application.nil? then
    puts "Specify the center name?"
    STDOUT.flush
    $center = STDIN.gets.chomp
    puts "Specify the application name?"
    $application = STDIN.gets.chomp
  end
  $publicKeyFileName = _setPublicKeyName($center,$application)
  $privateKeyFileName = _setPrivateKeyName($center,$application)
end
  

def loadPrivateKey(key_file_name)
  begin
    $privateKey = OpenSSL::PKey::RSA.new File.read(key_file_name)
    puts 'privateKey loaded.'
  rescue => error
    puts 'Unable to load private key'
    return
  end
end

def loadPublicKey(key_file_name)
  begin
    $publicKey = OpenSSL::PKey::RSA.new File.read(key_file_name)
    puts 'publicKey loaded.'
  rescue => error
    puts 'Unable to load public key'
    return
  end
end

def checkarguments(num, command)
  unless ARGV.length == num
    puts "Wrong number of arguments."
    puts "Usage: ruby autodeploymentAPI.rb %{command} <value>\n"
    exit
  end
end

def encryptValue (value)
  # Needed to preserve special characters
  encrypted = $publicKey.public_encrypt(value)
  encoded = Base64.strict_encode64(encrypted)
  puts "Encoded Value: \n" + encoded; puts
end

def decryptValue(value)
  begin
    # Needed to preserve special characters
    decoded = Base64.decode64(value)
    decrypted = $privateKey.private_decrypt(decoded)
    puts "Decrypted Value: " + decrypted
  rescue => error
    puts "Permission Denied; decrypting is not allowed"
  end
end

def loadKeys()
  _getKeynames()
  loadPrivateKey $privateKeyFileName
  loadPublicKey $publicKeyFileName
end

if __FILE__ == $0
  ARGV.each do|a|
    puts "Argument: #{a}"
  end
  
  if ARGV[0] == nil
    puts "*****Welcome to the Automated Deployment Encryption Tools*****"; puts
    puts "This tools will prompt the user for the center and application name."; puts
    puts " Generate Keys - this is a one time only command that will generate public and private keys.\n"
    puts "   Usage: ruby autodeploymentAPI generatekeys"; puts
    puts " Encrypt Data - you pass a string argument and it encrypt it then encodes the value then dumps it to the screen.\n For example, if it is a password simply copy the output to the LST/CFG for the value of that property."
    puts "   Usage: ruby autodeploymentAPI encrypt stringValue"; puts
    puts " Decrypt Data - you pass a string argument representing the encrypted, encoded value and it will decode and decrypt it giving you the original password."
    puts "   Usage: ruby autodeploymentAPI decrypt"
  end

  if ARGV[0] == "encrypt"
    checkarguments 2,"encrypt"
    if ARGV[1].nil?
      puts "An argument for the value to be encrypted is needed"
    else
      loadKeys()
      encryptValue ARGV[1]
    end
  end

  if ARGV[0] == "decrypt"
    checkarguments 2,"decrypt"
    if ARGV[1].nil?
      puts "An argument for the value to be decrypted is needed"
    else
      loadKeys()
      decryptValue ARGV[1]
    end
  end

  if ARGV[0] == "generatekeys"
    generatekeys
  end
  
if ARGV[0] == "generatekeys_overloaded"
    checkarguments 3,"generatekeys_overloaded"
    generatekeys_overloaded ARGV[1], ARGV[2]
  end

end
