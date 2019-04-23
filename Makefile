pod_install:
	bundle exec pod install

carthage_install:
	carthage update --platform iOS

provisioning_dev_development:
	bundle exec fastlane match development -a jp.co.neon.nene.dev

provisioning_prod_development:
	bundle exec fastlane match development -a jp.co.neon.nene

provisioning_dev_adhoc:
	bundle exec fastlane match adhoc -a jp.co.neon.nene.dev

provisioning_prod_adhoc:
	bundle exec fastlane match adhoc -a jp.co.neon.nene

provisioning_appstore:
	bundle exec fastlane match appstore -a jp.co.neon.nene

certificates:
	bundle exec fastlane certificates

adhoc:
	bundle exec fastlane adhoc