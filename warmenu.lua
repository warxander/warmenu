WarMenu = { }
WarMenu.__index = WarMenu

-- Deprecated
WarMenu.debug = false
function WarMenu.SetDebugEnabled(enabled)
end
function WarMenu.IsDebugEnabled()
	return false
end
---

local menus = { }
local keys = { up = 188, down = 187, left = 189, right = 190, select = 201, back = 202 }
local optionCount = 0

local currentKey = nil
local currentMenu = nil

local toolTipWidth = 0.153

local spriteWidth = 0.027
local spriteHeight = spriteWidth * GetAspectRatio()

local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local buttonHeight = 0.038
local buttonFont = 0
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005
local buttonSpriteXOffset = 0.002
local buttonSpriteYOffset = 0.005

local function setMenuProperty(id, property, value)
	if not id then
		return
	end

	local menu = menus[id]
	if menu then
		menu[property] = value
	end
end

local function setMenuVisible(id, visible, holdCurrentOption)
	if visible then
		if currentMenu == id then
			return
		end
	else
		if currentMenu ~= id then
			return
		end
	end

	if visible then
		if not currentMenu then
			menus[id].currentOption = 1
		else
			if not holdCurrentOption then
				menus[currentMenu].currentOption = 1
			end
			setMenuVisible(currentMenu, false)
		end

		currentMenu = id
	else
		currentMenu = nil
	end
end

local function setTextParams(font, color, scale, center, shadow, alignRight, wrapFrom, wrapTo)
	SetTextFont(font)
	SetTextColour(color[1], color[2], color[3], color[4] or 255)
	SetTextScale(scale, scale)

	if shadow then
		SetTextDropShadow()
	end

	if center then
		SetTextCentre(center)
	elseif alignRight then
		SetTextRightJustify(true)
	end

	if not wrapFrom or not wrapTo then
		local menu = menus[currentMenu]
		wrapFrom = wrapFrom or menu.x
		wrapTo = wrapTo or menu.x + menu.width - buttonTextXOffset
	end

	SetTextWrap(wrapFrom, wrapTo)
end

local function getLinesCount(text, x, y)
	BeginTextCommandLineCount('STRING')
	AddTextComponentString(tostring(text))
	return EndTextCommandGetLineCount(x, y)
end

local function drawText(text, x, y)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentString(tostring(text))
	EndTextCommandDisplayText(x, y)
end

local function drawRect(x, y, width, height, color)
	DrawRect(x, y, width, height, color[1], color[2], color[3], color[4] or 255)
end

local function getCurrentIndex(menu)
	if menu.currentOption <= menu.maxOptionCount and optionCount <= menu.maxOptionCount then
		return optionCount
	elseif optionCount > menu.currentOption - menu.maxOptionCount and optionCount <= menu.currentOption then
		return optionCount - (menu.currentOption - menu.maxOptionCount)
	end

	return nil
end

local function drawTitle()
	local menu = menus[currentMenu]

	local x = menu.x + menu.width / 2
	local y = menu.y + titleHeight / 2

	if menu.titleBackgroundSprite then
		DrawSprite(menu.titleBackgroundSprite.dict, menu.titleBackgroundSprite.name, x, y, menu.width, titleHeight, 0., 255, 255, 255, 255)
	else
		drawRect(x, y, menu.width, titleHeight, menu.titleBackgroundColor)
	end

	setTextParams(menu.titleFont, menu.titleColor, titleScale, true)
	drawText(menu.title, x, y - titleHeight / 2 + titleYOffset)
end

local function drawSubTitle()
	local menu = menus[currentMenu]

	local x = menu.x + menu.width / 2
	local y = menu.y + titleHeight + buttonHeight / 2
	local subTitleColor = menu.subTitleColor or menu.titleBackgroundColor

	drawRect(x, y, menu.width, buttonHeight, menu.subTitleBackgroundColor)

	setTextParams(buttonFont, subTitleColor, buttonScale, false)
	drawText(menu.subTitle, menu.x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset)

	if optionCount > menu.maxOptionCount then
		setTextParams(buttonFont, subTitleColor, buttonScale, false, false, true)
		drawText(tostring(menu.currentOption)..' / '..tostring(optionCount), menu.x + menu.width, y - buttonHeight / 2 + buttonTextYOffset)
	end
end

