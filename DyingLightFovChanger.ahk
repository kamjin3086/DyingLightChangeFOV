#SingleInstance, Force

; --- 配置文件路径 ---
ConfigFilePath := A_MyDocuments . "\DyingLight\out\settings\video.scr"

; --- 程序启动时，首先调用函数加载初始FOV值 ---
InitialFov := LoadInitialFov()

; --- [v1语法] 创建菜单 ---
Menu, AboutMenu, Add, 作者: kamjin3086, DummyHandler
Menu, AboutMenu, Disable, 作者: kamjin3086
Menu, AboutMenu, Add, 版本: 0.1.0, DummyHandler
Menu, AboutMenu, Disable, 版本: 0.1.0
Menu, AboutMenu, Add  ; 分隔线
; --- [文本修改] 更改菜单项的显示文本 ---
Menu, AboutMenu, Add, 项目链接（下载新版本）, OpenProjectLink
Menu, AboutMenu, Add, 作者主页..., OpenHomepageLink
Menu, MenuBar, Add, &关于, :AboutMenu
Gui, Menu, MenuBar

; --- [v1语法] 创建GUI界面 ---
Gui, Font, s12, Microsoft YaHei
Gui, Add, Text, cRed w320, 注意：保存时请确保游戏已完全退出！
Gui, Add, Text, h15
Gui, Add, Text, vCurrentFovDisplay w320, % "当前文件中FOV: " . Format("{:.2f}", InitialFov)
Gui, Add, Text, vTargetFovDisplay w320, % "滑块目标FOV: " . Format("{:.2f}", InitialFov)
Gui, Add, Slider, vFovValue gUpdateTargetFovDisplay Range5-100 w320, %InitialFov%
Gui, Add, Text, h15
Gui, Add, Button, gSaveSettings w150, 保存
Gui, Add, Button, x+20 gResetSettings w150, 重置

; 显示窗口
Gui, Show
Return


; --- 事件处理标签 ---

; 菜单项的点击事件
OpenProjectLink:
    Run, https://github.com/kamjin3086/DyingLightChangeFOV
Return

OpenHomepageLink:
    Run, http://kamjin3086.github.io/
Return

; 滑块拖动事件 (g-label)
UpdateTargetFovDisplay:
    GuiControlGet, FovValue  ; 从滑块控件获取当前值到 FovValue 变量
    GuiControl,, TargetFovDisplay, % "滑块目标FOV: " . Format("{:.2f}", FovValue)
Return

; 重置按钮事件 (g-label)
ResetSettings:
    GuiControl,, FovValue, 20 ; 1. 将滑块的值在界面上设置为20
    Gosub, UpdateTargetFovDisplay ; 2. 更新界面上的文本显示
    Gosub, SaveSettings      ; 3. 调用保存的子程序
Return

; 保存按钮事件 (g-label)
SaveSettings:
    Gui, Submit, NoHide ; 将所有控件的当前值更新到其关联变量中
    if not FileExist(ConfigFilePath)
    {
        MsgBox, 48, 错误, 未找到配置文件!`n`n路径: `n%ConfigFilePath%`n`n请确认游戏是否已运行至少一次。
        Return
    }

    NewContent := ""
    FoundLine := false

    Loop, Read, %ConfigFilePath%
    {
        if InStr(A_LoopReadLine, "ExtraGameFov")
        {
            NewContent .= "ExtraGameFov(" . Format("{:.2f}", FovValue) . ")`r`n"
            FoundLine := true
        }
        else
        {
            NewContent .= A_LoopReadLine . "`r`n"
        }
    }

    if not FoundLine
    {
        NewContent .= "ExtraGameFov(" . Format("{:.2f}", FovValue) . ")`r`n"
    }
    
    FileDelete, %ConfigFilePath%
    FileAppend, %NewContent%, %ConfigFilePath%, UTF-8
    
    GuiControl,, CurrentFovDisplay, % "当前文件中FOV: " . Format("{:.2f}", FovValue)
    MsgBox, 64, 成功, % "FOV 值已成功保存为 " . Format("{:.2f}", FovValue) . "！"
Return

; 关闭窗口事件
GuiClose:
ExitApp

; --- 函数定义 ---

LoadInitialFov() {
    DefaultFov := 20
    if not FileExist(A_MyDocuments . "\DyingLight\out\settings\video.scr")
        Return DefaultFov

    Loop, Read, % A_MyDocuments . "\DyingLight\out\settings\video.scr"
    {
        if InStr(A_LoopReadLine, "ExtraGameFov")
        {
            RegExMatch(A_LoopReadLine, "\(([\d\.]+)\)", Match)
            Return Match1
        }
    }
    Return DefaultFov
}

; 这是一个空的标签，用于禁用菜单项
DummyHandler:
Return