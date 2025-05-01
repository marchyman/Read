xcodebuild:
	xcodegen -c
	xcodebuild -scheme Read

clean:
	git clean -fdx -e buildServer.json -e Makefile