local function drawButton(text, subText)
	local menu = menus[currentMenu]

	local currentIndex = getCurrentIndex(menu)
	if not currentIndex then
		return
	end

	local backgroundColor = nil
	local textColor = nil
	local subTextColor = nil
	local shadow = false

	if menu.currentOption == optionCount then
		backgroundColor = menu.focusColor
		textColor = menu.focusTextColor
		subTextColor = menu.focusTextColor
	else
		backgroundColor = menu.backgroundColor
		textColor = menu.textColor
		subTextColor = menu.subTextColor
		shadow = true
	end

	local x = menu.x + menu.width / 2
	local y = menu.y + titleHeight + buttonHeight + (buttonHeight * currentIndex) - buttonHeight / 2

	drawRect(x, y, menu.width, buttonHeight, backgroundColor)

	setTextParams(buttonFont, textColor, buttonScale, false, shadow)
	drawText(text, menu.x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset)

	if subText then
		setTextParams(buttonFont, subTextColor, buttonScale, false, shadow, true)
		drawText(subText, menu.x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset)
	end
end

function WarMenu.CreateMenu(id, title)
	-- Default settings
	local menu = { }

	menu.title = title
	menu.subTitle = 'INTERACTION MENU'

	menu.previousMenu = nil

	menu.aboutToBeClosed = false

	menu.x = 0.0175
	menu.y = 0.025
	menu.width = 0.23

	menu.currentOption = 1
	menu.maxOptionCount = 10

	menu.titleFont = 1
	menu.titleColor = { 0, 0, 0, 255 }
	menu.titleBackgroundColor = { 245, 127, 23, 255 }
	menu.titleBackgroundSprite = nil

	menu.textColor = { 255, 255, 255, 255 }
	menu.subTextColor = { 189, 189, 189, 255 }
	menu.focusTextColor = { 0, 0, 0, 255 }
	menu.focusColor = { 245, 245, 245, 255 }
	menu.backgroundColor = { 0, 0, 0, 160 }
	menu.subTitleBackgroundColor = { 0, 0, 0, 255 }

	menu.buttonPressedSound = { name = 'SELECT', set = 'HUD_FRONTEND_DEFAULT_SOUNDSET' } --https://pastebin.com/0neZdsZ5

	menus[id] = menu
end

function WarMenu.CreateSubMenu(id, parent, subTitle)
	local parentMenu = menus[parent]
	if not parentMenu then
		return
	end

	WarMenu.CreateMenu(id, parentMenu.title)

	local menu = menus[id]
	menu.previousMenu = parent
	menu.subTitle = subTitle and string.upper(subTitle) or string.upper(parentMenu.subTitle)
	menu.x = parentMenu.x
	menu.y = parentMenu.y
	menu.maxOptionCount = parentMenu.maxOptionCount
	menu.titleFont = parentMenu.titleFont
	menu.titleColor = parentMenu.titleColor
	menu.titleBackgroundColor = parentMenu.titleBackgroundColor
	menu.titleBackgroundSprite = parentMenu.titleBackgroundSprite
	menu.subTitleColor = parentMenu.subTitleColor
	menu.textColor = parentMenu.textColor
	menu.subTextColor = parentMenu.subTextColor
	menu.focusTextColor = parentMenu.focusTextColor
	menu.focusColor = parentMenu.focusColor
	menu.backgroundColor = parentMenu.backgroundColor
	menu.subTitleBackgroundColor = parentMenu.subTitleBackgroundColor
end

function WarMenu.CurrentMenu()
	return currentMenu
end

function WarMenu.OpenMenu(id)
	if id and menus[id] then
		PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
		setMenuVisible(id, true)
	end
end

function WarMenu.IsMenuOpened(id)
	return currentMenu == id
end

function WarMenu.IsAnyMenuOpened()
	return currentMenu ~= nil
end

function WarMenu.IsMenuAboutToBeClosed()
	local menu = menus[currentMenu]
	if menu then
		return menu.aboutToBeClosed
	else
		return false
	end
end

