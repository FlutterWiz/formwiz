clean:
	flutter clean
	flutter pub get

build_runner:
	dart run build_runner build --delete-conflicting-outputs