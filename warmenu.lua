-- Copyright (c) 2017 - 2024, Warxander, https://github.com/warxander
-- Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted,
-- provided that the above copyright notice and this permission notice appear in all copies.
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.
-- IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
-- WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


WarMenu = {}
WarMenu.__index = WarMenu

--! @deprecated
function WarMenu.SetDebugEnabled()
end

--! @deprecated
function WarMenu.IsDebugEnabled()
	return false
end

--! @deprecated
function WarMenu.IsMenuAboutToBeClosed()
	return false
end

local keys = { down = 187, scrollDown = 242, up = 188, scrollUp = 241, left = 189, right = 190, select = 191, accept = 237, back = 194, cancel = 238 }

local toolTipWidth = 0.153

local buttonSpriteWidth = 0.027

local titleHeight = 0.101
local titleYOffset = 0.021
local titleFont = 1
local titleScale = 1.0

local buttonHeight = 0.038
local buttonFont = 0
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005
local buttonSpriteXOffset = 0.002
local buttonSpriteYOffset = 0.005

local defaultStyle = {
	x = 0.0175,
	y = 0.025,
	width = 0.23,
	maxOptionCountOnScreen = 10,
	titleVisible = true,
	titleColor = { 0, 0, 0, 255 },
	titleBackgroundColor = { 245, 127, 23, 255 },
	titleBackgroundSprite = nil,
	subTitleColor = { 245, 127, 23, 255 },
	textColor = { 254, 254, 254, 255 },
	subTextColor = { 189, 189, 189, 255 },
	focusTextColor = { 0, 0, 0, 255 },
	focusColor = { 245, 245, 245, 255 },
	backgroundColor = { 0, 0, 0, 160 },
	subTitleBackgroundColor = { 0, 0, 0, 255 },
	buttonPressedSound = { name = 'SELECT', set = 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
}

local menus = {}

local skipInputNextFrame = true

local currentMenu = nil
local currentKey = nil
local currentOptionCount = 0

local function isNavigatedDown()
	return IsControlJustReleased(2, keys.down) or IsControlJustReleased(2, keys.scrollDown)
end

local function isNavigatedUp()
	return IsControlJustReleased(2, keys.up) or IsControlJustReleased(2, keys.scrollUp)
end

local function isSelectedPressed()
	return IsControlJustReleased(2, keys.select) or IsControlJustReleased(2, keys.accept)
end

local function isBackPressed()
	return IsControlJustReleased(2, keys.back) or IsControlJustReleased(2, keys.cancel)
end

local function setMenuProperty(id, property, value)
	if not id then
		return
	end

	local menu = menus[id]
	if menu then
		menu[property] = value
	end
end

local function setStyleProperty(id, property, value)
	if not id then
		return
	end

	local menu = menus[id]

	if menu then
		if not menu.overrideStyle then
			menu.overrideStyle = {}
		end

		menu.overrideStyle[property] = value
	end
end

local function getStyleProperty(property, menu)
	local usedMenu = menu or currentMenu

	if usedMenu.overrideStyle then
		local value = usedMenu.overrideStyle[property]
		if value ~= nil then
			return value
		end
	end

	return usedMenu.style and usedMenu.style[property] or defaultStyle[property]
end

local function getTitleHeight()
	return getStyleProperty('titleVisible') and titleHeight or 0
end

local function copyTable(t)
	if type(t) ~= 'table' then
		return t
	end

	local result = {}
	for k, v in pairs(t) do
		result[k] = copyTable(v)
	end

	return result
end

local function setMenuVisible(id, visible, holdOptionIndex)
	if currentMenu then
		if visible then
			if currentMenu.id == id then
				return
			end
		else
			if currentMenu.id ~= id then
				return
			end
		end
	end

	if visible then
		local menu = menus[id]

		if not currentMenu then
			menu.optionIndex = 1
		else
			if not holdOptionIndex then
				menus[currentMenu.id].optionIndex = 1
			end
		end

		currentMenu = menu
		skipInputNextFrame = true

		SetUserRadioControlEnabled(false)
		HudWeaponWheelIgnoreControlInput(true)
	else
		HudWeaponWheelIgnoreControlInput(false)
		SetUserRadioControlEnabled(true)

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
		SetTextCentre(true)
	elseif alignRight then
		SetTextRightJustify(true)
	end

	SetTextWrap(wrapFrom or getStyleProperty('x'),
		wrapTo or (getStyleProperty('x') + getStyleProperty('width') - buttonTextXOffset))
end

local function getLinesCount(text, x, y)
	BeginTextCommandLineCount('TWOSTRINGS')
	AddTextComponentString(tostring(text))
	return EndTextCommandGetLineCount(x, y)
end

local function drawText(text, x, y)
	BeginTextCommandDisplayText('TWOSTRINGS')
	AddTextComponentString(tostring(text))
	EndTextCommandDisplayText(x, y)
end

local function drawRect(x, y, width, height, color)
	DrawRect(x, y, width, height, color[1], color[2], color[3], color[4] or 255)
end

local function getCurrentOptionIndex()
	if not currentMenu then error('getCurrentOptionIndex() failed: No current menu') end

	local maxOptionCount = getStyleProperty('maxOptionCountOnScreen')
	if currentMenu.optionIndex <= maxOptionCount and currentOptionCount <= maxOptionCount then
		return currentOptionCount
	elseif currentOptionCount > currentMenu.optionIndex - maxOptionCount and currentOptionCount <= currentMenu.optionIndex then
		return currentOptionCount - (currentMenu.optionIndex - maxOptionCount)
	end

	return nil
end

local function drawTitle()
	if not currentMenu then error('drawTitle() failed: No current menu') end

	if not getStyleProperty('titleVisible') then
		return
	end

	local width = getStyleProperty('width')
	local x = getStyleProperty('x') + width / 2
	local y = getStyleProperty('y') + titleHeight / 2

	local backgroundSprite = getStyleProperty('titleBackgroundSprite')
	if backgroundSprite then
		DrawSprite(backgroundSprite.dict, backgroundSprite.name, x, y,
			width, titleHeight, 0., 255, 255, 255, 255)
	else
		drawRect(x, y, width, titleHeight, getStyleProperty('titleBackgroundColor'))
	end

	if currentMenu.title then
		setTextParams(titleFont, getStyleProperty('titleColor'), titleScale, true)
		drawText(currentMenu.title, x, y - titleHeight / 2 + titleYOffset)
	end
end

local function drawSubTitle()
	if not currentMenu then error('drawSubTitle() failed: No current menu') end

	local width = getStyleProperty('width')
	local styleX = getStyleProperty('x')
	local x = styleX + width / 2
	local y = getStyleProperty('y') + getTitleHeight() + buttonHeight / 2
	local subTitleColor = getStyleProperty('subTitleColor')

	drawRect(x, y, width, buttonHeight, getStyleProperty('subTitleBackgroundColor'))

	setTextParams(buttonFont, subTitleColor, buttonScale, false)
	drawText(currentMenu.subTitle, styleX + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset)

	if currentOptionCount > getStyleProperty('maxOptionCountOnScreen') then
		setTextParams(buttonFont, subTitleColor, buttonScale, false, false, true)
		drawText(tostring(currentMenu.optionIndex) .. ' / ' .. tostring(currentOptionCount),
			styleX + width, y - buttonHeight / 2 + buttonTextYOffset)
	end
end

local function drawButton(text, subText)
	if not currentMenu then error('drawButton() failed: No current menu') end

	local optionIndex = getCurrentOptionIndex()
	if not optionIndex then
		return
	end

	local backgroundColor = nil
	local textColor = nil
	local subTextColor = nil
	local shadow = false

	if currentMenu.optionIndex == currentOptionCount then
		backgroundColor = getStyleProperty('focusColor')
		textColor = getStyleProperty('focusTextColor')
		subTextColor = getStyleProperty('focusTextColor')
	else
		backgroundColor = getStyleProperty('backgroundColor')
		textColor = getStyleProperty('textColor')
		subTextColor = getStyleProperty('subTextColor')
		shadow = true
	end

	local width = getStyleProperty('width')
	local styleX = getStyleProperty('x')
	local halfButtonHeight = buttonHeight / 2
	local x = styleX + width / 2
	local y = getStyleProperty('y') + getTitleHeight() + buttonHeight + (buttonHeight * optionIndex) - halfButtonHeight

	drawRect(x, y, width, buttonHeight, backgroundColor)

	setTextParams(buttonFont, textColor, buttonScale, false, shadow)
	drawText(text, styleX + buttonTextXOffset, y - halfButtonHeight + buttonTextYOffset)

	if subText then
		setTextParams(buttonFont, subTextColor, buttonScale, false, shadow, true)
		drawText(subText, styleX + buttonTextXOffset, y - halfButtonHeight + buttonTextYOffset)
	end
end

function WarMenu.CreateMenu(id, title, subTitle, style)
	local menu = {}

	menu.id = id
	menu.parentId = nil
	menu.optionIndex = 1
	menu.title = title
	menu.subTitle = subTitle and string.upper(subTitle) or 'INTERACTION MENU'

	if style then
		menu.style = style
	end

	menus[id] = menu
end

function WarMenu.CreateSubMenu(id, parentId, subTitle, style)
	local parentMenu = menus[parentId]
	if not parentMenu then
		return
	end

	WarMenu.CreateMenu(id, parentMenu.title, subTitle and string.upper(subTitle) or parentMenu.subTitle)

	local menu = menus[id]

	menu.parentId = parentId

	if parentMenu.overrideStyle then
		menu.overrideStyle = copyTable(parentMenu.overrideStyle)
	end

	if style then
		menu.style = style
	elseif parentMenu.style then
		menu.style = copyTable(parentMenu.style)
	end
end

function WarMenu.CurrentMenu()
	return currentMenu and currentMenu.id or nil
end

function WarMenu.OpenMenu(id)
	if id and menus[id] then
		PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
		setMenuVisible(id, true, true)
	end
end

function WarMenu.IsMenuOpened(id)
	return currentMenu and currentMenu.id == id
end

WarMenu.Begin = WarMenu.IsMenuOpened

function WarMenu.IsAnyMenuOpened()
	return currentMenu ~= nil
end

function WarMenu.CloseMenu()
	if not currentMenu then return end

	setMenuVisible(currentMenu.id, false)
	currentOptionCount = 0
	currentKey = nil
	PlaySoundFrontend(-1, 'QUIT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

function WarMenu.ToolTip(text, width, flipHorizontal)
	if not currentMenu then
		return
	end

	local optionIndex = getCurrentOptionIndex()
	if not optionIndex then
		return
	end

	local tipWidth = width or toolTipWidth
	local halfTipWidth = tipWidth / 2
	local x = nil
	local y = getStyleProperty('y')

	if not flipHorizontal then
		x = getStyleProperty('x') + getStyleProperty('width') + halfTipWidth + buttonTextXOffset
	else
		x = getStyleProperty('x') - halfTipWidth - buttonTextXOffset
	end

	local textX = x - halfTipWidth + buttonTextXOffset
	setTextParams(buttonFont, getStyleProperty('textColor'), buttonScale, false, true, false, textX,
		textX + tipWidth - (buttonTextYOffset * 2))
	local linesCount = getLinesCount(text, textX, y)

	local height = GetTextScaleHeight(buttonScale, buttonFont) * (linesCount + 1) + buttonTextYOffset
	local halfHeight = height / 2
	y = y + getTitleHeight() + (buttonHeight * optionIndex) + halfHeight

	drawRect(x, y, tipWidth, height, getStyleProperty('backgroundColor'))

	y = y - halfHeight + buttonTextYOffset
	drawText(text, textX, y)
end

function WarMenu.Button(text, subText)
	if not currentMenu then
		return
	end

	currentOptionCount = currentOptionCount + 1

	drawButton(text, subText)

	local pressed = false

	if currentMenu.optionIndex == currentOptionCount then
		if currentKey == keys.select then
			local buttonPressedSound = getStyleProperty('buttonPressedSound')
			if buttonPressedSound then
				PlaySoundFrontend(-1, buttonPressedSound.name, buttonPressedSound.set, true)
			end

			pressed = true
		elseif currentKey == keys.left or currentKey == keys.right then
			PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
		end
	end

	return pressed
end

function WarMenu.SpriteButton(text, dict, name, r, g, b, a)
	if not currentMenu then
		return
	end

	local pressed = WarMenu.Button(text)

	local optionIndex = getCurrentOptionIndex()
	if not optionIndex then
		return
	end

	if not HasStreamedTextureDictLoaded(dict) then
		RequestStreamedTextureDict(dict)
	end

	local buttonSpriteHeight = buttonSpriteWidth * GetAspectRatio()
	DrawSprite(dict, name,
		getStyleProperty('x') + getStyleProperty('width') - buttonSpriteWidth / 2 - buttonSpriteXOffset,
		getStyleProperty('y') + getTitleHeight() + buttonHeight + (buttonHeight * optionIndex) - buttonSpriteHeight / 2 +
		buttonSpriteYOffset, buttonSpriteWidth, buttonSpriteHeight, 0., r or 255, g or 255, b or 255, a or 255)

	return pressed
end

function WarMenu.InputButton(text, windowTitleEntry, defaultText, maxLength, subText)
	if not currentMenu then
		return
	end

	local pressed = WarMenu.Button(text, subText)
	local inputText = nil

	if pressed then
		DisplayOnscreenKeyboard(1, windowTitleEntry or 'FMMC_MPM_NA', '', defaultText or '', '', '', '', maxLength or 255)

		while true do
			local status = UpdateOnscreenKeyboard()
			if status == 2 then
				break
			elseif status == 1 then
				inputText = GetOnscreenKeyboardResult()
				break
			end

			Citizen.Wait(0)
		end
	end

	return pressed, inputText
end

function WarMenu.MenuButton(text, id, subText)
	if not currentMenu then
		return
	end

	local pressed = WarMenu.Button(text, subText)

	if pressed then
		currentMenu.optionIndex = currentOptionCount
		setMenuVisible(currentMenu.id, false)
		setMenuVisible(id, true, true)
	end

	return pressed
end

function WarMenu.CheckBox(text, checked)
	if not currentMenu then
		return
	end

	local name = nil
	if currentMenu.optionIndex == currentOptionCount + 1 then
		name = checked and 'shop_box_tickb' or 'shop_box_blankb'
	else
		name = checked and 'shop_box_tick' or 'shop_box_blank'
	end

	return WarMenu.SpriteButton(text, 'commonmenu', name)
end

function WarMenu.ComboBox(text, items, currentIndex)
	if not currentMenu then
		return
	end

	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = currentMenu.optionIndex == currentOptionCount + 1

	if itemsCount > 1 and isCurrent then
		selectedItem = '← ' .. tostring(selectedItem) .. ' →'
	end

	local pressed = WarMenu.Button(text, selectedItem)

	if not pressed and isCurrent then
		if currentKey == keys.left then
			if currentIndex > 1 then currentIndex = currentIndex - 1 else currentIndex = itemsCount end
		elseif currentKey == keys.right then
			if currentIndex < itemsCount then currentIndex = currentIndex + 1 else currentIndex = 1 end
		end
	end

	return pressed, currentIndex
end

function WarMenu.Display()
	if not currentMenu then
		return
	end

	if not IsPauseMenuActive() then
		ClearAllHelpMessages()
		HudWeaponWheelIgnoreSelection()
		DisablePlayerFiring(PlayerId(), true)
		DisableControlAction(0, 25, true)

		drawTitle()
		drawSubTitle()

		currentKey = nil

		if skipInputNextFrame then
			skipInputNextFrame = false
		else
			if isNavigatedDown() then
				PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)

				if currentMenu.optionIndex < currentOptionCount then
					currentMenu.optionIndex = currentMenu.optionIndex + 1
				else
					currentMenu.optionIndex = 1
				end
			elseif isNavigatedUp() then
				PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)

				if currentMenu.optionIndex > 1 then
					currentMenu.optionIndex = currentMenu.optionIndex - 1
				else
					currentMenu.optionIndex = currentOptionCount
				end
			elseif IsControlJustReleased(2, keys.left) then
				currentKey = keys.left
			elseif IsControlJustReleased(2, keys.right) then
				currentKey = keys.right
			elseif isSelectedPressed() then
				currentKey = keys.select
			elseif isBackPressed() then
				if menus[currentMenu.parentId] then
					setMenuVisible(currentMenu.parentId, true)
					PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
				else
					WarMenu.CloseMenu()
				end
			end
		end
	end

	currentOptionCount = 0