function WarMenu.CloseMenu()
	local menu = menus[currentMenu]
	if menu then
		if menu.aboutToBeClosed then
			menu.aboutToBeClosed = false
			setMenuVisible(currentMenu, false)
			optionCount = 0
			currentKey = nil
			PlaySoundFrontend(-1, 'QUIT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
		else
			menu.aboutToBeClosed = true
		end
	end
end

function WarMenu.ToolTip(text, width, flipHorizontal)
	local menu = menus[currentMenu]

	local currentIndex = getCurrentIndex(menu)
	if not currentIndex then
		return
	end

	width = width or toolTipWidth

	local x = nil
	if not flipHorizontal then
		x = menu.x + menu.width + width / 2 + buttonTextXOffset
	else
		x = menu.x - width / 2 - buttonTextXOffset
	end

	local textX = x - (width / 2) + buttonTextXOffset
	setTextParams(buttonFont, menu.textColor, buttonScale, false, true, false, textX, textX + width - (buttonTextYOffset * 2))
	local linesCount = getLinesCount(text, textX, menu.y)

	local height = GetTextScaleHeight(buttonScale, buttonFont) * (linesCount + 1) + buttonTextYOffset
	local y = menu.y + titleHeight + (buttonHeight * currentIndex) + height / 2

	drawRect(x, y, width, height, menu.backgroundColor)

	y = y - (height / 2) + buttonTextYOffset
	drawText(text, textX, y)
end

function WarMenu.Button(text, subText)
	optionCount = optionCount + 1

	drawButton(text, subText)

	local pressed = false

	local menu = menus[currentMenu]
	if menu.currentOption == optionCount then
		if currentKey == keys.select then
			pressed = true
			PlaySoundFrontend(-1, menu.buttonPressedSound.name, menu.buttonPressedSound.set, true)
		elseif currentKey == keys.left or currentKey == keys.right then
			PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
		end
	end

	return pressed
end

function WarMenu.SpriteButton(text, dict, name, r, g, b, a)
	local menu = menus[currentMenu]

	local pressed = WarMenu.Button(text)

	local currentIndex = getCurrentIndex(menu)
	if not currentIndex then
		return
	end

	if not HasStreamedTextureDictLoaded(dict) then
		RequestStreamedTextureDict(dict)
	end
	DrawSprite(dict, name, menu.x + menu.width - spriteWidth / 2 - buttonSpriteXOffset, menu.y + titleHeight + buttonHeight + (buttonHeight * currentIndex) - spriteHeight / 2 + buttonSpriteYOffset, spriteWidth, spriteHeight, 0., r or 255, g or 255, b or 255, a or 255)

	return pressed
end

function WarMenu.MenuButton(text, id, subText)
	local pressed = WarMenu.Button(text, subText)

	if pressed then
		menus[currentMenu].currentOption = optionCount
		setMenuVisible(currentMenu, false)
		setMenuVisible(id, true, true)
	end

	return pressed
end

function WarMenu.CheckBox(text, checked, callback)
	local name = nil
	if menus[currentMenu].currentOption == optionCount + 1 then
		name = checked and 'shop_box_tickb' or 'shop_box_blankb'
	else
		name = checked and 'shop_box_tick' or 'shop_box_blank'
	end

	local pressed = WarMenu.SpriteButton(text, 'commonmenu', name)

	if pressed then
		checked = not checked
		if callback then callback(checked) end
	end

	return pressed
end

function WarMenu.ComboBox(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == optionCount + 1
	selectedIndex = selectedIndex or currentIndex

	if itemsCount > 1 and isCurrent then
		selectedItem = '← '..tostring(selectedItem)..' →'
	end

	local pressed = WarMenu.Button(text, selectedItem)

	if pressed then
		selectedIndex = currentIndex
	elseif isCurrent then
		if currentKey == keys.left then
			if currentIndex > 1 then currentIndex = currentIndex - 1 else currentIndex = itemsCount end
		elseif currentKey == keys.right then
			if currentIndex < itemsCount then currentIndex = currentIndex + 1 else currentIndex = 1 end
		end
	end

	if callback then callback(currentIndex, selectedIndex) end
	return pressed, currentIndex
end

function WarMenu.Display()
	if currentMenu then
		DisableControlAction(0, keys.left, true)
		DisableControlAction(0, keys.up, true)
		DisableControlAction(0, keys.down, true)
		DisableControlAction(0, keys.right, true)
		DisableControlAction(0, keys.back, true)
		DisableControlAction(0, keys.select, true)

		local menu = menus[currentMenu]

		if menu.aboutToBeClosed then
			WarMenu.CloseMenu()
		else
			ClearAllHelpMessages()

			drawTitle()
			drawSubTitle()

			currentKey = nil

			if IsDisabledControlJustReleased(0, keys.down) then
				PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)

				if menu.currentOption < optionCount then
					menu.currentOption = menu.currentOption + 1
				else
					menu.currentOption = 1
				end
			elseif IsDisabledControlJustReleased(0, keys.up) then
				PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)

				if menu.currentOption > 1 then
					menu.currentOption = menu.currentOption - 1
				else
					menu.currentOption = optionCount
				end
			elseif IsDisabledControlJustReleased(0, keys.left) then
				currentKey = keys.left
			elseif IsDisabledControlJustReleased(0, keys.right) then
				currentKey = keys.right
			elseif IsDisabledControlJustReleased(0, keys.select) then
				currentKey = keys.select
			elseif IsDisabledControlJustReleased(0, keys.back) then
				if menus[menu.previousMenu] then
					setMenuVisible(menu.previousMenu, true)
					PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
				else
					WarMenu.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end

