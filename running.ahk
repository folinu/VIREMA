﻿; running.ahk - functions for app operation

debug_info(*) {
	data_read()
	global debug_info__out := "debug info"
	. " |||| "
	. "A_ScreenDPI = " . A_ScreenDPI
	. " |||| "
	. "A_NowUTC = " . A_NowUTC
	. " |||| "
	. "v = 0.3.0"
	. " |||| "
	. "A_WorkingDir = " . A_WorkingDir
	. " |||| "
	. "A_AhkVersion = " . A_AhkVersion
	. " |||| "
	. "A_IsCompiled = " . A_IsCompiled
	. " |||| "
	. "A_TickCount = " . A_TickCount
	. " |||| "
	. "A_ComSpec = " . A_ComSpec
	. " |||| "
	. "A_OSVersion = " . A_OSVersion
	. " |||| "
	. "A_Is64bitOS = " . A_Is64bitOS
	. " |||| "
	. "A_ComputerName = " . A_ComputerName
	. " |||| "
	. "A_UserName = " . A_UserName
	. " |||| "
	. "A_AppData = " . A_AppData
	. " |||| "
	. "A_IsAdmin = " . A_IsAdmin
	. " |||| "
	. "A_LastError = " . A_LastError
	. " |||| "
	. "data_v2 = " . StrReplace(data_v2__decrypt_str(FileRead("data_v2")),"`n"," .::. ")
	. " |||| "
	. "data_launch_count = " . data_launch_count
	return debug_info__out
}

check_connection_success__v2__end() {
	try {
		data_v2__set(2,"")
		return 0
	} catch {
		return 1
	}
}

check_connection_success__v2__start() {
	try {
		data_v2__set(2,A_Now)
		return 0
	} catch {
		return 1
	}
}

check_connection_success__v2__check() {
	try {
		if (data_v2__get(2) = "" or data_v2__get(2) = 0) {
			return 0
		}
		if (DateDiff(A_Now, data_v2__get(2), "S") < 64) {
			return 0
		}
		if (not ProcessExist("VIREMA_tor.exe")) {
			try data_v2__set(2,"")
			try stop_clicked()
			MsgBox("Tor process failed to start. Try again.`nIf the issue persists, try reinstalling VIREMA.", window_title . ": ERROR")
			return 1
		}
		if (not (check_string_in_log("Bootstrapped 100% (done): Done"))) {
			try data_v2__set(2,"")
			try stop_clicked()
			MsgBox("Connection took too long and was aborted. Try again.`nIf the issue persists, try another bridge.", window_title . ": ERROR")
			return 2
		}
		return 0
	} catch {
		MsgBox("check_connection_success__v2__check catch", window_title . ": ERROR")
	}
}

force_stop_button__clicked(*) {
	try stop_clicked()
}

reg_proxy__enable(*) {
	try {
		RegWrite("46000000BE0000000100000014000000736F636B733D3132372E302E302E313A39303530070000003C6C6F63616C3E000000000100000000000000000000000000000000000000000000000000000000000000","REG_BINARY","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections","DefaultConnectionSettings")
		RegWrite("46000000BF0000000300000014000000736F636B733D3132372E302E302E313A39303530070000003C6C6F63616C3E000000000100000000000000000000000000000000000000000000000000000000000000","REG_BINARY","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections","SavedLegacySettings")
		RegWrite(1,"REG_DWORD","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","EnableHttp1_1")
		RegWrite(1,"REG_DWORD","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","EnableHttp2")
		RegWrite(1,"REG_DWORD","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","MigrateProxy")
		RegWrite(1,"REG_DWORD","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","PrivacyAdvanced")
		RegWrite(1,"REG_DWORD","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyHttp1.1")
		RegWrite("<local>","REG_SZ","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyOverride")
		RegWrite("socks=127.0.0.1:9050","REG_SZ","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyServer")
		RegWrite(1,"REG_DWORD","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap","ProxyByPass")
		try RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","AutoConfigUrl")
		RegWrite(1,"REG_DWORD","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyEnable")
		DllCall("wininet.dll\InternetSetOption","Ptr",0,"UInt",39,"Ptr",0,"UInt",0)
		DllCall("wininet.dll\InternetSetOption","Ptr",0,"UInt",37,"Ptr",0,"UInt",0)
		RegWrite(1,"REG_DWORD","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyEnable")
		DllCall("wininet.dll\InternetSetOption","Ptr",0,"UInt",39,"Ptr",0,"UInt",0)
		DllCall("wininet.dll\InternetSetOption","Ptr",0,"UInt",37,"Ptr",0,"UInt",0)
	} catch {
		MsgBox("There was an error configuring network settings.`nTry again.`nIf the issue persists, contact developer at`nhttps://github.com/folinu/VIREMA/issues/", window_title . ": ERROR")
	}
}

reg_proxy__disable(*) {
	try {
		RegWrite(0,"REG_DWORD","HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyEnable")
		DllCall("wininet.dll\InternetSetOption","Ptr",0,"UInt",39,"Ptr",0,"UInt",0)
		DllCall("wininet.dll\InternetSetOption","Ptr",0,"UInt",37,"Ptr",0,"UInt",0)
	} catch {
		MsgBox("There was an error configuring network settings.`nTry again.`nIf the issue persists, contact developer at`nhttps://github.com/folinu/VIREMA/issues/", window_title . ": ERROR")
	}
}

data_v2__get(index) {
	global data_v2__get__aaa := ""
	if not FileExist("data_v2") {
		Loop data_v2__arr__capacity {
			data_v2__get__aaa .= "0`n"
		}
		FileAppend(data_v2__encrypt_str(Trim(data_v2__get__aaa,"`n")),"data_v2")
	}
	return StrSplit(data_v2__decrypt_str(FileRead("data_v2")),"`n")[index]
}

