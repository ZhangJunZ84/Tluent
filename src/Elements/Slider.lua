local UserInputService = game:GetService("UserInputService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Slider - Missing Title.")
	assert(Config.Default, "Slider - Missing default value.")
	assert(Config.Min, "Slider - Missing minimum value.")
	assert(Config.Max, "Slider - Missing maximum value.")
	assert(Config.Rounding, "Slider - Missing rounding value.")

	local Slider = {
		Value = nil,
		Min = Config.Min,
		Max = Config.Max,
		Rounding = Config.Rounding,
		Callback = Config.Callback or function(Value) end,
		Type = "Slider",
	}

	local Dragging = false

	local SliderFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false)
	SliderFrame.DescLabel.Size = UDim2.new(1, -210, 0, 15)

	Slider.SetTitle = SliderFrame.SetTitle
	Slider.SetDesc = SliderFrame.SetDesc

	local SoccerBallLabel = New("ImageLabel", {
		Image = "rbxassetid://4642432897",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 5,
	})

	-- Thumb: light dot ringed with the window background so it reads over the fill
	local SliderDot = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(12, 12),
		ZIndex = 3,
		ThemeTag = {
			BackgroundColor3 = "Text",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		New("UIStroke", {
			Thickness = 3,
			ThemeTag = {
				Color = "Background",
			},
		}),
		SoccerBallLabel,
	})

	Creator.AddThemeObject(SliderDot, {
		BackgroundColor3 = function(GetTheme)
			local isBrasil = (Library.Theme == "Brasil")
			SoccerBallLabel.Visible = isBrasil
			SliderDot.BackgroundTransparency = isBrasil and 1 or 0
			SliderDot.Size = isBrasil and UDim2.fromOffset(22, 22) or UDim2.fromOffset(12, 12)
			SliderDot.BackgroundColor3 = GetTheme("Text")
		end,
	})

	local SliderFill = New("Frame", {
		Size = UDim2.fromScale(0, 1),
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
	})

	local SliderRail = New("Frame", {
		Size = UDim2.new(1, -44, 0, 4),
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = {
			BackgroundColor3 = "Surface3",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		SliderFill,
		SliderDot,
	})

	local SliderHitbox = New("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, -44, 1, 16),
		Position = UDim2.fromOffset(0, -8),
		AutoButtonColor = false,
		ZIndex = 4,
	})

	local SliderDisplay = New("TextBox", {
		FontFace = Creator.Fonts.Mono,
		Text = "Value",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 36, 1, 0),
		Position = UDim2.fromScale(1, 0),
		AnchorPoint = Vector2.new(1, 0),
		ClearTextOnFocus = false,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	New("Frame", {
		Size = UDim2.new(0, 190, 0, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = SliderFrame.Frame,
	}, {
		SliderRail,
		SliderHitbox,
		SliderDisplay,
	})

	local function ValueFromInput(Input)
		local SizeScale = math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
		return Slider.Min + ((Slider.Max - Slider.Min) * SizeScale)
	end

	Creator.AddSignal(SliderHitbox.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = true
			Slider:SetValue(ValueFromInput(Input))
		end
	end)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = false
		end
	end)

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if
			Dragging
			and (
				Input.UserInputType == Enum.UserInputType.MouseMovement
				or Input.UserInputType == Enum.UserInputType.Touch
			)
		then
			Slider:SetValue(ValueFromInput(Input))
		end
	end)

	Creator.AddSignal(SliderDisplay.FocusLost, function(Enter)
		local Number = tonumber(SliderDisplay.Text)
		if Number then
			Slider:SetValue(Number)
		else
			Slider:SetValue(Slider.Value)
		end
	end)

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Func(Slider.Value)
	end

	function Slider:SetValue(Value)
		self.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)

		local Percent = (self.Value - Slider.Min) / (Slider.Max - Slider.Min)
		SliderDot.Position = UDim2.fromScale(Percent, 0.5)
		SliderFill.Size = UDim2.fromScale(Percent, 1)
		SliderDisplay.Text = tostring(self.Value)
		SoccerBallLabel.Rotation = Percent * 360 * 3

		Library:SafeCallback(Slider.Callback, self.Value)
		Library:SafeCallback(Slider.Changed, self.Value)
	end

	function Slider:Destroy()
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Slider:SetValue(Config.Default)

	Library.Options[Idx] = Slider
	return Slider
end

return Element
