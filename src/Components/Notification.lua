local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local Icons = require(Root.Icons)
local TweenService = game:GetService("TweenService")

local Spring = Flipper.Spring.new
local New = Creator.New

local Notification = {}

function Notification:Init(GUI)
	Notification.Holder = New("Frame", {
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 300, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Parent = GUI,
	}, {
		New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 8),
		}),
	})
end

function Notification:New(Config)
	Config.Title = Config.Title or "Title"
	Config.Content = Config.Content or "Content"
	Config.SubContent = Config.SubContent or ""
	Config.Duration = Config.Duration or nil
	Config.Buttons = Config.Buttons or {}
	local NewNotification = {
		Closed = false,
	}

	NewNotification.Title = New("TextLabel", {
		Position = UDim2.new(0, 30, 0, 17),
		Text = Config.Title,
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0,
		FontFace = Creator.Fonts.SemiBold,
		TextSize = 14,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.new(1, -70, 0, 12),
		TextWrapped = true,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	NewNotification.ContentLabel = New("TextLabel", {
		FontFace = Creator.Fonts.Medium,
		Text = Config.Content,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		TextWrapped = true,
		ThemeTag = {
			TextColor3 = "Muted",
		},
	})

	NewNotification.SubContentLabel = New("TextLabel", {
		FontFace = Creator.Fonts.Regular,
		Text = Config.SubContent,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		TextWrapped = true,
		ThemeTag = {
			TextColor3 = "Soft",
		},
	})

	NewNotification.LabelHolder = New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(30, 36),
		Size = UDim2.new(1, -44, 0, 0),
	}, {
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 3),
		}),
		NewNotification.ContentLabel,
		NewNotification.SubContentLabel,
	})

	NewNotification.CloseButton = New("TextButton", {
		Text = "",
		Position = UDim2.new(1, -14, 0, 13),
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
	}, {
		(function()
			local CloseIcon = Icons.Image({
				Icon = "lucide:x",
				Size = UDim2.fromOffset(16, 16),
				Colors = { "Soft" },
			})
			CloseIcon.IconFrame.Position = UDim2.fromScale(0.5, 0.5)
			CloseIcon.IconFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			return CloseIcon.IconFrame
		end)(),
	})

	NewNotification.Root = New("Frame", {
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromScale(1, 0),
		ThemeTag = {
			BackgroundColor3 = "Surface2",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),
		New("UIStroke", {
			ThemeTag = {
				Color = "Line2",
			},
		}),
		New("Frame", {
			Size = UDim2.fromOffset(8, 8),
			Position = UDim2.fromOffset(14, 21),
			ThemeTag = {
				BackgroundColor3 = "Accent",
			},
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		}),
		NewNotification.Title,
		NewNotification.CloseButton,
		NewNotification.LabelHolder,
	})

	if Config.Content == "" then
		NewNotification.ContentLabel.Visible = false
	end

	if Config.SubContent == "" then
		NewNotification.SubContentLabel.Visible = false
	end

	NewNotification.Holder = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 200),
		Parent = Notification.Holder,
	}, {
		NewNotification.Root,
	})

	local ProgressTrack = New("Frame", {
		Size = UDim2.new(1, -28, 0, 2),
		Position = UDim2.new(0, 14, 1, -8),
		BorderSizePixel = 0,
		BackgroundTransparency = 0.85,
		Parent = NewNotification.Root,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
	})

	local ProgressBar = New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		Parent = ProgressTrack,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
	})

	local RootMotor = Flipper.GroupMotor.new({
		Scale = 1,
		Offset = 60,
	})

	RootMotor:onStep(function(Values)
		NewNotification.Root.Position = UDim2.new(Values.Scale, Values.Offset, 0, 0)
	end)

	Creator.AddSignal(NewNotification.CloseButton.MouseButton1Click, function()
		NewNotification:Close()
	end)

	function NewNotification:Open()
		local ContentSize = NewNotification.LabelHolder.AbsoluteSize.Y
		NewNotification.Holder.Size = UDim2.new(1, 0, 0, 56 + ContentSize)

		RootMotor:setGoal({
			Scale = Spring(0, { frequency = 5 }),
			Offset = Spring(0, { frequency = 5 }),
		})
	end

	function NewNotification:Close()
		if not NewNotification.Closed then
			NewNotification.Closed = true
			task.spawn(function()
				RootMotor:setGoal({
					Scale = Spring(1, { frequency = 5 }),
					Offset = Spring(60, { frequency = 5 }),
				})
				task.wait(0.4)
				NewNotification.Holder:Destroy()
			end)
		end
	end

	NewNotification:Open()
	if Config.Duration then
		local Tween = TweenService:Create(ProgressBar, TweenInfo.new(Config.Duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0),
		})
		Tween:Play()

		task.delay(Config.Duration, function()
			NewNotification:Close()
		end)
	else
		ProgressTrack.Visible = false
	end
	return NewNotification
end

return Notification