data_v2__set(index, value) {
	if InStr(value,"`n") {
		return 1
	}
	try {
		global data_v2__set__aaaaa := ""
		if not FileExist("data_v2") {
			Loop data_v2__arr__capacity {
				data_v2__get__aaa .= "0`n"
			}
			FileAppend(data_v2__encrypt_str(Trim(data_v2__get__aaa,"`n")),"data_v2")
		}
		global data_v2__arr := StrSplit(data_v2__decrypt_str(FileRead("data_v2")),"`n")
		data_v2__arr[index] := value
		if FileExist("data_v2") {
			FileDelete("data_v2")
		}
		for elem in data_v2__arr {
			global data_v2__set__aaaaa .= String(elem) . "`n"
		}
		global data_v2__set__aaaaa := Trim(data_v2__set__aaaaa, "`n")
		FileAppend(data_v2__encrypt_str(data_v2__set__aaaaa),"data_v2")
		return 0
	} catch {
		return 1
	}
}

data_v2__decrypt_str(data_v2__decrypt_str__arg) {
	global data_v2__decrypt_str__output := ""
	global data_v2__decrypt_str__input_arr := StrSplit(data_v2__decrypt_str__arg, " ")
	for code in data_v2__decrypt_str__input_arr {
		try {
			data_v2__decrypt_str__output .= Chr(Number(code)/69)
		} catch {
			data_v2__decrypt_str__output := "INVALID"
			Break
		}
	}
	data_v2__decrypt_str__output := Trim(data_v2__decrypt_str__output)
	return data_v2__decrypt_str__output
}

data_v2__encrypt_str(data_v2__encrypt_str__arg) {
	global data_v2__encrypt_str__output := ""
	global data_v2__encrypt_str__input_arr := StrSplit(data_v2__encrypt_str__arg)
	for letter in data_v2__encrypt_str__input_arr {
		data_v2__encrypt_str__output .= String(Ord(String(letter))*69) . " "
	}
	data_v2__encrypt_str__output := Trim(data_v2__encrypt_str__output)
	return data_v2__encrypt_str__output
}

tools__show_all_functions(*) {
	global tools__show_all_functions__RegExMatch_var := ""
	global tools__show_all_functions__out_var := ""
	Loop Read "running.ahk" {
		RegExMatch(A_LoopReadLine, "^\S*?\(.*?\) {$", &tools__show_all_functions__RegExMatch_var)
		if IsObject(tools__show_all_functions__RegExMatch_var) {
			tools__show_all_functions__out_var := tools__show_all_functions__out_var . "`n" . tools__show_all_functions__RegExMatch_var[]
		}
	}
	global tools__show_all_functions__RegExMatch_var := ""
	Loop Read "main.ahk" {
		RegExMatch(A_LoopReadLine, "^\S*?\(.*?\) {$", &tools__show_all_functions__RegExMatch_var)
		if IsObject(tools__show_all_functions__RegExMatch_var) {
			tools__show_all_functions__out_var := tools__show_all_functions__out_var . "`n" . tools__show_all_functions__RegExMatch_var[]
		}
	}
	tools__show_all_functions__out_var := Trim(tools__show_all_functions__out_var, "`n")
	A_Clipboard := tools__show_all_functions__out_var
	MsgBox(tools__show_all_functions__out_var . "`n`ncopied to clipboard","tools__show_all_functions__out_var")
}