end

WarMenu.End = WarMenu.Display

function WarMenu.CurrentOption()
	if currentMenu and currentOptionCount ~= 0 then
		return currentMenu.optionIndex
	end

	return nil
end

WarMenu.OptionIndex = WarMenu.CurrentOption

function WarMenu.IsItemHovered()
	if not currentMenu or currentOptionCount == 0 then
		return false
	end

	return currentMenu.optionIndex == currentOptionCount
end

function WarMenu.IsItemSelected()
	return currentKey == keys.select and WarMenu.IsItemHovered()
end

function WarMenu.SetTitle(id, title)
	setMenuProperty(id, 'title', title)
end

WarMenu.SetMenuTitle = WarMenu.SetTitle

function WarMenu.SetSubTitle(id, subTitle)
	setMenuProperty(id, 'subTitle', string.upper(subTitle))
end

WarMenu.SetMenuSubTitle = WarMenu.SetSubTitle

function WarMenu.SetMenuStyle(id, style)
	setMenuProperty(id, 'style', style)
end

function WarMenu.SetMenuTitleVisible(id, visible)
	setStyleProperty(id, 'titleVisible', visible)
end

function WarMenu.SetMenuX(id, x)
	setStyleProperty(id, 'x', x)
end

function WarMenu.SetMenuY(id, y)
	setStyleProperty(id, 'y', y)
