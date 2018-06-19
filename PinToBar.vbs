'Pin an application to a start menu or task bar
If WScript.Arguments.Count = 4 then
	Call PinApplicationToTaskBar(WScript.Arguments(0), WScript.Arguments(1), WScript.Arguments(2), WScript.Arguments(3))
Else
	WScript.Echo "Missing parameters.  String AppPathAndName String ShortcutName Boolean OnStartMenu." & vbCr & vbCr & "  Example cmd.exe CMD  false " & vbCr & vbCr & "  Example %windir%\system32\SnippingTool.exe SnipIt false " & chr(34) &  " "  & chr(34) 
End If
	
Public Sub PinApplicationToTaskBar(AppPathAndName, ShortcutName, OnStartMenu, Arguments)
	'This is on for a soft failure. Uncomment this if error checking for a hard failure is needed for debugging.
	On Error Resume Next

	Dim FileSystemObj, ObjShell, ObjShellApp
	Set ObjShell = WScript.CreateObject("WScript.Shell")
	Set FileSystemObj = CreateObject("Scripting.FileSystemObject")
	
	'Create a temp location for the short-cut to exist
	TempShortcutLocation = FileSystemObj.GetFolder(ObjShell.ExpandEnvironmentStrings("%TEMP%"))
	'Where is it being pinned too?  Determine the location where the pinned item will reside.
	If(trim(lcase(OnStartMenu)) = "true") then ' pinned to start menu
		HasItAlreadyBeenPinnedShortCut = ObjShell.ExpandEnvironmentStrings("%APPDATA%") & "\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu"
	Else
		HasItAlreadyBeenPinnedShortCut = ObjShell.ExpandEnvironmentStrings("%APPDATA%") & "\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
	End If
	'Temporary location for the application short-cut
	TempShortcut = TempShortcutLocation & "\" & ShortcutName & ".lnk"
	'Possible location of a pinned item
	HasItAlreadyBeenPinnedShortCut =  HasItAlreadyBeenPinnedShortCut & "\" & ShortcutName & ".lnk"
	'If this already exists, than exit this procedure. The application has already been pinned.
	If(FileSystemObj.FileExists(HasItAlreadyBeenPinnedShortCut)) Then
		'MsgBox(HasItAlreadyBeenPinnedShortCut & " Already Pinned")
		Set ObjShell = Nothing
		Set FileSystemObj = Nothing
		Exit Sub
	End If
	'Create a short-cut using the shell
	Set lnk = ObjShell.CreateShortcut(TempShortcut)
	lnk.TargetPath = AppPathAndName ' Full application path and name
	lnk.Arguments = Arguments 'Arguments wanted for url
	lnk.Description = ShortcutName 'The name that appears on the start menu.
	lnk.Save 
	
	Set ObjShellApp = CreateObject("Shell.Application")
		
	'Get the newly created short-cut full path
	Set ShortCutToPin =  ObjShellApp.NameSpace(TempShortcutLocation) 
			
	If(FileSystemObj.FileExists(TempShortcut)) Then 
		Dim ShortCutToPinItem, verb
		'Set the location to pin the item to do based on the passed OnStartMenu argument
		If(trim(lcase(OnStartMenu)) = "true") then
			verbToDo = "Pin to Start Men&u"
		Else	
			verbToDo = "Pin to Tas&kbar"
		End If
		For Each ShortCutToPinItem in ShortCutToPin.Items()
			'Look for the pinning verb when the temporary short-cut name matches the passed ShortcutName argument
			If (ShortCutToPinItem.Name = ShortcutName) Then
				'Loop through the shell object's (the short-cut) commands looking for the pinning method.
				For Each verb in ShortCutToPinItem.Verbs 
					'The verb matches the verbToDo so pin it to verb's defined location
					If (verb.Name = verbToDo) Then verb.DoIt
				Next
			End If
		Next
		'Delete the temporary short-cut used to pin the application
		FileSystemObj.DeleteFile(TempShortcut) 
	End If
	'clean up
	Set ObjShell =  Nothing
	Set FileSystemObj = Nothing
	Set ObjShellApp = Nothing
End Sub


	

	