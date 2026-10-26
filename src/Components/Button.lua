local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

return function(Parent, DialogCheck)
	DialogCheck = DialogCheck or false
	local Button = {}

	Button.Title = New("TextLabel", {
		FontFace = Creator.Fonts.SemiBold,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Button.HoverFrame = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ThemeTag = {
			BackgroundColor3 = "Text",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),
	})

	Button.Frame = New("TextButton", {
		Size = UDim2.new(0, 0, 0, 32),
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = "Surface2",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "Line2",
			},
		}),
		Button.HoverFrame,
		Button.Title,
	})

	local Motor, SetTransparency = Creator.SpringMotor(1, Button.HoverFrame, "BackgroundTransparency", DialogCheck)
	Creator.AddSignal(Button.Frame.MouseEnter, function()
		SetTransparency(0.97)
	end)
	Creator.AddSignal(Button.Frame.MouseLeave, function()
		SetTransparency(1)
	end)
	Creator.AddSignal(Button.Frame.MouseButton1Down, function()
		SetTransparency(1)
	end)
	Creator.AddSignal(Button.Frame.MouseButton1Up, function()
		SetTransparency(0.97)
	end)

	return Button
end
