default:
	xcodegen -c
	xcodebuild -scheme Read
	buildserver Read

clean:
	git clean -fdx
