xcodebuild:
	xcodegen -c
	xcodebuild -scheme Read

clean:
	git clean -n -f -e buildServer.json -e Makefile
	# rm -rf Build DerivedData Index.noindex
