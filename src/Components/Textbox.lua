local TextService = game:GetService("TextService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

return function(Parent, Acrylic)
	Acrylic = Acrylic or false
	local Textbox = {}

	Textbox.Input = New("TextBox", {
		FontFace = Creator.Fonts.Medium,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(10, 0),
		ThemeTag = {
			TextColor3 = "Text",
			PlaceholderColor3 = "Soft",
		},
	})

	Textbox.Container = New("Frame", {
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 6, 0, 0),
		Size = UDim2.new(1, -12, 1, 0),
	}, {
		Textbox.Input,
	})

	Textbox.Indicator = New("Frame", {
		Size = UDim2.new(1, -16, 0, 1),
		Position = UDim2.new(0, 8, 1, -1),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Visible = false,
	})

	local Stroke = New("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		ThemeTag = {
			Color = "Line2",
		},
	})

	Textbox.Frame = New("Frame", {
		Size = UDim2.new(0, 0, 0, 30),
		BackgroundTransparency = 0,
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = "Background",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),
		Stroke,
		Textbox.Indicator,
		Textbox.Container,
	})

	local updatePending = false
	local function Update()
		updatePending = false
		local PADDING = 2
		local Reveal = Textbox.Container.AbsoluteSize.X

		if not Textbox.Input:IsFocused() or Textbox.Input.TextBounds.X <= Reveal - 2 * PADDING then
			Textbox.Input.Position = UDim2.new(0, PADDING, 0, 0)
		else
			local Cursor = Textbox.Input.CursorPosition
			if Cursor ~= -1 then
				local subtext = string.sub(Textbox.Input.Text, 1, Cursor - 1)
				local width = TextService:GetTextSize(
					subtext,
					Textbox.Input.TextSize,
					Textbox.Input.Font,
					Vector2.new(math.huge, math.huge)
				).X

				local CurrentCursorPos = Textbox.Input.Position.X.Offset + width
				if CurrentCursorPos < PADDING then
					Textbox.Input.Position = UDim2.fromOffset(PADDING - width, 0)
				elseif CurrentCursorPos > Reveal - PADDING - 1 then
					Textbox.Input.Position = UDim2.fromOffset(Reveal - width - PADDING - 1, 0)
				end
			end
		end
	end

	local function ScheduleUpdate()
		if not updatePending then
			updatePending = true
			task.defer(Update)
		end
	end

	task.spawn(Update)

	Creator.AddSignal(Textbox.Input:GetPropertyChangedSignal("Text"), ScheduleUpdate)
	Creator.AddSignal(Textbox.Input:GetPropertyChangedSignal("CursorPosition"), ScheduleUpdate)

	Creator.AddSignal(Textbox.Input.Focused, function()
		Update()
		Creator.OverrideTag(Stroke, { Color = "AccentLine" })
	end)

	Creator.AddSignal(Textbox.Input.FocusLost, function()
		Update()
		Creator.OverrideTag(Stroke, { Color = "Line2" })
	end)

	return Textbox
end
