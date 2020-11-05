# WarMenu
Inspired by @MrDaGree  [GUI Management (Maker) | Mod Menu Style Menus (uhh.. ya)](https://forum.fivem.net/t/release-gui-management-maker-mod-menu-style-menus-uhh-ya)


## How to Install
1. Place it to `/resources` folder
2. Add `ensure warmenu` to your `server.cfg`
3. Add `client_script '@warmenu/warmenu.lua'` to your `fxmanifest.lua`


## Features
* Original GTA V look 'n' feel
* Customize each menu separately
* Create nested menus in one line
* It sounds


## Usage
```lua
Citizen.CreateThread(function()
	local items = { 'Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5' }
	local currentItemIndex = 1
	local selectedItemIndex = 1
	local checkbox = true

	WarMenu.CreateMenu('test', 'Test title')
	WarMenu.CreateSubMenu('closeMenu', 'test', 'Are you sure?')

	while true do
		if WarMenu.IsMenuOpened('test') then
			if WarMenu.CheckBox('Checkbox', checkbox) then
				checkbox = not checkbox
				-- Do your stuff here
			elseif WarMenu.ComboBox('Combobox', items, currentItemIndex, selectedItemIndex, function(currentIndex, selectedIndex)
					currentItemIndex = currentIndex
					selectedItemIndex = selectedIndex

					-- Do your stuff here if current index was changed (don't forget to check it)
				end) then
					-- Do your stuff here if current item was activated
			elseif WarMenu.MenuButton('Exit', 'closeMenu') then
			end

			-- Always check current option AFTER drawing all controls and BEFORE WarMenu.Display() function call
			Citizen.Trace(WarMenu.CurrentOption())

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('closeMenu') then
			if WarMenu.Button('Yes') then
				WarMenu.CloseMenu()
			elseif WarMenu.MenuButton('No', 'test') then
			end

			WarMenu.Display()
		elseif IsControlJustReleased(0, 244) then -- M by default
			WarMenu.OpenMenu('test')
		end

		Citizen.Wait(0)
	end
end)
```


## API
```lua
WarMenu.SetDebugEnabled(enabled) -- false by default
WarMenu.IsDebugEnabled()

WarMenu.CreateMenu(id, title)
WarMenu.CreateSubMenu(id, parent, subTitle)

WarMenu.CurrentMenu() -- id
WarMenu.CurrentOption() -- current index (>= 1) or nil

WarMenu.OpenMenu(id)
WarMenu.IsMenuOpened(id)
WarMenu.IsAnyMenuOpened()
WarMenu.IsMenuAboutToBeClosed() -- return true if current menu will be closed in next frame
WarMenu.CloseMenu()

-- Controls return true if activated
WarMenu.Button(text, subText)
WarMenu.MenuButton(text, id, subText)
WarMenu.CheckBox(text, bool, callback)
WarMenu.ComboBox(text, items, currentIndex, selectedIndex, callback)
-- Use them in loop to draw

WarMenu.Display() -- Processing key events and menu logic, use it in loop


-- Customizable options
WarMenu.SetMenuWidth(id, width) -- [0.0..1.0]
WarMenu.SetMenuX(id, x) -- [0.0..1.0] top left corner
WarMenu.SetMenuY(id, y) -- [0.0..1.0] top
WarMenu.SetMenuMaxOptionCountOnScreen(id, count) -- 10 by default

WarMenu.SetMenuTitle(id, title)
WarMenu.SetMenuTitleColor(id, r, g, b, a)
WarMenu.SetMenuTitleBackgroundColor(id, r, g, b, a)
-- or
WarMenu.SetMenuTitleBackgroundSprite(id, textureDict, textureName)

WarMenu.SetMenuSubTitle(id, text) -- it will uppercase automatically

WarMenu.SetMenuBackgroundColor(id, r, g, b, a)
WarMenu.SetMenuTextColor(id, r, g, b, a)
WarMenu.SetMenuSubTextColor(id, r, g, b, a)
WarMenu.SetMenuFocusColor(id, r, g, b, a)

WarMenu.SetMenuButtonPressedSound(id, name, set) -- https://pastebin.com/0neZdsZ5
```


## Changelog
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
