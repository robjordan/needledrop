#!/bin/bash
# ------------------------------------------------------------------
# [Rob Jordan] needledrop.sh
#          post-process recordings from turntable, with speed
#          adjustment and rumble reduction
# ------------------------------------------------------------------
VERSION=0.1.0
USAGE="Usage: needledrop.sh -s speedadjustment inputfile"
SPEEDADJ=1.0264
SIDEHP=150
MIDHP=20

# set -x

# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
    echo $USAGE
    exit 1;
fi

while getopts ":s:vh" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "s")
          echo "-s argument: $OPTARG"
	  SPEEDADJ=$OPTARG
        ;;
      "h")
        echo $USAGE
        exit 0;
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

shift $(($OPTIND - 1))

infile=$1
f45=${infile%.*}-45rpm.wav
fmid=${infile%.*}-45rpm-mid.wav
fmidhp=${infile%.*}-45rpm-mid-hp.wav
fside=${infile%.*}-45rpm-side.wav
fsidehp=${infile%.*}-45rpm-side-hp.wav
fmidsidehp=${infile%.*}-45rpm-midside-hp.wav
fout=${infile%.*}-45rpm-hp.flac


# --- Body --------------------------------------------------------
#  SCRIPT LOGIC GOES HERE
# set -x
echo "Processing " $infile

echo "Adjusting speed..."
sox --multi-threaded $infile $f45 speed $SPEEDADJ

echo "Splitting mid-side channels..."
sox $f45 $fmid remix 1,2
sox $f45 $fside remix 1v0.5,2v-0.5

echo "High-pass filter mid..."
sox --multi-threaded $fmid $fmidhp sinc -L $MIDHP -n 32767 reverse sinc -L $MIDHP -n 32767 reverse

echo "High-pass filter side..."
sox --multi-threaded $fside $fsidehp sinc -L $SIDEHP -n 32767 reverse sinc -L $SIDEHP -n 32767 reverse

echo "Recombining mid-size to LR..."
sox -M $fmidhp $fsidehp $fmidsidehp
sox $fmidsidehp $fout remix -m 1,2 1,2i

echo "Complete"
# -----------------------------------------------------------------