function WarMenu.CurrentOption()
	if currentMenu and optionCount ~= 0 and menus[currentMenu] then
		return menus[currentMenu].currentOption
	end

	return nil
end

function WarMenu.IsItemHovered()
	if not currentMenu or optionCount == 0 then
		return false
	end

	return menus[currentMenu].currentOption == optionCount
end

function WarMenu.IsItemSelected()
	return currentKey == keys.select and WarMenu.IsItemHovered()
end

function WarMenu.SetMenuWidth(id, width)
	setMenuProperty(id, 'width', width)
end

function WarMenu.SetMenuX(id, x)
	setMenuProperty(id, 'x', x)
end

function WarMenu.SetMenuY(id, y)
	setMenuProperty(id, 'y', y)
end

function WarMenu.SetMenuMaxOptionCountOnScreen(id, count)
	setMenuProperty(id, 'maxOptionCount', count)
end

function WarMenu.SetTitle(id, title)
	setMenuProperty(id, 'title', title)
end
WarMenu.SetMenuTitle = WarMenu.SetTitle

function WarMenu.SetTitleColor(id, r, g, b, a)
	setMenuProperty(id, 'titleColor', { r, g, b, a or menus[id].titleColor[4] })
end
WarMenu.SetMenuTitleColor = WarMenu.SetTitleColor

function WarMenu.SetMenuSubTitleColor(id, r, g, b, a)
	setMenuProperty(id, 'subTitleColor', { r, g, b, a or 255 })
end

function WarMenu.SetTitleBackgroundColor(id, r, g, b, a)
	setMenuProperty(id, 'titleBackgroundColor', { r, g, b, a or menus[id].titleBackgroundColor[4] })
end
WarMenu.SetMenuTitleBackgroundColor = WarMenu.SetTitleBackgroundColor

function WarMenu.SetTitleBackgroundSprite(id, textureDict, textureName)
	RequestStreamedTextureDict(textureDict)
	setMenuProperty(id, 'titleBackgroundSprite', { dict = textureDict, name = textureName })
end
WarMenu.SetMenuTitleBackgroundSprite = WarMenu.SetTitleBackgroundSprite

function WarMenu.SetSubTitle(id, text)
	setMenuProperty(id, 'subTitle', string.upper(text))
end
WarMenu.SetMenuSubTitle = WarMenu.SetSubTitle

function WarMenu.SetMenuBackgroundColor(id, r, g, b, a)
	setMenuProperty(id, 'backgroundColor', { r, g, b, a or menus[id].backgroundColor[4] })
end

function WarMenu.SetMenuTextColor(id, r, g, b, a)
	setMenuProperty(id, 'textColor', { r, g, b, a or menus[id].textColor[4] })
end

function WarMenu.SetMenuSubTextColor(id, r, g, b, a)
	setMenuProperty(id, 'subTextColor', { r, g, b, a or menus[id].subTextColor[4] })
end

function WarMenu.SetMenuFocusColor(id, r, g, b, a)
	setMenuProperty(id, 'focusColor', { r, g, b, a or menus[id].focusColor[4] })
end

function WarMenu.SetMenuFocusTextColor(id, r, g, b, a)
	setMenuProperty(id, 'focusTextColor', { r, g, b, a or menus[id].focusTextColor[4] })
end

function WarMenu.SetMenuButtonPressedSound(id, name, set)
	setMenuProperty(id, 'buttonPressedSound', { name = name, set = set })
end
