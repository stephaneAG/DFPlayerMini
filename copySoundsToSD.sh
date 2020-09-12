#!/usr/bin/env bash

# V0.1a by StephaneAG
# released 13/09/2020

# R: run the following for each card to format it correctly
# 1: sudo diskutil list
# 2: sudo diskutil eraseDisk FAT32 DFPLAYER MBRFormat /dev/disk1
# ( 3: ls -a /Volumes/DFPLAYER )
# 4: ./copySoundsToSD.sh # R: run twice if still invisible stuff ;p

# quick colors
C_RED='\033[0;31m'
C_NC='\033[0m' # No Color
C_Black='\033[0;30m'
C_DarkGray='\033[1;30m'
C_Red='\033[0;31m'
C_LightRed='\033[1;31m'
C_Green='\033[0;32m'
C_LightGreen='\033[1;32m'
C_BrownOrange='\033[0;33m'
C_Yellow='\033[1;33m'
C_Blue='\033[0;34m'
C_LightBlue='\033[1;34m'
C_Purple='\033[0;35m'
C_LightPurple='\033[1;35m'
C_Cyan='\033[0;36m'
C_LightCyan='\033[1;36m'
C_LightGray='\033[0;37m'
C_White='\033[1;37m'

sourceDir="./sounds2/"
sinkDir="/Volumes/DFPLAYER"
# debug passing params
cliSourceDir="$1"
cliSinkDir="$2"

if [ "$cliSourceDir" != "" ] && [ "$cliSinkDir" == "" ] # passing alternative source directory
then
  echo -e "${C_LightGreen}Source directory updated to: $cliSourceDir ${C_NC}"
  sourceDir="${cliSourceDir}"
elif [ "$cliSourceDir" != "" ] && [ "$cliSinkDir" != "" ] # passing alternative source directory
then
  echo -e "${C_LightGreen}Source directory updated to: $cliSourceDir & sink directory to: $cliSinkDir ${C_NC}"
  sourceDir="${cliSourceDir}"
  sinkDir="${cliSinkDir}"
fi
echo -e "Source:${C_Cyan} $sourceDir ${C_NC}\t--->\tSink:${C_Cyan} $sinkDir ${C_NC}"


# check if dir doesn't exist OR exist, & if so, copy files in order to it
if [ ! -d "${sourceDir}" ] || [ ! -d "${sinkDir}" ] # make sure both source & sink dirs exist
then
  if [ ! -d "${sourceDir}" ] && [ ! -d "${sinkDir}" ]
  then
    echo -e "${C_Red}Neither source ( ${sourceDir} ) or sink ( ${sinkDir} ) directories exist.${C_NC}"
  elif [ ! -d "${sourceDir}" ]
  then
    echo -e "${C_Red}Source directory ${sourceDir} doesn't exists.${C_NC}"
  else
    echo -e "${C_Red}Sink directory ${sinkDir} doesn't exists.${C_NC}"
  fi
  exit 9999 # die with error code 9999
else

  echo -e "${C_LightGreen}Initiating copy from ${sourceDir} to ${sinkDir} ..${C_NC}\n"

  # get ref to working dir
  #DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  #echo $DIR

  # clean source dir just in case
  dot_clean "${sourceDir}"

  # copy file to it
  # unfortunately, same/correct order as "find ./sounds/ -maxdepth 1 -name '*.mp3'"
  start=0 # 'll be used as incremental seconds
  # up to [0..39553] filenames ( even if SD /root only supports [0..2999] ;p )
  hh=0
  mm=0
  ss=0
  #start=10 # debug 2-digits check - ok
  for filename in "${sourceDir}/*.mp3"; do # for whatever dir ;p
    echo "copying $filename to SD card .."
    cp $filename "${sinkDir}/" # copy to SD card root
    
    fileAndExt="${filename##*/}"

    # add prefixes if needed for 1-digit numbers
    # seconds
    #tmpSs="$start"
    tmpSs="$ss"
    if [ ${#tmpSs} -eq 1 ]
    then
      tmpSs="0$tmpSs"
    fi
    # minutes
    tmpMm="$mm"
    if [ ${#tmpMm} -eq 1 ]
    then
      tmpMm="0$tmpMm"
    fi
    # hours
    tmpHh="$hh"
    if [ ${#tmpHh} -eq 1 ]
    then
      tmpHh="0$tmpHh"
    fi

    # quick parse proof
    # Nb: since limitation will still apply, better use the 'hacky format' trick above to set minutes & seconds ;p
    echo -e "${C_LightGreen}" "-> prefx:" "${fileAndExt:0:4}" "${C_NC}" # kept as neat logic log

    echo -e "${C_BrownOrange}" "-> start: ${start} timestamp: " "19870604${tmpHh}${tmpMm}.${tmpSs}" "${sinkDir}/$fileAndExt" "${C_NC}" # shall operate at hhmm.ss level - updated for dynamic param
    touch -a -m -t "19870604${tmpHh}${tmpMm}.${tmpSs}" "${sinkDir}/$fileAndExt" # - updated for dynamic param
    SetFile -d "06/04/1987 ${tmpHh}:${tmpMm}:${tmpSs}" "${sinkDir}/$fileAndExt" # - updated for dynamic param

    # during debug - to make sure we are clear
    echo -e "${C_Cyan}" "-> stat1:" $(stat -n "${sinkDir}/$fileAndExt") # - updated for dynamic param
    echo -e "${C_LightPurple}" "-> stat2:" $(stat -n -f %SB "${sinkDir}/$fileAndExt") # - updated for dynamic param
    echo -e "${C_NC}"

    start=$(($start+1)) # simple incremental # kept & displayed in logs

    # --  # formatting for hhmm.ss level --
    if [ ${ss} -eq 58 ]
    then
      ss=0 # reset seconds
      if [ ${mm} -eq 59 ]
      then
        mm=0 # reset minutes - untested, since need way more files ^^
        if [ ${hh} -eq 23 ]
        then
          echo "${C_Red}Maximum supported hours reached :/ ..${C_NC}"
          #hh=0 # reset hours
          # -> onto DD, MM & YY ? -> no need for us, BUT could be done ( & will be cuz it's FUN  ! ) => for now, I keep my b-day fingerprint on those generated timestamps ;P
        else
          hh=$(($hh+1)) # increment hours
        fi
      else
        mm=$(($mm+1)) # increment minutes
      fi
    else
      ss=$(($ss+2)) # /!\ 2-seconds SD FAT32 granularity
    fi

    echo # a little spacer for cli logs
  done

  # clean SD card root just in case
  dot_clean "${sinkDir}"


  # additional steps for 'full' cleanup
  [ -d "${sinkDir}/.Spotlight-V100" ] && rm -r "${sinkDir}/.Spotlight-V100/"
  [ -d "${sinkDir}/.fseventsd" ] && rm -r "${sinkDir}/.fseventsd/"
  [ -d "${sinkDir}/.Trashes" ] && rm -r "${sinkDir}/.Trashes/"

  # quick listing from SD card to make sure everything is ok & cleaned up
  echo "DFPLAYER-ready SD card files: ${start}"
  echo -e "${C_Yellow}"
  ls -a "${sinkDir}"
  echo -e "${C_NC}"

  exit 0 # die witohut errors
fi
