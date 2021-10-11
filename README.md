# WarMenu
Inspired by [Dear ImGui](https://github.com/ocornut/imgui) and GTA V menu system

## How to Install
1. Place it to `/resources` folder
2. Add `ensure warmenu` to your `server.cfg`
3. Add `client_script '@warmenu/warmenu.lua'` to your `fxmanifest.lua`


## Features
* Backward compatibility
* GTA V-like look'n'feel
* Rich menu style customization
* Lots of built-in controls
* Demo menu

## Demo menu
You can read its source code to understand how framework works   
To run it, just add `client_script @warmenu/warmenu_demo.lua` to any of your resources which are using WarMenu

## API
```lua
--- * - optional parameters
WarMenu.CreateMenu(id, title, subTitle*, style*)
WarMenu.CreateSubMenu(id, parent, subTitle*, style*)

WarMenu.CurrentMenu() -- id

WarMenu.OpenMenu(id)
WarMenu.Begin(id)
WarMenu.IsAnyMenuOpened()
WarMenu.IsMenuAboutToBeClosed() -- DEPRECATED: always return false
WarMenu.CloseMenu()

-- Controls
WarMenu.Button(text, subText*)
WarMenu.InputButton(text, windowTitleEntry*, defaultText*, maxLength*, subText*)
WarMenu.SpriteButton(text, dict, name, r*, g*, b*, a*)
WarMenu.MenuButton(text, id, subText*)
WarMenu.CheckBox(text, checked)
WarMenu.ComboBox(text, items, currentIndex)
WarMenu.ToolTip(text, width*, flipHorizontal*)
-- Use them in loop to draw
-- They return true if were selected OR you can use functions below for more granual control
WarMenu.IsItemHovered()
WarMenu.IsItemSelected()
-- See Usage section for more details

WarMenu.End() -- Processing key events and menu logic, use it in loop


-- Customizable options
--- Menu
WarMenu.SetMenuTitle(id, title)
WarMenu.SetMenuSubTitle(id, text) -- it will uppercase automatically

--- Style
--- Property name can be extracted from setter signature, i. e. 'SetMenuTitleColor' -> 'titleColor'
--- Example: local style = { titleColor = { 255, 255, 255 }, maxOptionCountOnScreen = 7, buttonPressedSound = { name = 'name', set = 'set' } }
WarMenu.SetMenuStyle(id, style)

WarMenu.SetMenuX(id, x) -- [0.0..1.0] top left corner
WarMenu.SetMenuY(id, y) -- [0.0..1.0] top
WarMenu.SetMenuWidth(id, width) -- [0.0..1.0]
WarMenu.SetMenuMaxOptionCountOnScreen(id, count) -- 10 by default

WarMenu.SetMenuTitleColor(id, r, g, b, a*)
WarMenu.SetMenuSubTitleColor(id, r, g, b, a*)

WarMenu.SetMenuTitleBackgroundColor(id, r, g, b, a*)
-- or
WarMenu.SetMenuTitleBackgroundSprite(id, dict, name)

WarMenu.SetMenuBackgroundColor(id, r, g, b, a*)
WarMenu.SetMenuTextColor(id, r, g, b, a*)
WarMenu.SetMenuSubTextColor(id, r, g, b, a*)
WarMenu.SetMenuFocusColor(id, r, g, b, a*)
WarMenu.SetMenuFocusTextColor(id, r, g, b, a*)
WarMenu.SetMenuButtonPressedSound(id, name, set) -- https://pastebin.com/0neZdsZ5
```


## Changelog
### 1.5
* Added styles support
* Added `WarMenu.SetMenuStyle` API
* Added `WarMenu.CreateMenu` subTitle parameter
* Corrected title background aspect ratio
* Fixed minor bugs
### 1.4
* Added `WarMenu.InputButton` API
* Improved performance
* Improved key mapping
* Marked optional parameters in API section
### 1.3
* Added Demo Menu
* Added `WarMenu.SetMenuFocusTextColor` API
* Fixed `WarMenu.SetMenuFocusColor` API
* Fixed `WarMenu.SpriteButton` edge case
* Improved performance and memory consumption
* Removed debug prints
* Improved code style
### 1.2
* Added `WarMenu.SpriteButton` API
### 1.1
* Added `WarMenu.ToolTip` API
### 1.0
* Added `WarMenu.IsItemHovered` and `WarMenu.IsItemSelected` API
* Implemented restoring parent menu selected index after closing submenu
* Improved `WarMenu.ComboBox` and `WarMenu.CheckBox` API (without breaking compatibility!)
* Improved performance and memory consumption
* Updated Usage section
### 0.9.15
* Improved performance and memory consumption
* Added proper debug getter/setter API
* Improved API consistency
### 0.9.14
* Improved button mapping
* Improved controller support
### 0.9.12
* Introduced significant performance boost
From `~0.4 ms` to `~0.02 ms` ( **~20x times faster!** )
### 0.9.11
* Fixed drawing numbers as button text
### 0.9.10
* Added new `WarMenu.CurrentOption()` API
### 0.9.9
* Added new `WarMenu.SetTitle()` API
* Added `WarMenu.MenuButton` subText optional parameter
* Updated manifest format
### 0.9.8
* Added new `WarMenu.IsAnyMenuOpened()` API
* Added new `WarMenu.SetTitleBackgroundSprite()` API
### 0.9.7
* Added new `WarMenu.SetMenuSubTextColor()` API
* @alberto2345: Added alpha parameters to color functions (with default values, so no worry for existing code)
* Improved default `subText` color (see image)
* Fixed flickering after reopening menu
* @alberto2345: Fixed button execution after reopening menu
* Fixed `subTitle` sub menu initializing
* Corrected `WarMenu.CheckBox` usage example
### 0.9.6
* Added new `WarMenu.IsMenuAboutToBeClosed()` API
* Fixed `WarMenu.MenuButton` bug with unnecessary attempts to draw it without current menu
* Fixed `WarMenu.ComboBox` bug with incorrect current index after reopening menu
### 0.9.5
* Changed `WarMenu.ComboBox` control behavior and look - you need to press SELECT in order to confirm your choice.
Also, it has two indexes now - for a current displaying item and user-selected one.
It allows you create more complex menus like Los Santos Customs with Preview Mode.
And don't forget to check new sexy arrows. :wink:
See updated Usage section for more info.
* Added new `SetMenuButtonPressedSound(id, name, set)` API
* Highly improved Debug Mode - more helpful information, better readability
* `SetTitleWrap()` and `SetTitleScale()` APIs were removed due to text alignment complexity
* Fixed lots of potential bugs with Debug Mode
* Code cleaning and refactoring as well as bug fixes
### 0.9
* Initial release
