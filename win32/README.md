# build OpenSSL on windows

According to OpenSSL Notes for Windows platforms, build OpenSSL on win32 follows:

1. Install Visual Studio with 2015 v140xp toolset
2. Install Perl from https://strawberryperl.com/ (tested with `strawberry-perl-5.32.1.1-64bit.msi`)
3. Install NASM from https://www.nasm.us/ (tested with `nasm-2.16.01-installer-x64.exe`)
4. Add nasm installed location to user environment `PATH`
5. Open terminal with "x86 Native Tools Command Prompt for VS 20XX" (vcvars32)
5. extract OpenSSL (tested with 3.0.8) and cd into it
6. perl Configure threads no-shared --prefix=`pwd`\..\builds --openssldir=`pwd`\..\builds
7. nmake
8. nmake test
9. nmake install
