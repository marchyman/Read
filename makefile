PROJECT = Read

buildServer.json:	Build
	xcode-build-server config -scheme "$(PROJECT)" -project *.xcodeproj
	sed -i '~' "/\"build_root\"/s/: \"\(.*\)\"/: \"\1\/DerivedData\/$(PROJECT)\"/" buildServer.json

Build:	$(PROJECT).xcodeproj/project.pbxproj
	xcodebuild -scheme $(PROJECT)

$(PROJECT).xcodeproj/project.pbxproj:	project.yml
	xcodegen -c

# remove files created during the build process
# do **not** use the -d option to git clean as it will blow away .jj files
clean:
	git clean -fx
	rm -rf Build DerivedData $(PROJECT).xcodeproj Index.noindex