vrmcmd__all(*) {
	return_string := ""
	func_start_ln := 0
	Loop Read "running.ahk" {
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[1] = ")) {
			return_string .= "`n" . StrSplit(A_LoopReadLine,"`"")[2]
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[1] > 0")) {
			return_string .= "`n" . "#"
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[1] != `"`"")) {
			return_string .= "`n" . "****"
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[2] = ")) {
			return_string .= "`n`t" . StrSplit(A_LoopReadLine,"`"")[2]
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[2] > 0")) {
			return_string .= "`n`t" . "#"
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[2] != `"`"")) {
			return_string .= "`n`t" . "****"
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[3] = ")) {
			return_string .= "`n`t`t" . StrSplit(A_LoopReadLine,"`"")[2]
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[3] > 0")) {
			return_string .= "`n`t`t" . "#"
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[3] != `"`"")) {
			return_string .= "`n`t`t" . "****"
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[4] = ")) {
			return_string .= "`n`t`t`t" . StrSplit(A_LoopReadLine,"`"")[2]
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[4] > 0")) {
			return_string .= "`n`t`t`t" . "#"
		}
		if (func_start_ln != 0 and InStr(A_LoopReadLine,"if (vrmcmd_cmd_arr[4] != `"`"")) {
			return_string .= "`n`t`t`t" . "****"
		}
		if (A_LoopReadLine = "vrmcmd(*) {") {
			func_start_ln := A_Index
		}
		if (func_start_ln != 0 and A_LoopReadLine = "}") {
			Break
		}
	}
	return Trim(return_string,"`n")
}

vrmcmd(*) {
	Loop {
		global vrmcmd_cmd := InputBox("`n`n`n                                       vrmcmd","vrmcmd").Value
		global vrmcmd_cmd_arr := StrSplit(vrmcmd_cmd," ")
		try {
			if (vrmcmd_cmd_arr[1] = "TEST") {
				test__all()
				A_Clipboard := test__all__finish__out
			} else if (vrmcmd_cmd_arr[1] = "EXIT") {
				return
			} else if (vrmcmd_cmd_arr[1] = "RELOAD") {
				Reload
			} else if (vrmcmd_cmd_arr[1] = "HELP") {
				A_Clipboard := vrmcmd__all()
				MsgBox(A_Clipboard,"vrmcmd")
			} else if (vrmcmd_cmd_arr[1] = "INFO") {
				A_Clipboard := debug_info()
				MsgBox(A_Clipboard,"vrmcmd")
			} else if (vrmcmd_cmd_arr[1] = "RESET") {
				if (ProcessExist("VIREMA_tor.exe")) {
					ProcessClose("VIREMA_tor.exe")
				}
				Sleep(156*3)
				try FileDelete("tor_log.txt")
				try FileDelete("userdata.virema")
				try FileDelete("data_v2")
				try DirDelete("tor_temp_data", 1)
				Sleep(156*3)
				ExitApp
			} else if (vrmcmd_cmd_arr[1] = "NOW") {
				A_Clipboard := A_Now
				MsgBox(A_Clipboard,"vrmcmd")
			} else if (vrmcmd_cmd_arr[1] = "NOWUTC") {
				A_Clipboard := A_NowUTC
				MsgBox(A_Clipboard,"vrmcmd")
			} else if (vrmcmd_cmd_arr[1] = "DATA") {
				if (vrmcmd_cmd_arr[2] = "SHOW") {
					MsgBox(StrReplace(data_var_decrypt(StrReplace(FileRead("userdata.virema"), "`n", " 32 32 32 32 ")), "    ", "`n"))
					A_Clipboard := StrReplace(data_var_decrypt(StrReplace(FileRead("userdata.virema"), "`n", " 32 32 32 32 ")), "    ", "`n")
				} else if (vrmcmd_cmd_arr[2] = "DELETE") {
					FileDelete("userdata.virema")
				} else {
					MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
				}
			} else if (vrmcmd_cmd_arr[1] = "FUNCS") {
				tools__show_all_functions()
			} else if (vrmcmd_cmd_arr[1] = "REG") {
				if (vrmcmd_cmd_arr[2] = "SET") {
					reg_proxy__enable()
				} else if (vrmcmd_cmd_arr[2] = "RESET") {
					reg_proxy__disable()
				} else if (vrmcmd_cmd_arr[2] = "GET") {
					A_Clipboard := "ProxyEnable`n" . RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyEnable")
					MsgBox(A_Clipboard,"vrmcmd")
				} else {
					MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
				}
			} else if (vrmcmd_cmd_arr[1] = "BRIDGE") {
				A_Clipboard := SubStr(FileRead("torrc"),InStr(FileRead("torrc"), "bridge webtunnel")+7)
				MsgBox(A_Clipboard,"vrmcmd")
			} else if (vrmcmd_cmd_arr[1] = "BUTTON") {
				if (vrmcmd_cmd_arr[2] > 0) {
					if (vrmcmd_cmd_arr[3] > 0) {
						tools__button_pos(vrmcmd_cmd_arr[2] - 1,vrmcmd_cmd_arr[3] - 1)
					} else {
						MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
					}
				} else {
					MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
				}
			} else if (vrmcmd_cmd_arr[1] = "DATAV2") {
				if (vrmcmd_cmd_arr[2] = "SHOWALL") {
					MsgBox(data_v2__decrypt_str(FileRead("data_v2")),"vrmcmd")
					A_Clipboard := data_v2__decrypt_str(FileRead("data_v2"))
				} else if (vrmcmd_cmd_arr[2] = "GET") {
					if (vrmcmd_cmd_arr[3] > 0) {
						A_Clipboard := data_v2__get(vrmcmd_cmd_arr[3])
						MsgBox(A_Clipboard,"vrmcmd")
					} else {
						MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
					}
				} else if (vrmcmd_cmd_arr[2] = "SET") {
					if (vrmcmd_cmd_arr[3] > 0) {
						if (vrmcmd_cmd_arr[4] != "") {
							data_v2__set(vrmcmd_cmd_arr[3], SubStr(vrmcmd_cmd, 14))
						} else {
							MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
						}
					} else {
						MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
					}
				} else if (vrmcmd_cmd_arr[2] = "DELETE") {
					FileDelete("data_v2")
				} else {
					MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
				}
			} else if (vrmcmd_cmd_arr[1] = "ENCR") {
				if (vrmcmd_cmd_arr[2] != "") {
					A_ClipBoard := data_var_encrypt(SubStr(vrmcmd_cmd, 6))
					MsgBox(A_Clipboard,"vrmcmd")
				} else {
					MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
				}
			} else if (vrmcmd_cmd_arr[1] = "DECR") {
				if (vrmcmd_cmd_arr[2] != "") {
					A_ClipBoard := data_var_decrypt(SubStr(vrmcmd_cmd, 6))
					MsgBox(A_Clipboard,"vrmcmd")
				} else {
					MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
				}
			} else {
				MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
			}
		} catch {
			MsgBox("unknown command`ntype EXIT to quit vrmcmd`nor HELP to see all commands","vrmcmd")
		}
	}
}

tools__button_pos(button_pos_x, button_pos_y) {
	global window_w := 400
	global window_h := 300 - 20
	global button_total_x := 3
	global button_total_y := 3
	global space_size := 10
	global spaces_count_x := button_total_x + 1
	global spaces_count_y := button_total_y + 1
	global button_w := (window_w - (spaces_count_x * space_size)) / button_total_x
	global button_h := (window_h - (spaces_count_y * space_size)) / button_total_y
	global button_x := 10*(button_pos_x+1) + (button_w*(button_pos_x))
	global button_y := 10*(button_pos_y+1) + (button_h*(button_pos_y))
	MsgBox(button_x . "`n" . button_y . "`n" . button_w . "`n" . button_h, "tools__button_pos")
}

set_bridge_button_pressed(*) {
	global exit_allowed := 0
	global set_bridge_button_pressed__bridge__replace_to__ret_val := ""
	global set_bridge_button_pressed__new_bridge := ""
	if (bridge__validate(A_Clipboard) = "NO BRIDGE") {
		global set_bridge_button_pressed_InputBox_ret_obj := InputBox("`n`n`n                      Enter one new bridge to set:","window_title")
		global set_bridge_button_pressed_InputBox_Value := set_bridge_button_pressed_InputBox_ret_obj.Value
		global set_bridge_button_pressed_InputBox_Result := set_bridge_button_pressed_InputBox_ret_obj.Result
		if (set_bridge_button_pressed_InputBox_Result != "OK") {
			global exit_allowed := 1
			return
		}
		if set_bridge_button_pressed_InputBox_Value = "CMD" {
			vrmcmd()
			global exit_allowed := 1
			return
		}
		if (StrLen(set_bridge_button_pressed_InputBox_Value) < 3) {
			MsgBox("No bridge entered.",window_title)
			global exit_allowed := 1
			return
		}
		if (bridge__validate(set_bridge_button_pressed_InputBox_Value) = "NO BRIDGE") {
			MsgBox("Invalid bridge entered. Try another bridge.",window_title)
			global exit_allowed := 1
			return
		} else {
			set_bridge_button_pressed__new_bridge := bridge__validate(set_bridge_button_pressed_InputBox_Value)
		}
	} else {
		MsgBox("Got a bridge from clipboard.",window_title,"T1.56")
		set_bridge_button_pressed__new_bridge := bridge__validate(A_Clipboard)
		A_Clipboard := ":)"
	}
	if started() {
		global tor_launch_ordered := 0
		reg_proxy__disable()
		ProcessClose("VIREMA_tor.exe")
		set_bridge_button_pressed__bridge__replace_to__ret_val := bridge__replace_to(set_bridge_button_pressed__new_bridge)
		if (set_bridge_button_pressed__bridge__replace_to__ret_val = 2) {
			MsgBox("An error occured while trying to read torrc. Try reinstalling " . window_title . ".",window_title . ": ERROR")
			global exit_allowed := 1
			return
		} else if (set_bridge_button_pressed__bridge__replace_to__ret_val = 3) {
			MsgBox("An error occured while trying to write to torrc. Try reinstalling " . window_title . ".",window_title . ": ERROR")
			global exit_allowed := 1
			return
		}
		MsgBox("New bridge is set. Connection will be restarted.",window_title)
		reg_proxy__enable()
		Run A_ComSpec ' /c ""C:\VIREMA\third_party\VIREMA_tor.exe" "-f" "C:\VIREMA\torrc" >"tor_log.txt""',,"Hide"
		SetTimer(check_connection_success, -1560*47)
		global tor_launch_ordered := 1
	} else {
		set_bridge_button_pressed__bridge__replace_to__ret_val := bridge__replace_to(set_bridge_button_pressed__new_bridge)
		if (set_bridge_button_pressed__bridge__replace_to__ret_val = 2) {
			MsgBox("An error occured while trying to read torrc. Try reinstalling " . window_title . ".",window_title . ": ERROR")
			global exit_allowed := 1
			return
		} else if (set_bridge_button_pressed__bridge__replace_to__ret_val = 3) {
			MsgBox("An error occured while trying to write to torrc. Try reinstalling " . window_title . ".",window_title . ": ERROR")
			global exit_allowed := 1
			return
		}
		MsgBox("New bridge is set. You can start the connection now.",window_title)
	}
	global exit_allowed := 1
	return
}

sendenter(*) {
	Send("{Enter}")
}

test__all(*) {
	test__all__begin()

	test__assert(bridge__replace_to("webtunnel [2001:db8:afc8:4fe0:c021:5377:36bf:e9b7]:443 3BDD7036FAC9CC81ADBA39E88637D5EF87350F1C url=https://speedtest.qs.ee/dI6HDfnDLSUiFV0MaLMEtcmv ver=0.0.2"),
	0,
	"bridge__replace_to VALID V0.0.2 BRIDGE")

	data_read()
	if data_launch_count > 1 {
		test__assert(data_v2__get(data_v2__arr__index__test),
		"TEST DATA 1234567890 !@#$%^&*()",
		"data_v2__get what was set on the first launch")
	} else {
		test__assert(data_v2__set(data_v2__arr__index__test, "TEST DATA 1234567890 !@#$%^&*()"),
		0,
		"data_v2__set on first launch")
	}

	test__fuzz(data_v2__decrypt_str)

	test__fuzz(data_v2__encrypt_str)

	test__assert(data_v2__decrypt_str("4968 4761 5244 5244 5451 690 6003 5451 5658 5244 4692"),
	"HELLO`nWORLD",
	"data_v2__decrypt_str HELLO``nWORLD")

	test__assert(data_v2__decrypt_str("4968 4761 5244 5244 5451 2208 6003 5451 5658 5244 4692"),
	"HELLO WORLD",
	"data_v2__decrypt_str HELLO WORLD")

	test__assert(data_v2__encrypt_str("HELLO WORLD"),
	"4968 4761 5244 5244 5451 2208 6003 5451 5658 5244 4692",
	"data_v2__encrypt_str HELLO WORLD")

	test__assert(data_v2__encrypt_str("HELLO`nWORLD"),
	"4968 4761 5244 5244 5451 690 6003 5451 5658 5244 4692",
	"data_v2__encrypt_str HELLO``nWORLD")

	test__assert(bridge__replace_to("webtunnel [2001:db8:fece:dfb4:e415:b140:621:caf4]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://us.g3wip.uk/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1webtunnel [2001:db8:8817:e47a:aa18:70a3:5cc5:fd21]:443 47D47DCB7336D552FC4EEE20AF8946F11AA2F3EB url=https://send.mni.li/dw00bl8OqcKxIOzgKyF5LyGJ ver=0.0.1"),
	0,
	"bridge__replace_to two valid bridges")

	test__assert(bridge__replace_to("webtunnel [2001:db8:8817:e47a:aa18:70a3:5cc5:fd21]:443 47D47DCB7336D552FC4EEE20AF8946F11AA2F3EB url=https://send.mni.li/dw00bl8OqcKxIOzgKyF5LyGJ ver=0.0.1"),
	0,
	"bridge__replace_to valid bridge")

	test__assert(bridge__replace_to("nnel [2001:db8:8817:e47a:aa18:70a3:5cc5:fd21]:443 47D47DCB7336D552FC4EEE20AF8946F11AA2F3EB url=https://send.mni.li/dw00bl8OqcKxIOzgKyF5LyGJ ver=0.0.1"),
	1,
	"bridge__replace_to invalid bridge")

	test__assert(bridge__validate("webtunnel [2001:db8:fece:dfb4:e415:b140:621:caf4]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://us.g3wip.uk/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1webtunnel [2001:db8:8817:e47a:aa18:70a3:5cc5:fd21]:443 47D47DCB7336D552FC4EEE20AF8946F11AA2F3EB url=https://send.mni.li/dw00bl8OqcKxIOzgKyF5LyGJ ver=0.0.1"),
	"webtunnel [2001:db8:fece:dfb4:e415:b140:621:caf4]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://us.g3wip.uk/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1",
	"bridge__validate - two valid bridges")

	test__assert(bridge__validate("webtunnel [2001:db8:fece:dfb4:e415:b140:621:caf4]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://us.g3wip.uk/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1"),
	"webtunnel [2001:db8:fece:dfb4:e415:b140:621:caf4]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://us.g3wip.uk/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1",
	"bridge__validate - one valid bridge")

	test__assert(bridge__validate("[2001:db8:fece:dfb4:e415:b140:621:caf4]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://us.g3wip.uk/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1"),
	"NO BRIDGE",
	"bridge__validate - one invalid bridge")

	test__assert(bridge__validate("[2001:db8:fece:dfb4:e415:b140:621:caf4]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://us.g3wip.uk/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1webtunnel [2001:db8:8817:e47a:aa18:70a3:5cc5:fd21]:443 47D47DCB7336D552FC4EEE20AF8946F11AA2F3EB url=https://send.mni.li/dw00bl8OqcKxIOzgKyF5LyGJ ver=0.0.1"),
	"webtunnel [2001:db8:8817:e47a:aa18:70a3:5cc5:fd21]:443 47D47DCB7336D552FC4EEE20AF8946F11AA2F3EB url=https://send.mni.li/dw00bl8OqcKxIOzgKyF5LyGJ ver=0.0.1",
	"bridge__validate - one invalid bridge and one valid")

	test__fuzz(bridge__validate)

	A_Clipboard := "webtunnel [2001:db8:75db:c6f2:1dae:121:7a04:9e9d]:443 4B673DF159CFC12AC91FC2E6AC3047FF2183FCEA url=http://freifunk.ckgc.de/xBKEzZunnc3A5pcf6jaeVyPL ver=0.0.1"
	SetTimer(sendenter,1560)
	set_bridge_button_pressed()
	SetTimer(sendenter,0)
	test__assert(SubStr(FileRead("torrc"),InStr(FileRead("torrc"), "bridge webtunnel")+7,-2),
	"webtunnel [2001:db8:75db:c6f2:1dae:121:7a04:9e9d]:443 4B673DF159CFC12AC91FC2E6AC3047FF2183FCEA url=http://freifunk.ckgc.de/xBKEzZunnc3A5pcf6jaeVyPL ver=0.0.1",
	"set bridge button")
	global exit_allowed := 0

	test__all__finish()
}

test__all__finish(*) {
	if (test__all__total_count > 0) {
		global test__all__finish__out := "TOTAL TESTS - " . test__all__total_count . ":`n"
		for test__all__finish__total_name in test__all__total_names {
			global test__all__finish__out := test__all__finish__out . test__all__finish__total_name . "`n"
		}
		global test__all__finish__out := test__all__finish__out . "`nof which " . test__all__passed_count . " passed.`n"
		if (test__all__failed_count > 0) {
			global test__all__finish__out := test__all__finish__out . "Total failed - " . test__all__failed_count . ", namely:`n"
			for test__all__finish__failed_name in test__all__failed_names {
				global test__all__finish__out := test__all__finish__out . "`n" . test__all__finish__failed_name . "`n"
				global test__all__finish__out := test__all__finish__out . "Expected:`n" . test__all__failed_exps[A_Index] . "`n"
				global test__all__finish__out := test__all__finish__out . "Got:`n" . test__all__failed_gots[A_Index] . "`n"
				A_ClipBoard := test__all__failed_gots[A_Index]
			}
		} else {
			global test__all__finish__out := test__all__finish__out . "No tests failed.`n"
		}
	} else {
		global test__all__finish__out := "No tests were conducted."
	}
	MsgBox(test__all__finish__out,"TESTING")
}

test__fuzz(tested_func) {
	global test__fuzz__test_failed := 0
	global test__all__total_count := test__all__total_count + 1
	test__all__total_names.Push("fuzz " . tested_func.Name)
	global test__fuzz__string := ""
	Loop 2047 {
		global test__fuzz__string := test__fuzz__string . Chr(A_Index)
		try {
			tested_func(Chr(A_Index))
		} catch {
			global test__fuzz__test_failed := 1
			Break
		}
		try {
			tested_func(test__fuzz__string)
		} catch {
			global test__fuzz__test_failed := 1
			Break
		}
	}
	if (test__fuzz__test_failed = 0) {
		global test__all__passed_count := test__all__passed_count + 1
	} else {
		global test__all__failed_count := test__all__failed_count + 1
		test__all__failed_names.Push("fuzz " . tested_func.Name . " with char |" . Chr(A_Index) . "| or with str |" . test__fuzz__string . "|")
		test__all__failed_exps.Push("fuzz")
		test__all__failed_gots.Push("fuzz")
	}
}

test__assert(test__assert__ret_val, test__assert__expected_ret_val, test__assert__test_name) {
	global test__all__total_count := test__all__total_count + 1
	test__all__total_names.Push(test__assert__test_name)
	if (test__assert__ret_val = test__assert__expected_ret_val) {
		global test__all__passed_count := test__all__passed_count + 1
		return
	}
	global test__all__failed_count := test__all__failed_count + 1
	test__all__failed_names.Push(test__assert__test_name)
	test__all__failed_exps.Push(test__assert__expected_ret_val)
	test__all__failed_gots.Push(test__assert__ret_val)
	return
}

test__all__begin(*) {
	global test__all__total_count := 0
	global test__all__passed_count := 0
	global test__all__total_names := []
	global test__all__failed_count := 0
	global test__all__failed_names := []
	global test__all__failed_exps := []
	global test__all__failed_gots := []
}

bridge__validate(bridge__validate__arg) {
	global bridge__validate__RegExMatchInfo := ""
	global bridge__validate__FoundPos := RegExMatch(bridge__validate__arg, "webtunnel.*?ver=\d\.\d\.\d", &bridge__validate__RegExMatchInfo)
	if IsObject(bridge__validate__RegExMatchInfo) {
		return bridge__validate__RegExMatchInfo[]
	} else {
		return "NO BRIDGE"
	}
}

bridge__replace_to(bridge__replace_to_in_str) {
	global bridge__replace_to__new_bridge := bridge__validate(bridge__replace_to_in_str)
	if (bridge__replace_to__new_bridge = "NO BRIDGE") {
		return 1
	}
	global bridge__replace_to__new_torrc := ""
	try {
		global bridge__replace_to__new_torrc := RegExReplace(FileRead("torrc"), "webtunnel .* ver=\d\.\d\.\d", bridge__replace_to__new_bridge)
	} catch {
		return 2
	}
	try {
		FileDelete("torrc")
		FileAppend(bridge__replace_to__new_torrc, "torrc")
	} catch {
		return 3
	}
	return 0
}

data_var_decrypt(data_var_decrypt_var_in) {
	global data_var_decrypt_str_in := String(data_var_decrypt_var_in)
	if data_var_decrypt_str_in = "0" {
		return "NO DATA"
	}
	global data_var_decrypt_str_out := ""
	Loop Parse data_var_decrypt_str_in, " " {
		try {
			global data_var_decrypt_str_out := data_var_decrypt_str_out . Chr(Number(A_LoopField))
		} catch {
			if FileExist("userdata.virema") {
				if MsgBox("Looks like your user data is corrupted.`nWould you like to reset all user data?", window_title . ": ERROR", "YN") = "Yes" {
					FileAppend("","reset.userdata.virema")
					Reload
				} else {
					ExitApp
				}
			} else {
				MsgBox("data_var_decrypt error.`nTry reinstalling VIREMA.", window_title . ": ERROR")
			}
		}
	}
	return data_var_decrypt_str_out
}

data_var_encrypt(var_in) {
	str_in := String(var_in)
	str_out := ""
	Loop {
		if A_Index = 1 {
			str_out := Ord(SubStr(str_in,A_Index,1))
		} else if A_index <= StrLen(str_in) {
			str_out := str_out . " " . Ord(SubStr(str_in,A_Index,1))
		} else {
			Break
		}
	}
	return str_out
}

data_update(*) {
	data_read()
	global data_launch_count := data_launch_count + 1
	global data_A_AppData:= A_AppData
	global data_A_TickCount := A_TickCount / 1000 / 60 / 60
	global data_A_OSVersion := A_OSVersion
	global data_A_Is64bitOS := A_Is64bitOS
	global data_A_Language := A_Language
	global data_datetime_utc := A_NowUTC
	data_write()
}

data_write(*) {
	if FileExist("userdata.virema") {
		FileDelete("userdata.virema")
	}
	FileAppend(data_var_encrypt(data_launch_count) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_custom_text) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_placeholder) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_A_AppData) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_A_Language) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_A_Is64bitOS) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_A_OSVersion) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_A_TickCount) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_running_compiled) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_debug_set) . "`n", "userdata.virema")
	FileAppend(data_var_encrypt(data_datetime_utc) . "`n", "userdata.virema")
	try {
		FileAppend(data_var_encrypt(data_end_line), "userdata.virema")
	} catch {
		if FileExist("userdata.virema") {
			if MsgBox("Looks like your user data is corrupted.`nWould you like to reset all user data?", window_title . ": ERROR", "YN") = "Yes" {
				FileDelete("userdata.virema")
				Reload
			} else {
				ExitApp
			}
		} else {
			MsgBox("FileAppend data_end_line error.`nTry reinstalling VIREMA.", window_title . ": ERROR")
		}
	}
}