end

function WarMenu.SetMenuWidth(id, width)
	setStyleProperty(id, 'width', width)
end

function WarMenu.SetMenuMaxOptionCountOnScreen(id, optionCount)
	setStyleProperty(id, 'maxOptionCountOnScreen', optionCount)
end

function WarMenu.SetTitleColor(id, r, g, b, a)
	setStyleProperty(id, 'titleColor', { r, g, b, a })
end

WarMenu.SetMenuTitleColor = WarMenu.SetTitleColor

function WarMenu.SetMenuSubTitleColor(id, r, g, b, a)
	setStyleProperty(id, 'subTitleColor', { r, g, b, a })
end

function WarMenu.SetMenuSubTitleBackgroundColor(id, r, g, b, a)
	setStyleProperty(id, 'subTitleBackgroundColor', { r, g, b, a })
end

function WarMenu.SetTitleBackgroundColor(id, r, g, b, a)
	setStyleProperty(id, 'titleBackgroundColor', { r, g, b, a })
end

WarMenu.SetMenuTitleBackgroundColor = WarMenu.SetTitleBackgroundColor

function WarMenu.SetTitleBackgroundSprite(id, dict, name)
	RequestStreamedTextureDict(dict)
	setStyleProperty(id, 'titleBackgroundSprite', { dict = dict, name = name })
end

WarMenu.SetMenuTitleBackgroundSprite = WarMenu.SetTitleBackgroundSprite

function WarMenu.SetMenuBackgroundColor(id, r, g, b, a)
	setStyleProperty(id, 'backgroundColor', { r, g, b, a })
end

function WarMenu.SetMenuTextColor(id, r, g, b, a)
	setStyleProperty(id, 'textColor', { r, g, b, a })
end

function WarMenu.SetMenuSubTextColor(id, r, g, b, a)
	setStyleProperty(id, 'subTextColor', { r, g, b, a })
end

function WarMenu.SetMenuFocusColor(id, r, g, b, a)
	setStyleProperty(id, 'focusColor', { r, g, b, a })
end

function WarMenu.SetMenuFocusTextColor(id, r, g, b, a)
	setStyleProperty(id, 'focusTextColor', { r, g, b, a })
end

function WarMenu.SetMenuButtonPressedSound(id, name, set)
	setStyleProperty(id, 'buttonPressedSound', { name = name, set = set })
end
