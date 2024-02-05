local wasInitialized = false

local items = { 'F', 'I', 'V', 'E', 'M' }
local state = {}

local function uiThread()
	while true do
		if WarMenu.Begin('warmenuDemo') then
			WarMenu.MenuButton('Controls', 'warmenuDemo_controls')
			WarMenu.MenuButton('~r~Exit', 'warmenuDemo_exit')

			WarMenu.End()
		elseif WarMenu.Begin('warmenuDemo_controls') then
			WarMenu.Button('Button', 'Subtext')
			if WarMenu.IsItemHovered() then
				WarMenu.ToolTip('Tooltip example.')
			end

			local isPressed, inputText = WarMenu.InputButton('InputButton', nil, state.inputText)
			if isPressed and inputText then
				state.inputText = inputText
			end

			if WarMenu.SpriteButton('SpriteButton', 'commonmenu', state.useAltSprite and 'shop_gunclub_icon_b' or 'shop_garage_icon_b') then
				state.useAltSprite = not state.useAltSprite
			end

			if WarMenu.CheckBox('CheckBox', state.isChecked) then
				state.isChecked = not state.isChecked
			end

			local _, currentIndex = WarMenu.ComboBox('ComboBox', items, state.currentIndex)
			state.currentIndex = currentIndex

			WarMenu.End()
		elseif WarMenu.Begin('warmenuDemo_exit') then
			WarMenu.MenuButton('No', 'warmenuDemo')

			if WarMenu.Button('~r~Yes') then
				WarMenu.CloseMenu()
			end

			WarMenu.End()
		end

		Wait(0)
	end
end

RegisterCommand('warmenuDemo', function()
	if WarMenu.IsAnyMenuOpened() then
		return
	end

	if not wasInitialized then
		WarMenu.CreateMenu('warmenuDemo', 'WarMenu Demo', 'Created by Warxander')

		WarMenu.CreateSubMenu('warmenuDemo_controls', 'warmenuDemo', 'Controls')
		WarMenu.CreateSubMenu('warmenuDemo_exit', 'warmenuDemo', 'Are you sure?')

		Citizen.CreateThread(uiThread)

		wasInitialized = true
	end

	state = {
		useAltSprite = false,
		isChecked = false,
		currentIndex = 1
	}

	WarMenu.OpenMenu('warmenuDemo')
end)
