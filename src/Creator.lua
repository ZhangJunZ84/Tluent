local Root = script.Parent
local Themes = require(Root.Themes)
local Flipper = require(Root.Packages.Flipper)

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
			TextSize = 14,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
			Font = Enum.Font.Roboto,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.Roboto,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
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
	local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
	Creator.AddSignal(Button.MouseButton1Down, function()
		local TweenService = game:GetService("TweenService")
		local RunService = game:GetService("RunService")
		local AbsoluteSize = Button.AbsoluteSize
		local AbsolutePosition = Button.AbsolutePosition
		if AbsoluteSize.X == 0 then return end
		local MaxSize = math.max(AbsoluteSize.X, AbsoluteSize.Y) * 1.5

		local ScreenGui = Button:FindFirstAncestorOfClass("ScreenGui")
		if not ScreenGui then return end

		local parentCorner = Button:FindFirstChildOfClass("UICorner")
		local cornerRadius = parentCorner and parentCorner.CornerRadius or UDim.new(0, 8)

		-- Create ripple in ScreenGui to completely escape the AutomaticSize hierarchy
		local RippleHolder = Creator.New("CanvasGroup", {
			Name = "RippleHolder",
			Parent = ScreenGui,
			Size = UDim2.fromOffset(AbsoluteSize.X, AbsoluteSize.Y),
			Position = UDim2.fromOffset(AbsolutePosition.X, AbsolutePosition.Y),
			BackgroundTransparency = 1,
			ZIndex = 100
		})
		Creator.New("UICorner", { CornerRadius = cornerRadius, Parent = RippleHolder })

		local clickOffsetX = Mouse.X - AbsolutePosition.X
		local clickOffsetY = Mouse.Y - AbsolutePosition.Y

		local Circle = Creator.New("Frame", {
			Name = "Ripple",
			Parent = RippleHolder,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.6,
			ZIndex = 101,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(clickOffsetX, clickOffsetY),
			Size = UDim2.fromOffset(0, 0)
		})
		Creator.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Circle })
		Creator.AddThemeObject(Circle, { BackgroundColor3 = "OnSurface" })

		-- Sync position with Button if user scrolls
		local Connection
		Connection = RunService.RenderStepped:Connect(function()
			if not Button.Parent then
				Connection:Disconnect()
				RippleHolder:Destroy()
				return
			end
			RippleHolder.Position = UDim2.fromOffset(Button.AbsolutePosition.X, Button.AbsolutePosition.Y)
			RippleHolder.Size = UDim2.fromOffset(Button.AbsoluteSize.X, Button.AbsoluteSize.Y)
		end)

		local Tween = TweenService:Create(Circle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(MaxSize, MaxSize),
			BackgroundTransparency = 1
		})
		Tween:Play()
		
		Tween.Completed:Connect(function() 
			if Connection then Connection:Disconnect() end
			RippleHolder:Destroy() 
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
end

function Creator.GetThemeProperty(Property)
	if Themes[require(Root).Theme][Property] then
		return Themes[require(Root).Theme][Property]
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

function Creator.AddThemeObject(Object, Properties)
	local Idx = #Creator.Registry + 1
	local Data = {
		Object = Object,
		Properties = Properties,
		Idx = Idx,
	}

	Creator.Registry[Object] = Data
	Creator.UpdateTheme()
	return Object
end

function Creator.OverrideTag(Object, Properties)
	Creator.Registry[Object].Properties = Properties
	Creator.UpdateTheme()
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
