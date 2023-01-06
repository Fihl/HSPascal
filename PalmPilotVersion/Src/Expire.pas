if TimeLimited then
  //REMEMBER TO CHANGE: Global.pas 
  if Now>=EncodeDate(2002, 11, 1) then begin
    {$ifdef VersionUI}
    MessageDlg('Trial periode for HSPascal test version has expired'#13+
               'Please visit http://HSPascal.Fihl.net', mtWarning, [mbOk],0);
    //Application.Terminate;
    Raise Exception.Create('HSPascal trial periode has expired');
    {$else}
    Writeln('Trial periode for HSPascal test version has expired');
    Writeln('Please visit http://HSPascal.fihl.net');
    Halt;
    {$endif}
  end;

