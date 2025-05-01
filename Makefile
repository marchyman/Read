xcodebuild:
	xcodegen -c
	xcodebuild -scheme Read

clean:
	git clean -fx -e buildServer.json -e Makefile
	# rm -rf Build DerivedData Index.noindex
