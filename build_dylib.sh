echo "Copying framework..."
DYLIB_PATH="./layout/Library/Frameworks/"
if [ ! -d "$DYLIB_PATH" ]; then
	mkdir -p ./layout/Library/Frameworks/
fi

DYLIB_SOURCE_PATH="~/Library/Application\ Support/Reveal/RevealServer/iOS/RevealServer.framework"
cp -f -r ${DYLIB_SOURCE_PATH} layout/Library/Frameworks/

echo "##WARNING: resign RevealServer.framework 注意替换自己本地的证书"
# codesign -fs "Apple Development: ljduan2013@icloud.com (992QNX5ZG6)" ./layout/Library/Frameworks/RevealServer.framework
echo "===================================="

echo "Done."
