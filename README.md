# DFPlayerMini
Repo dedicated to cheap little SD card player with embedded memory

Aside from the following links ( with infos related to the DFPLayerMini itself or to stuff digged while writing the tool / helpful reminders ), a tool ( bash script ) is hosted on this repo ( 'copySoundsToSD.sh' ).

Its only goal is to 'hack' the files's creation timestamp ( as well as last access & last edit, just to set things straight ) so that the order in which they appear to the DFPLayerMini is the same as their alphanumerical one ( 0001a.mp3- >0001b.mp3 -> 0002a.mp3 -> .. ).

When not able to ( or when it's not desired to ) set a specific playback* mode on the DFPLayerMini while keeping files at the root of the SD card, the said hack hence allows to keep the desired order for file playback.

* For the playback mode part: I'm currently using a library ( the only one that worked without too much glitching so far ) that send hex's for control commands not found in the docs I could find, one of the reason why I wrote this tool ( aside from that "well, let's investigate <inset behavior to study> that !" inner talk ;p )

#### uC-side
I currently use the "DFPlayer Mini Mp2 by Makuna" ( thx ! ) to drive the DFPLayer using an Arduino Micro Pro & had troubles with the following fcn ( which seem to use an incorrect hex for the control command ? )
( R: issue generated at https://github.com/Makuna/DFMiniMp3/issues/57 )

Nb: I've read https://github.com/Makuna/DFMiniMp3/wiki/API-Reference, still no yet yet sure why it does so / which manual/doc as thoses hex's from
```
void loopGlobalTrack(uint16_t globalTrack)
    {
        sendPacket(0x08, globalTrack);
    }
```

#### the little tool ( bash sript )

- 2 cli params: 1st is to specify an alternative 'source' directory, 2nd to specify an alternative 'sink' directory as well
- 'source' directory defautls to one named 'sounds' in the tool's working directory ( the one from which the tool is run )
- 'sink' directory defautls to /Volumes/DFPlayer ( since it's how I name SD cards to be used for those breakouts )
- will also do cleanups for dot files & other OS-related junk

#### before I forget & correct me if I'm wrong ( please ! ^^ )

- maximum number of files at root of SD for DFPLayerMini: 2999 ( R => digg where I read this & if I'm not not / why I think I read this somewhere .. or did I wrote it ? .. => from the manual ;p )
- SD FAT32 date format & time format are both 16 bits ( see below tables as reminders extracted from the docs )
- yes, the way the tools achieve its goal is rather hacky ( knowing about the SD spec doc tables & the bits occupied, we could have written a tool to operate on the 'resulting' bits level, here it's just focused on getting ' alphanumerical-ordered timestamps' for thr DFPlayer to be happy )
- maximum number of different creation timestamps using the 'timestamp formatting hack' used by the tool: ( 23 hh * 59 mm * 29 .ss ) = 39 353
- maximum number of different creation timestamps pushing the 'timestamp formatting hack' to its limit: ( 127 yyy * 12 MM * 21 DD * 23 hh * 59 mm * 29 .ss ) = 1 859 193 132
- the above maxi is different from the 32 bits limit ? ( which is 4 294 967 295 -> even if I do 128*12*31*24*60*30 = 2 057 011 200 )
- why does timestamps seconds changes between what I set ( using 'touch' ) between my OS FS & an SD card's FS ?: it may 'granularity' of the format ( ex: FAT32 ) timestamps ( ex: 2 seconds granularity for FAT32 )
- when using 'cp', file creation, last edit & last access are all set to the time of copy by default
- 'cp -p' seemed not able to set creation time ( for me at least )
- 'SetFile -d' did indeed: joy :)

#### the links ( kudos to the authors ! ;p )
- not yet digged through thoroughiously https://github.com/Schallbert/DFplayer_AutoStructureFromPlaylist
- https://www.developerfiles.com/how-to-change-the-creation-date-of-a-file-in-os-x/
- https://hackernoon.com/how-to-change-a-file-s-last-modified-and-creation-dates-on-mac-os-x-494f8f76cdf4
- p42/136 http://read.pudn.com/downloads188/ebook/881633/SD%203.0/Part_2_File_System_Specification_V3.00_Final_090416.pdf
- http://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
- https://ss64.com/osx/stat.html
- https://reprage.com/post/dfplayer-mini-cheat-sheet
- other way around, getting order from, not setting it https://hackaday.io/project/35165-sda-the-best-new-pda/log/152891-hacking-the-df-player-mini
- audio clip finished https://forum.arduino.cc/index.php?topic=531918.0
- manual ( ctrl cmds on p3/12 ) http://www.electronicoscaldas.com/datasheet/DFR0299-DFPlayer-Mini-Manual.pdf
- https://arduino.stackexchange.com/questions/49807/dfplayer-noise-researched-tried-and-bep-bep-bep-bep-bep
- https://www.instructables.com/id/Tutorial-of-MP3-TF-16P/
- https://www.dfrobot.com/forum/viewtopic.php?t=2698
- https://wiki.dfrobot.com/DFPlayer_Mini_SKU_DFR0299#Sample_Code
