set abi=armeabi-v7a
del %abi%
md %abi%
if not exist %abi% md %abi%
cd %abi%
%ANDROID_SDK_HOME_CMD%/cmake/3.22.1/bin/cmake ^
  :-Hshadowhook CMakelists所在的目录^
  :-B%abi% generated-ninja-project-folder^
  -DANDROID_ABI=%abi% ^
  -DANDROID_PLATFORM=android-21 ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DANDROID_NDK=%ANDROID_SDK_HOME_CMD%/ndk/23.1.7779620/ ^
  -DCMAKE_TOOLCHAIN_FILE=%ANDROID_SDK_HOME_CMD%/ndk/23.1.7779620/build/cmake/android.toolchain.cmake ^
  -DANDROID_TOOLCHAIN=clang ^
  -DCMAKE_GENERATOR="Ninja" ^
  -DCMAKE_MAKE_PROGRAM=%ANDROID_SDK_HOME_CMD%/cmake/3.22.1/bin/ninja.exe ^
  ../android-inline-hook/shadowhook/src/main/cpp/

ninja

cd ..
