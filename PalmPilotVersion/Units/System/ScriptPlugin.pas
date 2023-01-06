/******************************************************************************
 *
 * Copyright (c) 1998-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ScriptPlugin.h
 *
 * YOU SHOULD CAREFULLY READ THE TERMS AND CONDITIONS SET FORTH IN THE FILE License.txt BEFORE USING THIS
 * SOFTWARE, THE USE OF WHICH IS LICENSED BY PALM COMPUTING, INC., A SUBSIDIARY OF 3COM CORPORATION 
 * (COLLECTIVELY, "3COM"), FOR USE ONLY AS SET FORTH IN SUCH TERMS AND CONDITIONS.  IF YOU DO NOT AGREE 
 * TO SUCH TERMS AND CONDITIONS,  DO NOT USE THE SOFTWARE.  USING ANY PART OF THE SOFTWARE INDICATES THAT 
 * YOU ACCEPT SUCH TERMS.
 *
 * Description:
 *    Include file for script plugin modules of the Network Pref Panel
 *    and the Net library. Note that you need to include the file
 *    <systemMgr.h> in your plugin before this file.
 *
 * History:
 *    WK  6/10/98    Created 
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit ScriptPlugin;

interface

Uses SystemMgr;

// Plugin Launch command codes
//
Type
  ScriptPluginLaunchCodesEnum = (
    scptLaunchCmdDoNothing = sysAppLaunchCmdCustomBase,
    scptLaunchCmdListCmds,
    scptLaunchCmdExecuteCmd
  );

// Commands for the callback selector function
//
Const
  pluginNetLibDoNothing             =0; // For debug purposes.
  pluginNetLibReadBytes             =1; // Receive X number of bytes.
  pluginNetLibWriteBytes            =2; // Send X number of bytes.
  pluginNetLibGetUserName           =3; // Get the user name from the service profile.
  pluginNetLibGetUserPwd            =4; // Get the user password from the service profile.
  pluginNetLibCheckCancelStatus     =5; // Check the user cancel status.
  pluginNetLibPromptUser            =6; // Prompt the user for data and collect it.
  pluginNetLibConnLog               =7; // Write to the connection log.
  pluginNetLibCallUIProc            =8; // Call the plugin's UI function.
  pluginNetLibGetSerLibRefNum       =9; // Get the Serial library reference number.

// Plugin constants
//
  pluginMaxCmdNameLen               =15;
  pluginMaxModuleNameLen            =15;
  pluginMaxNumOfCmds                =10;
  pluginMaxLenTxtStringArg          =63;


Type
  PluginCmdPtr = ^PluginCmdType;
  PluginCmdType = record
    commandName: String[pluginMaxCmdNameLen];
    hasTxtStringArg: Boolean;    
    reserved: UInt8;                   // explicitly account for 16-bit alignment padding
  end;


  PluginInfoPtr = ^PluginInfoType;
  PluginInfoType = Record
    pluginName: String[pluginMaxModuleNameLen];
    numOfCommands: UInt16;
    command: array[0..pluginMaxNumOfCmds-1] of PluginCmdType;
  end;


  // Plugin Execute structures

  //Err (*ScriptPluginSelectorProcPtr) (void *handle, UInt16 command, void *dataBufferP,
  //                                 UInt16 *sizeP, UInt16 *dataTimeoutP, void *procAddrP);
  ScriptPluginSelectorProcPtr = Pointer;

  PluginCallbackProcPtr = ^PluginCallbackProcType;
  PluginCallbackProcType = Record
     selectorProcP: ScriptPluginSelectorProcPtr;
  end;

  PluginExecCmdPtr = ^PluginExecCmdType;
  PluginExecCmdType = Record
    commandName: String[pluginMaxCmdNameLen];
    txtStringArg: String[pluginMaxLenTxtStringArg];
    procP: PluginCallbackProcPtr;
    handle: Pointer;
  end;

implementation

end.