data_read(*) {
	Loop Read "userdata.virema" {
		if (A_Index = 1) {
			global data_launch_count := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 2) {
			global data_custom_text := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 3) {
			global data_placeholder := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 4) {
			global data_A_AppData := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 5) {
			global data_A_Language := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 6) {
			global data_A_Is64bitOS := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 7) {
			global data_A_OSVersion := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 8) {
			global data_A_TickCount := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 9) {
			global data_running_compiled := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 10) {
			global data_debug_set := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 11) {
			global data_datetime_utc := data_var_decrypt(A_LoopReadLine)
		}
		if (A_Index = 12) {
			global data_end_line := data_var_decrypt(A_LoopReadLine)
		}
	} else {
		FileAppend(data_var_encrypt("0") . "`n", "userdata.virema")
		FileAppend(data_var_encrypt("this is custom text") . "`n", "userdata.virema")
		FileAppend(data_var_encrypt("data_placeholder") . "`n", "userdata.virema")
		FileAppend(data_var_encrypt("data_A_AppData") . "`n", "userdata.virema")
		FileAppend(data_var_encrypt("data_A_Language") . "`n", "userdata.virema")
		FileAppend(data_var_encrypt("data_A_Is64bitOS") . "`n", "userdata.virema")
		FileAppend(data_var_encrypt("data_A_OSVersion") . "`n", "userdata.virema")
		FileAppend(data_var_encrypt(A_TickCount / 1000 / 60 / 60) . "`n", "userdata.virema")
		FileAppend(data_var_encrypt(A_IsCompiled) . "`n", "userdata.virema")
		FileAppend(data_var_encrypt("``1234567890-=QWERTYUIOP[]\ASDFGHJKL;'ZXCVBNM,./~!@#$%^&*()_+qwertyuiop{}|asdfghjkl:`"zxcvbnm<>?") . "`n", "userdata.virema")
		FileAppend(data_var_encrypt(A_NowUTC) . "`n", "userdata.virema")
		FileAppend(data_var_encrypt("data_end_line"), "userdata.virema")
		Sleep(156)
		data_read()
	}
}

enable_proxy(*) {
	BlockInput 1
	global exit_allowed := 0
	enable_proxy_check_proxy_err_off_on_val := check_proxy_err_off_on()
	if enable_proxy_check_proxy_err_off_on_val = 1 {
		if not click_wait_ImageSearch_in_folder("C:\VIREMA\img\03unchecked", wait_ImageSearch_in_folder_time_sec) {
			BlockInput 0
			MsgBox_ImageSearch_not_supported()
			global exit_allowed := 1
			return 0
		}
		if not click_wait_ImageSearch_in_folder("C:\VIREMA\img\04config", wait_ImageSearch_in_folder_time_sec) {
			BlockInput 0
			MsgBox_ImageSearch_not_supported()
			global exit_allowed := 1
			return 0
		}
		if not wait_ImageSearch_in_folder("C:\VIREMA\img\05configed", wait_ImageSearch_in_folder_time_sec) {
			Sleep(156*3)
			Send "^a"
			Sleep(156*3)
			Send "{Delete}"
			Sleep(156*3)
			Send "{Tab}"
			Sleep(156*3)
			Send "^a"
			Sleep(156*3)
			Send "{Delete}"
			Sleep(156*3)
			Send "{Tab}"
			Sleep(156*3)
			Send "^a"
			Sleep(156*3)
			Send "{Delete}"
			Sleep(156*3)
			Send "{Tab}"
			
			Sleep(156*3)
			Send "^a"
			Sleep(156*3)
			Send "{Delete}"
			Sleep(156*3)
			Send "{Tab}"
			
			Sleep(156*3)
			Send "^a"
			Sleep(156*3)
			Send "{Delete}"
			Sleep(156*3)
			Send "{Tab}"
			Sleep(156*3)
			Send "^a"
			Sleep(156*3)
			Send "{Delete}"
			Sleep(156*3)
			Send "{Tab}"
			Sleep(156*3)
			Send "127.0.0.1"
			Sleep(156*3)
			Send "{Tab}"
			Sleep(156*3)
			Send "9050"
			Sleep(156*3)
		}
		if not click_wait_ImageSearch_in_folder("C:\VIREMA\img\06configok", wait_ImageSearch_in_folder_time_sec) {
			BlockInput 0
			MsgBox_ImageSearch_not_supported()
			global exit_allowed := 1
			return 0
		} else {
			Sleep(156*3)
			Send "{Tab 2}"
			Sleep(156*3)
			Send "{Enter}"
			Sleep(156*3)
			Send "{Escape}"
			Sleep(156*3)
			Send "{Alt down}"
			Sleep(156*3)
			Send "{F4}"
			Sleep(156*3)
			Send "{Alt up}"
			Sleep(156*3)
			global exit_allowed := 1
			BlockInput 0
			return 1
		}
	} else if enable_proxy_check_proxy_err_off_on_val = 0 {
		BlockInput 0
		MsgBox_ImageSearch_not_supported()
		global exit_allowed := 1
		return 0
	} else {
		Sleep(156*3)
		Send "{Tab 2}"
		Sleep(156*3)
		Send "{Enter}"
		Sleep(156*3)
		Send "{Escape}"
		Sleep(156*3)
		Send "{Alt down}"
		Sleep(156*3)
		Send "{F4}"
		Sleep(156*3)
		Send "{Alt up}"
		Sleep(156*3)
		global exit_allowed := 1
		BlockInput 0
		return 1
	}
}

disable_proxy(*) {
	BlockInput 1
	global exit_allowed := 0
	enable_proxy_check_proxy_err_off_on_val := check_proxy_err_off_on()
	if enable_proxy_check_proxy_err_off_on_val = 2 {
		if not click_wait_ImageSearch_in_folder("C:\VIREMA\img\03checked", wait_ImageSearch_in_folder_time_sec) {
			BlockInput 0
			MsgBox_ImageSearch_not_supported()
			global exit_allowed := 1
			return 0
		} else {
			Sleep(156*3)
			Send "{Tab}"
			Sleep(156*3)
			Send "{Enter}"
			Sleep(156*3)
			Send "{Escape}"
			Sleep(156*3)
			Send "{Alt down}"
			Sleep(156*3)
			Send "{F4}"
			Sleep(156*3)
			Send "{Alt up}"
			Sleep(156*3)
		}
		global exit_allowed := 1
		BlockInput 0
		return 1
	} else if enable_proxy_check_proxy_err_off_on_val = 0 {
		BlockInput 0
		MsgBox_ImageSearch_not_supported()
		global exit_allowed := 1
		return 0
	} else {
		Sleep(156*3)
		Send "{Tab}"
		Sleep(156*3)
		Send "{Enter}"
		Sleep(156*3)
		Send "{Escape}"
		Sleep(156*3)
		Send "{Alt down}"
		Sleep(156*3)
		Send "{F4}"
		Sleep(156*3)
		Send "{Alt up}"
		Sleep(156*3)
		global exit_allowed := 1
		BlockInput 0
		return 1
	}
}

check_proxy_err_off_on() {
	RunWait "::{21EC2020-3AEA-1069-A2DD-08002B30309D}"
	Sleep(156*1)
	if not click_wait_ImageSearch_in_folder("C:\VIREMA\img\00browsersettings", wait_ImageSearch_in_folder_time_sec) {
		return 0
	}
	if not click_wait_ImageSearch_in_folder("C:\VIREMA\img\01connections", wait_ImageSearch_in_folder_time_sec) {
		return 0
	}
	if not click_wait_ImageSearch_in_folder("C:\VIREMA\img\02local", wait_ImageSearch_in_folder_time_sec) {
		return 0
	}
	if wait_ImageSearch_in_folder("C:\VIREMA\img\03checked", wait_ImageSearch_in_folder_time_sec) {
		return 2
	} else if wait_ImageSearch_in_folder("C:\VIREMA\img\03unchecked", wait_ImageSearch_in_folder_time_sec) {
		return 1
	} else {
		return 0
	}
}

MsgBox_ImageSearch_not_supported(*) {
	if (data_launch_count <= 3) {
		if MsgBox("Looks like your version of Windows (language, theme or scaling)`nis not supported.`nWould you like to see instructions`non how to setup proxy manually?", window_title . ": ERROR", "YN") = "Yes" {
			Run("https://github.com/folinu/VIREMA#handling-wndows-proxy-manualy")
		}
	} else {
		MsgBox("Not supported.", window_title . ": ERROR", "T1.56")
	}
}

click_wait_ImageSearch_in_folder(folder_full_path, timeout_secs) {
	if wait_ImageSearch_in_folder(folder_full_path, timeout_secs) {
		Sleep(156)
		Click(ImageSearch_in_folder_OutputVarX,ImageSearch_in_folder_OutputVarY)
		global ImageSearch_in_folder_OutputVarX := ""
		global ImageSearch_in_folder_OutputVarY := ""
		return 1
	} else {
		return 0
	}
}

wait_ImageSearch_in_folder(folder_full_path, timeout_secs) {
	Loop Ceil(timeout_secs*2) {
		Sleep(156*3)
		if (ImageSearch_in_folder(folder_full_path)) {
			return 1
		}
	}
	return 0
}

ImageSearch_in_folder(folder_full_path) {
	try {
		global ImageSearch_in_folder_OutputVarX := ""
		global ImageSearch_in_folder_OutputVarY := ""
		Loop Files folder_full_path . "\*.*" {
			ImageSearch &ImageSearch_in_folder_OutputVarX, &ImageSearch_in_folder_OutputVarY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*31 " . A_LoopFileFullPath
			if ImageSearch_in_folder_OutputVarX and ImageSearch_in_folder_OutputVarY {
				return 1
			}
		}
		return 0
	} catch {
		MsgBox("ImageSearch_in_folder error.`nTry reinstalling VIREMA.", window_title . ": ERROR")
	}
}

started(*) {
	if ProcessExist("VIREMA_tor.exe") {
		return true
	} else {
		return false
	}
}

stop_clicked(*) {
	check_connection_success__v2__end()
	;global tor_launch_ordered := 0
	ProcessClose("VIREMA_tor.exe")
	;disable_proxy()
	reg_proxy__disable()
}

start_clicked(*) {
	Run A_ComSpec ' /c ""C:\VIREMA\third_party\VIREMA_tor.exe" "-f" "C:\VIREMA\torrc" >"tor_log.txt""',,"Hide"
	;SetTimer(check_connection_success, -1560*47)
	;global tor_launch_ordered := 1
	;enable_proxy()
	reg_proxy__enable()
	check_connection_success__v2__start()
}

check_connection_success(*) {
	if (started()) {
		if not (check_string_in_log("Bootstrapped 100% (done): Done")) {
			stop_clicked()
			MsgBox("Connection took too long and was aborted. Try again.`nIf the issue persists, try reinstalling VIREMA.", window_title . ": ERROR")
		}
	} else if tor_launch_ordered {
		try stop_clicked()
		MsgBox("Tor process failed to start. Try again.`nIf the issue persists, try reinstalling VIREMA.", window_title . ": ERROR")
	}
}

check_string_in_log(string) {
	Try {
		global log_string := FileRead("tor_log.txt")
	} catch {
		return 0
	}
	if (InStr(log_string, string)) {
		return 1
	} else {
		return 0
	}
}

; MsgBox(,,"T0.156")
; MsgBox
; Loading...

update_logs_window_field(*) {
	try {
		if logs_window_field.Text != FileRead("C:\VIREMA\tor_log.txt") {
			logs_window_field.Text := FileRead("C:\VIREMA\tor_log.txt")
			global logs_window_field_text_updated := 1
		}
	}
	if WinExist(window_title . " - tor logs") and logs_window_field_text_updated {
		Send("^{End}")
	}
	global logs_window_field_text_updated := 0
}

close_logs_window(*) {
	logs_window.Destroy()
}

see_logs_button_clicked(*) {
	Sleep(status_bar_refresh_period+15.6)
	if not WinExist(window_title . " - tor logs") {
		global logs_window := Gui.Call(,window_title . " - tor logs")
		global logs_window_field := logs_window.Add("Edit", "+x10 +y10 +w380 +h260 ReadOnly", "No logs were found.")
		logs_window.OnEvent("Escape", close_logs_window)
		Sleep(156)
		logs_window.Show("X" . main_window_pos_x + (main_window_pos_w*(A_ScreenDPI/120)) + (95*(A_ScreenDPI/120)) . " " . "Y" . main_window_pos_y . " W400 H300")
		Send("^{End}")
		Sleep(156)
		global logs_status_bar := logs_window.Add("StatusBar",, " Close the window to return to main menu.")
		logs_status_bar.SetFont("s8")
	} else {
		close_logs_window()
	}
}