use_frameworks!
platform :ios, '8.0'

workspace 'Eureka.xcworkspace'
xcodeproj 'Eureka.xcodeproj'
xcodeproj 'Example.xcodeproj'

def phone_pods
    source 'https://github.com/CocoaPods/Specs.git'
    pod 'PhoneNumberKit', '~> 0.8'
end

target 'Eureka' do
    phone_pods
    xcodeproj 'Eureka.xcodeproj'
end

target 'Example' do
    phone_pods
    xcodeproj 'Example.xcodeproj'
end
