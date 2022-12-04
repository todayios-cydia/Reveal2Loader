echo "Copying framework..."
DYLIB_PATH=./RevealLoaderPrefs/layout/Library/Application\ Support
if [ ! -d "$DYLIB_PATH" ]; then
	mkdir -p $DYLIB_PATH
	echo '创建DYLIB_PATH'
fi

echo "##WARNING: resign RevealServer.framework 注意替换自己本地的证书"
codesign -fs "Apple Development: Qianduan Da (4V52F2MX45)" "$DYLIB_PATH"/RevealServer.framework
echo "===================================="

echo "Done."
