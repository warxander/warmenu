# WarMenu
FiveM Lua Menu framework

WarMenu is an immediate mode GUI framework based on GTA V GUI style

## Installation Guide
1. Download and put into `resources/` directory
2. Add `ensure warmenu` to your `server.cfg`
3. Add `client_script '@warmenu/warmenu.lua'` to your `fxmanifest.lua`

## Demo
Add `client_script @warmenu/warmenu_demo.lua` to your `fxmanifest.lua` and use `warmenuDemo` chat command to open WarMenu demo

## API
```lua
--! @param id: string
--! @param title: string
--! @param subTitle: string
--! @param style: table
WarMenu.CreateMenu(id, title, [subTitle, style])

--! @param id: string
--! @param parentId: string
--! @param subTitle: string
--! @param style: table
WarMenu.CreateSubMenu(id, parentId, [subTitle, style])

--! @return id: string
local id = WarMenu.CurrentMenu()

--! @return optionIndex: number
local optionIndex = WarMenu.OptionIndex()

--! @param id: string
WarMenu.OpenMenu(id)

--! @param id: string
--! @return isOpened: boolean
local isOpened = WarMenu.Begin(id)

WarMenu.End()

--! @param text: string
--! @return isPressed: boolean
local isPressed = WarMenu.Button(text [, subText])

--! @param text: string
--! @param windowTitleEntry: string
--! @param defaultText: string
--! @param maxLength: number
--! @param subText: string
--! @return isPressed: boolean
--! @return inputText: string
local isPressed, inputText = WarMenu.InputButton(text [, windowTitleEntry, defaultText, maxLength, subText])

--! @param text: string
--! @param dict: string
--! @param name: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
--! @return isPressed: boolean
local isPressed = WarMenu.SpriteButton(text, dict, name [, r, g, b, a])

--! @param text: string
--! @param id: string
--! @param subText: string
--! @return isPressed: boolean
local isPressed = WarMenu.MenuButton(text, id [, subText])

--! @param text: string
--! @param checked: boolean
--! @return isPressed: boolean
local isPressed = WarMenu.CheckBox(text, checked)

--! @param text: string
--! @param items: table
--! @param currentIndex: number
--! @return isPressed: boolean
--! @return currentIndex: number
local isPressed, currentIndex = WarMenu.ComboBox(text, items, currentIndex)

--! @param text: string
--! @param width: number
--! @param flipHorizontal: boolean
WarMenu.ToolTip(text [, width, flipHorizontal])

--! @return isHovered: boolean
local isHovered = WarMenu.IsItemHovered()

--! @return isSelected: boolean
local isSelected = WarMenu.IsItemSelected()

--! @param id: string
--! @param title: string
--! @comment Uppercased automatically
WarMenu.SetMenuTitle(id, title)

--! @param id: string
--! @param subTitle: string
--! @comment Uppercased automatically
WarMenu.SetMenuSubTitle(id, subTitle)

--! @param id: string
--! @param style: table
--! @comment Use style methods to figure out style values
WarMenu.SetMenuStyle(id, style)

--! @param id: string
--! @param x: number [0.0..1.0] left-right direction
WarMenu.SetMenuX(id, x)

--! @param id: string
--! @param y: number [0.0..1.0] top-bottom direction
WarMenu.SetMenuY(id, y)

--! @param id: string
--! @param width: number [0.0..1.0]
WarMenu.SetMenuWidth(id, width)

--! @param id: string
--! @param optionCount: number
WarMenu.SetMenuMaxOptionCountOnScreen(id, optionCount)

--! @param id: string
--! @param visible: boolean
WarMenu.SetMenuTitleVisible(id, visible)

--! @param id: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
WarMenu.SetMenuTitleColor(id, r, g, b [, a])

--! @param id: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
WarMenu.SetMenuSubTitleColor(id, r, g, b [, a])

--! @param id: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
WarMenu.SetMenuSubTitleBackgroundColor(id, r, g, b [, a])

--! @param id: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
WarMenu.SetMenuTitleBackgroundColor(id, r, g, b [, a])

--! @param id: string
--! @param dict: string
--! @param name: string
WarMenu.SetMenuTitleBackgroundSprite(id, dict, name)

--! @param id: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
WarMenu.SetMenuBackgroundColor(id, r, g, b [, a])

--! @param id: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
WarMenu.SetMenuTextColor(id, r, g, b [, a])

--! @param id: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
WarMenu.SetMenuSubTextColor(id, r, g, b [, a])

--! @param id: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
WarMenu.SetMenuFocusColor(id, r, g, b [, a])

--! @param id: string
--! @param r: number
--! @param g: number
--! @param b: number
--! @param a: number
WarMenu.SetMenuFocusTextColor(id, r, g, b [, a])

--! @param id: string
--! @param name: string
--! @param set: string
--! @comment List of sounds from decompiled scripts: https://pastebin.com/0neZdsZ5
WarMenu.SetMenuButtonPressedSound(id, name, set)
```
