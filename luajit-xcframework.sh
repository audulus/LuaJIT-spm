
set -e

rm -rf luajit.xcframework
rm -rf luajit
git clone https://github.com/audulus/LuaJIT.git 
cd luajit

mkdir headers
cp src/lua.h headers/
cp src/lauxlib.h headers/
cp src/luaconf.h headers/
cp src/luajit.h headers/
cp src/lualib.h headers/
cp src/lua.hpp headers/

mkdir lib

export MACOSX_DEPLOYMENT_TARGET=11.00

# macOS/x64
ISDKP=$(xcrun --sdk macosx --show-sdk-path)
ICC=$(xcrun --sdk macosx --find clang)
ISDKF="-arch x86_64 -isysroot $ISDKP -mmacosx-version-min=11.0"
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" amalg
mv src/libluajit.a lib/libluajitx86_64.a
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" clean 

# macOS/ARM64
ISDKP=$(xcrun --sdk macosx --show-sdk-path)
ICC=$(xcrun --sdk macosx --find clang)
ISDKF="-arch arm64 -isysroot $ISDKP -mmacosx-version-min=11.0"
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" amalg
mv src/libluajit.a lib/libluajit_macOS_arm64.a
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" clean 

# combine macOS libraries with lipo
lipo -create -output lib/libluajit_macos.a lib/libluajitx86_64.a lib/libluajit_macOS_arm64.a

# iOS/ARM64
ISDKP=$(xcrun --sdk iphoneos --show-sdk-path)
ICC=$(xcrun --sdk iphoneos --find clang)
ISDKF="-arch arm64 -isysroot $ISDKP -miphoneos-version-min=14.0"
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" TARGET_SYS=iOS amalg
mv src/libluajit.a lib/libluajitA64.a
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" TARGET_SYS=iOS clean 

# iOS/x64 simulator
ISDKP=$(xcrun --sdk iphonesimulator --show-sdk-path)
ICC=$(xcrun --sdk iphonesimulator --find clang)
ISDKF="-arch x86_64 -isysroot $ISDKP -mios-simulator-version-min=14.0"
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" TARGET_SYS=iOS amalg
mv src/libluajit.a lib/libluajit_iOS_simulator_x86_64.a
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" TARGET_SYS=iOS clean 

# iOS/ARM64 simulator
ISDKP=$(xcrun --sdk iphonesimulator --show-sdk-path)
ICC=$(xcrun --sdk iphonesimulator --find clang)
ISDKF="-arch arm64 -isysroot $ISDKP -mios-simulator-version-min=14.0"
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" TARGET_SYS=iOS amalg
mv src/libluajit.a lib/libluajit_iOS_simulator_a64.a
make DEFAULT_CC=clang CROSS="$(dirname $ICC)/" \
     TARGET_FLAGS="$ISDKF" TARGET_SYS=iOS clean 

# combine iOS simulator libraries
lipo -create -output lib/libluajit_iOS_simulator.a lib/libluajit_iOS_simulator_x86_64.a lib/libluajit_iOS_simulator_a64.a


echo "Creating xcframework"
xcodebuild -create-xcframework \
           -library lib/libluajit_macos.a \
           -headers headers/ \
           -library lib/libluajitA64.a \
           -headers headers/ \
           -library lib/libluajit_iOS_simulator.a \
           -headers headers/ \
           -output luajit.xcframework

mv luajit.xcframework ..
cd ..
rm -rf luajit
