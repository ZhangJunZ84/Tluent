local Root = script.Parent
local Themes = require(Root.Themes)
local Flipper = require(Root.Packages.Flipper)
local TweenService = game:GetService("TweenService")

local Creator = {
	Registry = {},
	Signals = {},
	TransparencyMotors = {},
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ScrollingFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ScrollBarImageColor3 = Color3.new(0, 0, 0),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.Roboto,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			TextSize = 16,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
			Font = Enum.Font.Roboto,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 16,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.Roboto,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 16,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
		},
		CanvasGroup = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
	},
}

Creator.Typography = {
	Display = { Font = Enum.Font.Roboto, Size = 36 },
	Headline = { Font = Enum.Font.Roboto, Size = 24 },
	Title = { Font = Enum.Font.Roboto, Size = 16, Weight = Enum.FontWeight.Medium },
	Label = { Font = Enum.Font.Roboto, Size = 14, Weight = Enum.FontWeight.Medium },
	Body = { Font = Enum.Font.Roboto, Size = 14 },
}

function Creator.CreateRipple(Button)
	Creator.AddSignal(Button.MouseButton1Down, function()
		local parentCorner = Button:FindFirstChildOfClass("UICorner")
		local cornerRadius = parentCorner and parentCorner.CornerRadius or UDim.new(0, 8)

		local Overlay = Creator.New("Frame", {
			Name = "ClickIndicator",
			Parent = Button,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.7,
			ZIndex = 100,
		})
		Creator.New("UICorner", { CornerRadius = cornerRadius, Parent = Overlay })
		Creator.AddThemeObject(Overlay, { BackgroundColor3 = "Hover" })

		local Tween = TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		})
		Tween:Play()
		
		Tween.Completed:Connect(function() 
			Overlay:Destroy() 
		end)
	end)
end

local function ApplyCustomProps(Object, Props)
	if Props.ThemeTag then
		Creator.AddThemeObject(Object, Props.ThemeTag)
	end
end

function Creator.AddSignal(Signal, Function)
	table.insert(Creator.Signals, Signal:Connect(Function))
end

function Creator.Disconnect()
	for Idx = #Creator.Signals, 1, -1 do
		local Connection = table.remove(Creator.Signals, Idx)
		Connection:Disconnect()
	end

	for Idx = #Creator.TransparencyMotors, 1, -1 do
		table.remove(Creator.TransparencyMotors, Idx)
	end
end

function Creator.GetThemeProperty(Property)
	local ThemeTable = Themes[require(Root).Theme] or Themes["Dark"]
	if ThemeTable[Property] then
		return ThemeTable[Property]
	end

	-- Fallbacks for new structural properties in case older themes do not define them
	if Property == "SidebarBackground" then
		return ThemeTable.DialogHolder or ThemeTable.AcrylicMain
	elseif Property == "ContentBackground" then
		return ThemeTable.AcrylicMain or ThemeTable.Dialog
	elseif Property == "SelectedTabBackground" then
		return ThemeTable.Dialog
	elseif Property == "SelectedTabText" then
		return ThemeTable.Accent or ThemeTable.Text
	end

	return Themes["Dark"][Property]
end

function Creator.UpdateTheme()
	for Instance, Object in next, Creator.Registry do
		for Property, ColorIdx in next, Object.Properties do
			if type(ColorIdx) == "function" then
				ColorIdx(Creator.GetThemeProperty)
			else
				Instance[Property] = Creator.GetThemeProperty(ColorIdx)
			end
		end
	end

	for _, Motor in next, Creator.TransparencyMotors do
		Motor:setGoal(Flipper.Instant.new(Creator.GetThemeProperty("ElementTransparency")))
	end
end

local function ApplyThemeToObject(Object, Properties)
	for Property, ColorIdx in next, Properties do
		if type(ColorIdx) == "function" then
			ColorIdx(Creator.GetThemeProperty)
		else
			Object[Property] = Creator.GetThemeProperty(ColorIdx)
		end
	end
end

function Creator.AddThemeObject(Object, Properties)
	local Idx = #Creator.Registry + 1
	local Data = {
		Object = Object,
		Properties = Properties,
		Idx = Idx,
	}

	Creator.Registry[Object] = Data
	ApplyThemeToObject(Object, Properties)
	return Object
end

function Creator.OverrideTag(Object, Properties)
	Creator.Registry[Object].Properties = Properties
	for Property, ColorIdx in next, Properties do
		if type(ColorIdx) == "function" then
			ColorIdx(Creator.GetThemeProperty)
		else
			Object[Property] = Creator.GetThemeProperty(ColorIdx)
		end
	end
end

function Creator.New(Name, Properties, Children)
	local Object = Instance.new(Name)

	-- Default properties
	for Name, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[Name] = Value
	end

	-- Properties
	for Name, Value in next, Properties or {} do
		if Name ~= "ThemeTag" then
			Object[Name] = Value
		end
	end

	-- Children
	for _, Child in next, Children or {} do
		Child.Parent = Object
	end

	ApplyCustomProps(Object, Properties)
	return Object
end

function Creator.SpringMotor(Initial, Instance, Prop, IgnoreDialogCheck, ResetOnThemeChange)
	IgnoreDialogCheck = IgnoreDialogCheck or false
	ResetOnThemeChange = ResetOnThemeChange or false
	local Motor = Flipper.SingleMotor.new(Initial)
	Motor:onStep(function(value)
		Instance[Prop] = value
	end)

	if ResetOnThemeChange then
		table.insert(Creator.TransparencyMotors, Motor)
		Instance.Destroying:Connect(function()
			for i = #Creator.TransparencyMotors, 1, -1 do
				if Creator.TransparencyMotors[i] == Motor then
					table.remove(Creator.TransparencyMotors, i)
					break
				end
			end
		end)
	end

	local function SetValue(Value, Ignore)
		Ignore = Ignore or false
		if not IgnoreDialogCheck then
			if not Ignore then
				if Prop == "BackgroundTransparency" and require(Root).DialogOpen then
					return
				end
			end
		end
		Motor:setGoal(Flipper.Spring.new(Value, { frequency = 8 }))
	end

	return Motor, SetValue
end

return Creator
