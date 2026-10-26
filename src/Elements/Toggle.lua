local TweenService = game:GetService("TweenService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Toggle"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Toggle - Missing Title")

	local Toggle = {
		Value = Config.Default or false,
		Callback = Config.Callback or function(Value) end,
		Type = "Toggle",
	}

	local ToggleFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true)
	ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 15)

	Toggle.SetTitle = ToggleFrame.SetTitle
	Toggle.SetDesc = ToggleFrame.SetDesc

	local Knob = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 3, 0.5, 0),
		ThemeTag = {
			BackgroundColor3 = "Muted",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),
	})

	local TrackStroke = New("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		ThemeTag = {
			Color = "Line2",
		},
	})

	local Track = New("Frame", {
		Size = UDim2.fromOffset(34, 20),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Parent = ToggleFrame.Frame,
		ThemeTag = {
			BackgroundColor3 = "Surface3",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),
		TrackStroke,
		Knob,
	})

	-- Set while the change comes from a click, so loading a config doesn't light every row up
	local FromClick = false

	function Toggle:OnChanged(Func)
		Toggle.Changed = Func
		Func(Toggle.Value)
	end

	function Toggle:SetValue(Value)
		Value = not not Value
		Toggle.Value = Value

		Creator.OverrideTag(Track, { BackgroundColor3 = Value and "Accent" or "Surface3" })
		TrackStroke.Transparency = Value and 1 or 0
		Creator.OverrideTag(Knob, { BackgroundColor3 = Value and "AccentInk" or "Muted" })
		TweenService:Create(
			Knob,
			TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, Value and 17 or 3, 0.5, 0) }
		):Play()

		ToggleFrame:SetActive(Value, FromClick)

		Library:SafeCallback(Toggle.Callback, Toggle.Value)
		Library:SafeCallback(Toggle.Changed, Toggle.Value)
	end

	function Toggle:Destroy()
		ToggleFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
		FromClick = true
		Toggle:SetValue(not Toggle.Value)
		FromClick = false
	end)

	Toggle:SetValue(Toggle.Value)

	Library.Options[Idx] = Toggle
	return Toggle
end

return Element
