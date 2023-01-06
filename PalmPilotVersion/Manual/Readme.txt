Readme file

New in Build #29, 3-3-2002
o I forgot to include the latest units, like HSSys4, DLServer,..

New in Build #29, 24-2-2002
o ' in comments during skip of $else
o XOR
o allow for const in procedure headers for plain variables like:
  ToggleSwitchButtons(Const eToggleType : SwitchButtonToggles);
o With, using arrays now allowed
o Worked in POSE, but not on real cpu, now fixed:
  "repeat until false;" or "if true then ..."
o FillChar(P^,100,0) works (and so does Move(P^,x,10))
o "var  P: PChar; begin inc(P,4);" now works
o undefined procs will tell in plain text which name is undefined.
o F1 help system, remember to run CompAll.bat first


New in Build #28, 9-1-2002
o Program will expire in Marts 2002
o Fix of string compare

New in Build #27, 10-12-2001
o F1 help. First compile the CompAll pascal source
o New SerialMgr

New in Build #26, 22-11-2001
o Auto-indenting on Enter, except when using Shift-Enter
o Alt-Enter will open file at cursor.
o Drag and Drop of files. 
  And Better than Delphi too, as you can drop links.
o Resources like:
  (ResRaw, 'TEST',1000,'Hello world');  //Include a string
  (ResFile,'MIDI',1000,'Olsen.mid');    //Include a whole file


New in Build #25, 15-11-2001
o Tab and Backspace works uses smart indention
o Tab characters are removed from the file when loading from disk.

Old stuff
hspc.cfg: Config file for initial parameters for hspc.exe, the command line compiler
hspascal.cfg: Config file for the gui version HSPascal.exe

Using this config, the compiler can now be installed somewhere hidden, including the units folder. 
The sources does not need to explain the SearchPaths to the units. 



Please send me what you think about HSPascal, found errors, that I might no know about,...

I need small demo programs. If you like, send me some, including your name (as Shareware Copyright).

Thanks,

Christen Fihl
http://HSPascal.Fihl.net/
