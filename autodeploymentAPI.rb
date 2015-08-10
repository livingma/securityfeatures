require 'openssl'
require 'base64'
require 'optparse'

$publicKey=""
$privateKey=""
$center=""
$application=""

def generatekeys
  key = OpenSSL::PKey::RSA.new(2048)
  _getKeynames()
  open $privateKey, 'w' do |io| io.write key.to_pem end
  open $publicKey, 'w' do |io| io.write key.public_key.to_pem end
  puts "Key generated!"
end

def _setPublicKeyName(center, application)
  _publickey = "public_" + center + "_" + application + "_key.pem"
  return _publickey
end

def _setPrivateKeyName(center, application)
  _privatekey = "private_" + center + "_" + application + "_key.pem"
  return _privatekey
end

def _getKeynames()
  puts "Specify the center name?"
  STDOUT.flush
  $center = STDIN.gets.chomp
  puts "Specify the application name?"
  $application = STDIN.gets.chomp
  $publicKey = _setPublicKeyName($center, $application)
  $privateKey = _setPrivateKeyName($center, $application)
end
  

def loadPrivateKey(key_file_name)
  privateKey = File.read('private_key.pem')
  puts 'privateKey loaded.'
end

def loadPublicKey(key_file_name)
  publicKey = File.read('public_key.pem')
  puts 'publicKey loaded.'
end

def checkarguments(num, command)
  unless ARGV.length == num
    puts "Wrong number of arguments."
    puts "Usage: ruby autodeploymentAPI.rb %{command} <value>\n"
    exit
  end
end

def encryptValue (value)
  key = OpenSSL::PKey::RSA.new File.read('public_key.pem')
  # Needed to preserve special characters
  encrypted = key.public_encrypt(value)
  encoded = Base64.strict_encode64(encrypted)
  puts "Encoded Value: \n" + encoded; puts
end

def decryptValue(value)
  # Needed to preserve special characters
  decoded = Base64.decode64(value)
  key = OpenSSL::PKey::RSA.new File.read('private_key.pem')
  decrypted = key.private_decrypt(decoded)
  puts "Decrypted Value: " + decrypted
end

def loadKeys()
  _getKeynames()
  loadPrivateKey $privateKey
  loadPublicKey $publicKey
end

if __FILE__ == $0
  ARGV.each do|a|
    puts "Argument: #{a}"
  end
  
  if ARGV[0] == nil
    puts "Welcome to the Automated Deployment Encryption Tools"
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

end
