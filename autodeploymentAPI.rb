require 'openssl'
require 'base64'
require 'optparse'

$publicKey=""
$privateKey=""

def generatekeys
  key = OpenSSL::PKey::RSA.new(2048)
  open 'private_key.pem', 'w' do |io| io.write key.to_pem end
  open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end
  puts "Key generated!"
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
  key = OpenSSL::PKey::RSA.new File.read('private_key.pem')
  # Needed to preserve special characters
  newValue = key.private_encrypt(value)
  binaryValue = Base64.encode64(newValue)
  open 'Password', 'w' do |io| io.write binaryValue end
  puts newValue
  return newValue
end

def decryptValue()
  value = File.read('Password')
  # Needed to preserve special characters
  newValue = Base64.decode64(value)
  key = OpenSSL::PKey::RSA.new File.read('public_key.pem')
  newValue1 = key.public_decrypt(newValue)
  puts newValue1
end

def loadKeys()
  loadPrivateKey 'private_key.pem'
  loadPublicKey 'public_key.pem'
end

if __FILE__ == $0
  ARGV.each do|a|
    puts "Argument: #{a}"
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
    loadKeys()
    decryptValue
  end

  if ARGV[0] == "generatekeys"
    generatekeys
  end

end
