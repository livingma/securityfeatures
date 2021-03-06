require 'openssl'
require 'base64'
require 'optparse'
require 'fileutils'
require 'yaml'


class EncryptData
  $publicKey=""
  $privateKey=""
  $publicKeyFileName=""
  $privateKeyFileName=""
  $center=nil
  $application=nil
  $currentdirectory= File.expand_path(File.dirname(__FILE__))
  $settings_file = $currentdirectory + "/encrypt.properties"
    
  
  def generatekeys(*items)
    $center = items[0]
    $application = items[1]
    key = OpenSSL::PKey::RSA.new(2048)
    _getKeynames($currentdirectory)
    # make directories if they do not exist
    if not File.exists?($currentdirectory + "/#{$center}/#{$application}")
      FileUtils::mkdir_p $currentdirectory + "/#{$center}/#{$application}"
      puts "Created directory #{$currentdirectory} /#{$center}/#{$application}"
    end

    # change directory to where ruby file exists
    Dir.chdir $currentdirectory + "/#{$center}/#{$application}"
    createkeys(key)
  end
  
  def initialize(filename)
#    if items.nil?
#      abort "initializing failed"
#    else
#      puts "%%%%#{items[0]}"
#      puts "yo"
#      puts "me#{items.length.to_s}"
#    end
    puts "%%%%#{filename}"
    $settings_file = filename
    loadProperties()
  end
  
  def set_settingsFilePath(filename)
    $settings_file = filename
    loadProperties()
  end

  def generatekeys_alt(center,application)
    key = OpenSSL::PKey::RSA.new(2048)
    $center = center
    $application = application

    _getKeynames($currentdirectory)
    # make directories if they do not exist
    if not File.exists?($currentdirectory + "/#{$center}/#{$application}")
      FileUtils::mkdir_p $currentdirectory + "/#{$center}/#{$application}"
      puts "Created directory #{$center}/#{$application}"
    end

    # change directory to where ruby file exists
    Dir.chdir $currentdirectory + "/#{$center}/#{$application}"
    createkeys(key)
  end

  def createkeys(key)
    if not File.exists?($privateKeyFileName)
      open $privateKeyFileName, 'w' do |io| io.write key.to_pem end
      puts "Public Key #{$publicKeyFileName} was generated"
    else
      puts "Private Key #{$privateKeyFileName} already exists"
    end
    if not File.exists?($publicKeyFileName)
      open $publicKeyFileName, 'w' do |io| io.write key.public_key.to_pem end
      puts "Public Key #{$publicKeyFileName} was generated"
    else
      puts "Public Key #{$publicKeyFileName} already exists"
    end

  end

  def _setPublicKeyName(path,center,application)
    _publickey = path + "/#{$center}/#{$application}/public_" + center + "_" + application + "_key.pem"
    return _publickey
  end

  def _setPrivateKeyName(path,center,application)
    _privatekey = path + "/#{$center}/#{$application}/private_" + center + "_" + application + "_key.pem"
    return _privatekey
  end

  def _getKeynames(rootpath)
    if $center.nil? || $application.nil? then
      puts "Specify the center name?"
      STDOUT.flush
      $center = STDIN.gets.chomp
      puts "Specify the application name?"
      $application = STDIN.gets.chomp
    end
    $publicKeyFileName = _setPublicKeyName(rootpath,$center,$application)
    $privateKeyFileName = _setPrivateKeyName(rootpath,$center,$application)
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
      return 1
    end
  end

  def checkarguments(num, command)
    unless ARGV.length == num
      puts "Wrong number of arguments."
      puts "Usage: ruby autodeploymentAPI.rb %{command} <value>\n"
      exit
    end
  end

  def encryptValue(*items)
    if items.length > 0      
      value = items[0]
      $center = items[1]
      $application = items[2]      
    end
    loadKeys()
    encrypted = $publicKey.public_encrypt(value)
    encoded = Base64.strict_encode64(encrypted)
    puts "Encoded Value: \n" + encoded; puts
    return encoded
  end

  def decryptValue(*items)
    if items.length > 0
      value = items[0]
      $center = items[1]
      $application = items[2]
    end
    loadKeys()
    begin
      # Needed to preserve special characters
      decoded = Base64.decode64(value)
      decrypted = $privateKey.private_decrypt(decoded)
      puts "Decrypted Value: " + decrypted
    rescue => error
      puts "Permission Denied; decrypting is not allowed"
    end
    return decrypted
  end

  def init_args()
    if $center.nil? && $application.nil?
      if ARGV[0] == "generatekeys"
        $center = ARGV[1]
        $application = ARGV[2]
      else
        $center = ARGV[2]
        $application = ARGV[3]
      end
    end
  end
  
  def loadKeys()
    # set this to get center and application global variables
    init_args()
    _getKeynames($currentdirectory)
    loadPrivateKey $privateKeyFileName
    loadPublicKey $publicKeyFileName
  end

  def loadProperties()

    test = open($settings_file).read
    fileH = YAML.load(test)
    fileH.keys.each do |section|
      begin
        key_path = fileH[section]['KEY_PATH'].strip.downcase
        if !key_path.nil?
          $currentdirectory = key_path
          if !Dir.exists?($currentdirectory)
            #puts; puts "The Root directory for Key Path does not exist. Check properties file"
            return 1
          end
        end
      rescue => error
        puts; puts "Warning KEY_PATH property not defined in #{$settings_file}; using current directory"; puts
      end

    end

  end

  if __FILE__ == $0

    puppetUser = EncryptData.new '/Users/Mark/workspace/rubyTest/encrypt.properties'
    if puppetUser.loadProperties() == 1
      abort "The Root directory for Key Path does not exist. Check properties file"
    end

    ARGV.each do|a|
      puts "Argument: #{a}"
    end

    if ARGV[0] == nil
      puts "*****Welcome to the Automated Deployment Encryption Tools*****"; puts
      puts "This tools will prompt the user for the center and application name."; puts
      puts " Generate Keys - this is a one time only command that will generate public and private keys.\n"
      puts " This functionality has two commands, the _alt version allows you to pass arguments while bypassing prompts.\n"
      puts "   Usage: ruby autodeploymentAPI.rb generatekeys"      
      puts " Encrypt Data - you pass a string argument and it encrypt it then encodes the value then dumps it to the screen.\n For example, if it is a password simply copy the output to the LST/CFG for the value of that property."
      puts "   Usage: ruby autodeploymentAPI.rb encrypt <stringValue>"; puts
      puts " Decrypt Data - you pass a string argument representing the encrypted, encoded value and it will decode and decrypt it giving you the original password."
      puts "   Usage: ruby autodeploymentAPI.rb decrypt <stringValue>"; puts
      puts; puts "Current Key Path directory => #{$currentdirectory}"; puts;
      puts; puts "Setting file => #{$settings_file}"; puts
    end

    if ARGV[0] == "encrypt"
      if ARGV[1].nil?
        puts "An argument for the value to be encrypted is needed"
      else
        #puppetUser.loadKeys()
        puppetUser.encryptValue ARGV[1]
      end
    end

    if ARGV[0] == "decrypt"
      if ARGV[1].nil?
        puts "An argument for the value to be decrypted is needed"
      else
        #puppetUser.loadKeys()
        puppetUser.decryptValue ARGV[1]
      end
    end

    if ARGV[0] == "generatekeys"
      # set this to get center and application global variables
      puppetUser.init_args()
      puppetUser.generatekeys()
    end

#    if ARGV[0] == "generatekeys_alt"
#      puppetUser.checkarguments 3,"generatekeys_overloaded"
#      puppetUser.generatekeys_alt ARGV[1], ARGV[2]
#    end

  end
end