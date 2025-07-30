platform :ios, '15.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

target 'PWalletInterfaceSDk' do
    pod 'AFNetworking'
    pod 'FMDB', '~> 2.7.5'
    pod 'YYModel', '~> 1.0.4'
    pod 'YYText', '~> 1.0.7'
    pod 'Masonry', '~> 1.1.0'
    pod 'MBProgressHUD','~> 1.1.0'
    pod 'MJRefresh','~> 3.1.15.7'
    pod 'MJExtension','~> 3.0.15.1'
    pod 'RTRootNavigationController','~> 0.7.0'
    pod 'IQKeyboardManager'
    pod 'pop'
    pod 'ReactiveObjC'
    pod 'WebViewJavascriptBridge'
    pod 'SDWebImage','~>5.0.0'
    pod 'SAMKeychain'
    pod 'BL_IPTool', :git => 'https://github.com/bolee/BL_IPTool.git'
    pod 'YYWebImage'
    #跑马灯
    pod 'JhtMarquee'
    pod 'SDWebImageWebPCoder'
    
    pod 'AlphaWalletWeb3Provider', :git=>'https://github.com/AlphaWallet/AlphaWallet-web3-provider', :commit => 'bdb38b06eeedeb4ca1e32d3ecd81783b5116ae68'
    pod 'AlphaWalletABI', :path => '.'
    pod 'AlphaWalletAddress', :path => '.'
    pod 'AlphaWalletAttestation', :path => '.'
    pod 'AlphaWalletCore', :path => '.'
    pod 'AlphaWalletGoBack', :path => '.'
    pod 'AlphaWalletENS', :path => '.'
    pod 'AlphaWalletHardwareWallet', :path => '.'
    pod 'AlphaWalletLogger', :path => '.'
    pod 'AlphaWalletOpenSea', :path => '.'
    pod 'AlphaWalletFoundation', :path => '.'
    pod 'AlphaWalletTrackAPICalls', :path => '.'
    pod 'AlphaWalletWeb3', :path => '.'
    pod 'AlphaWalletShareExtensionCore', :path => '.'
    pod 'AlphaWalletTrustWalletCoreExtensions', :path => '.'
    pod 'AlphaWalletNotifications', :path => '.'
    pod 'AlphaWalletTokenScript', :path => '.'
    pod 'EthereumABI', :git => 'https://github.com/AlphaWallet/EthereumABI.git', :commit => '877b77e8e7cbc54ab0712d509b74fec21b79d1bb'
    pod 'Kanna', :git => 'https://github.com/tid-kijyun/Kanna.git', :commit => '06a04bc28783ccbb40efba355dee845a024033e8'
    pod 'TrezorCrypto', :git=>'https://github.com/AlphaWallet/trezor-crypto-ios.git', :commit => '50c16ba5527e269bbc838e80aee5bac0fe304cc7'
    pod 'TrustKeystore', :git => 'https://github.com/AlphaWallet/latest-keystore-snapshot', :commit => 'c0bdc4f6ffc117b103e19d17b83109d4f5a0e764'
    pod 'Mixpanel-swift', '~> 3.1'

    
    pod 'JKBigInteger', '~> 0.0.1'
    pod 'MGSwipeTableCell','~> 1.6.7'
    

end

post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
          xcconfig_path = config.base_configuration_reference.real_path
          xcconfig = File.read(xcconfig_path)
          xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
          File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
          end
      end
  end
#post_install do |installer|
#  target.build_configurations.each do |config|
#    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0';
#  end
#end

