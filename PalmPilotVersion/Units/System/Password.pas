/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Password.h
 *
 * Description:
 *    Password include file
 *
 * History:
 *    4/1/95 - created by Roger Flores
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Password;

interface

Const
  pwdLength= 32;
  pwdEncryptionKeyLength= 64;

Function PwdExists: Boolean; SYS_TRAP(sysTrapPwdExists);
            
Function PwdVerify(Const Str: String): Boolean; SYS_TRAP(sysTrapPwdVerify);

// To remove, use NilStringPtr^ as newPassword;
Procedure PwdSet(Const oldPassword, newPassword: String); SYS_TRAP(sysTrapPwdSet);

Procedure PwdRemove; SYS_TRAP(sysTrapPwdRemove);
            
implementation

end.
