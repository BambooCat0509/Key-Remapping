#Requires AutoHotkey v2.0
#SingleInstance Force
#InputLevel 1
*AppsKey::    Send("{RCtrl Down}")
*AppsKey Up:: Send("{RCtrl Up}")

; ------------------------------------------------------------
; （# = Win，+ = Shift，^ = Ctrl，! = Alt）
; {Blind} 會保留目前實際按著的修飾鍵(Win/Shift)狀態一起送出。
; 用 #InputLevel 1 讓這個熱鍵只回應「實體按鍵」，忽略腳本自己
; 內部送出的 AppsKey(用來模擬按一下 List 鍵原本功能)，避免互相誤觸。
; ------------------------------------------------------------

global BurstThreshold := 100   ; 毫秒；判斷「單獨按下CP」vs「刻意Win+CP」的門檻，可自行調整
global g_WinDownTime  := 0     ; 真正的 Win 鍵最近一次「由放開變按下」的時間點
global g_LWinIsDown   := false
global g_RWinIsDown   := false ; 右邊 Win 鍵目前是否按著(旁觀記錄，不即時查詢)
global g_ComboActive  := false ; 目前是否正處於「CP 鍵按著沒放開」的狀態

; 單純旁觀記錄 Win 鍵按下的時間，不攔截、不影響任何其他功能
~*LWin:: {
	global g_WinDownTime, g_LWinIsDown, g_RWinIsDown
	if !g_LWinIsDown && !g_RWinIsDown {
		g_LWinIsDown  := true
		g_WinDownTime := A_TickCount
	}
}

~*LWin Up:: {
	global g_LWinIsDown
	g_LWinIsDown := false
}

~*RWin:: {
	global g_WinDownTime, g_RWinIsDown, g_LWinIsDown
	if !g_RWinIsDown && !g_LWinIsDown {
		g_RWinIsDown  := true
		g_WinDownTime := A_TickCount
	}
}

~*RWin Up:: {
	global g_RWinIsDown
	g_RWinIsDown := false
}

$*#+F23:: {
	global g_WinDownTime, g_ComboActive, g_RWinIsDown, BurstThreshold

	;; 忽略長按過程中系統自動重複送出的訊號
	if g_ComboActive
		return

	g_ComboActive := true
	elapsed := A_TickCount - g_WinDownTime
	isDeliberate := (elapsed >= BurstThreshold)

	if isDeliberate {
		Send("{Blind}{F23}")
	} else {
		Send("+{AppsKey}")
	}
}

$*#+F23 Up:: {
	global g_ComboActive
	g_ComboActive := false
}
