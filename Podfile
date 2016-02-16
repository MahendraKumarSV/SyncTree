#source 'https://github.com/CocoaPods/Specs.git'
#platform :ios, '7.0'
pod 'AFNetworking'
pod 'AsyncImageView'
pod 'Braintree', '~> 3.9.3'
pod 'LatoFont'
pod 'Braintree/Apple-Pay'
pod 'FBSDKCoreKit'
pod 'FBSDKLoginKit'
pod 'FBSDKShareKit'
pod 'HockeySDK'

post_install do |installer|
    installer = installer.respond_to?(:installer) ? installer.installer : installer
    targets = installer.pods_project.targets.select{ |t| t.to_s.end_with? "-Braintree" }
    if (targets.count > 0)
        targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['RUN_CLANG_STATIC_ANALYZER'] = 'YES'
                config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] ||= 'YES'
                config.build_settings['GCC_WARN_ABOUT_MISSING_NEWLINE'] ||= 'YES'
            end
        end
    else
        puts "WARNING: Braintree targets not found"
    end
end
