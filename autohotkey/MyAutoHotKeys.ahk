; vim: ts=2 sw=0

; Tips:
; `^` is `CTRL`
; `+` is `SHIFT`
; `!` is `ALT`
; `#` is `WIN`

; Open terminal with "Ctrl+Alt+T"
^!t::Run("wt.exe", EnvGet("USERPROFILE"))

; TotalCMD: open new tab with middle mouse button
#HotIf WinActive("ahk_class TTOTAL_CMD") && TC_OpenTabCheck()
MButton::{
  Click()
  PostMessage(1075, 3003, 0) ; cm_OpenDirInNewTab := 3003
}
!MButton::{
  Click()
  PostMessage(1075, 3004, 0) ; cm_OpenDirInNewTabOther := 3004
}
#HotIf

TC_OpenTabCheck() {
  MouseGetPos(, , , &ctrl)
  Return ctrl = "LCLListBox1" || ctrl == "LCLListBox2"
}
