source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'

workspace '971town.xcworkspace'
use_frameworks!
inhibit_all_warnings!

project '971town.xcodeproj'
project 'API/API.xcodeproj'

abstract_target '971townApp' do
	# Shared pods go here.
	pod 'KeychainSwift'

	target '971town' do
        	project '971town.xcodeproj'
		
		# Pods for 971town
		pod 'SDWebImage'
	end

	target 'API' do
		project 'API/API.xcodeproj'

		# Pods for API
	end
end
