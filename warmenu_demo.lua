local _isServer = IsDuplicityVersion()

if _isServer then
	RegisterCommand('warmenuDemo', function(source)
		if source > 0 then
			TriggerClientEvent('warmenu:showDemo', source)
		end
	end)
else
	-- Menu
	local _altX = false
	local _altY = false
	local _altWidth = false
	local _altTitle = false
	local _altSubTitle = false
	local _altMaxOption = false

	-- Controls
	local _inputText = nil

	local _altSprite = false

	local _comboBoxItems = { 'F', 'I', 'V', 'E', 'M' }
	local _comboBoxIndex = 1

	local _checked = false

	-- Style
	local _altTitleColor = false
	local _altSubTitleColor = false
	local _altTitleBackgroundColor = false
	local _altTitleBackgroundSprite = false
	local _altBackgroundColor = false
	local _altTextColor = false
	local _altSubTextColor = false
	local _altFocusColor = false
	local _altFocusTextColor = false
	local _altButtonSound = false

	WarMenu.CreateMenu('demo', 'Demo Menu', 'Thank you for using WarMenu')

	WarMenu.CreateSubMenu('demo_menu', 'demo', 'Menu')
	WarMenu.CreateSubMenu('demo_controls', 'demo', 'Controls')
	WarMenu.CreateSubMenu('demo_style', 'demo', 'Style')
	WarMenu.CreateSubMenu('demo_exit', 'demo', 'Are you sure?')

	RegisterNetEvent('warmenu:showDemo')
	AddEventHandler('warmenu:showDemo', function()
		if WarMenu.IsAnyMenuOpened() then
			return
		end

		WarMenu.OpenMenu('demo')

		while true do
			if WarMenu.Begin('demo') then
				WarMenu.MenuButton('Menu', 'demo_menu')
				WarMenu.MenuButton('Controls', 'demo_controls')
				WarMenu.MenuButton('Style', 'demo_style')
				WarMenu.MenuButton('Exit', 'demo_exit')

				WarMenu.End()
			elseif WarMenu.Begin('demo_menu') then
				WarMenu.End()
			elseif WarMenu.Begin('demo_controls') then
				WarMenu.Button('Button', 'Subtext')

				local pressed, inputText = WarMenu.InputButton('Input Button', nil, _inputText)
				if pressed then
					if inputText then
						_inputText = inputText
					end
				end

				if WarMenu.SpriteButton('Sprite Button', 'commonmenu', _altSprite and 'shop_gunclub_icon_b' or 'shop_garage_icon_b') then
					_altSprite = not _altSprite
				end

				WarMenu.Button('Single Line Tooltip')
				if WarMenu.IsItemHovered() then
					WarMenu.ToolTip('This is single line tooltip.')
				end

				WarMenu.Button('Multiline Tooltip')
				if WarMenu.IsItemHovered() then
					WarMenu.ToolTip('This is long enough multiline tooltip to test it.')
				end

				if WarMenu.CheckBox('Checkbox', _checked) then
					_checked = not _checked
				end

				local _, comboBoxIndex = WarMenu.ComboBox('Combobox', _comboBoxItems, _comboBoxIndex)
				if _comboBoxIndex ~= comboBoxIndex then
					_comboBoxIndex = comboBoxIndex
				end

				WarMenu.End()
			elseif WarMenu.Begin('demo_style') then
				WarMenu.End()
			elseif WarMenu.Begin('demo_exit') then
				WarMenu.MenuButton('No', 'demo')

				if WarMenu.Button('~r~Yes') then
					WarMenu.CloseMenu()
				end

				WarMenu.End()
			else
				return
			end

			Citizen.Wait(0)
		end
	end)
end
