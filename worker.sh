#!/usr/bin/env bash
ROOTDIR=`dirname $0`
FLAG=$1
FILE=$2

Src="$ROOTDIR/$FILE/bin/$FILE.dart"
Bin="$ROOTDIR/$FILE/bin/$FILE.aot"
DstMac="$ROOTDIR/build/mac/lib/$FILE.aot"
DstWin="$ROOTDIR/build/win/lib/$FILE.aot"
TmplWinBat="$ROOTDIR/tmpl-win.bat"
DstWinBat="$ROOTDIR/build/win/$FILE.bat"
# ARGS="$@"
case $FLAG in

  '-h' | '--help')
    echo "
 Options:
  -h --help     Show help options
  -r --run      Run the source code
  -b --build    Build for current system
  -e --exec     Execute build on runtime
  -d --deploy   Deploy build for release

 Usages:
  sh worker.sh -h cat
  sh worker.sh -r cat
  sh worker.sh -b cat
  sh worker.sh -e cat
  sh worker.sh -d cat
  "
    ;;

  '-r' | '--run')
    echo "Running ..."
    dart run $Src -v
    ;;

  '-b' | '--build')
    echo "Building ..."
    dart compile aot-snapshot $Src
    ;;

  '-e' | '--exec')
    echo "Executing ..."
    dartaotruntime $Bin -v
    ;;

  '-d' | '--deploy')
    echo "Deploying ..."
    rm $DstMac
    cp $Bin $DstMac
    rm $DstWin
    cp $Bin $DstWin
    rm $DstWinBat
    cp $TmplWinBat $DstWinBat
    aevz "FILENAME" $FILE $DstWinBat
    ;;

  *)
    echo "Missing arguments"
    ;;
esac