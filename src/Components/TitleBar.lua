local Root = script.Parent.Parent
local Assets = require(script.Parent.Assets)
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)

local New = Creator.New
local AddSignal = Creator.AddSignal

return function(Config)
	local TitleBar = {}

	TitleBar.TagsFrame = New("Frame", {
		Name = "Tags",
		Size = UDim2.fromScale(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 6),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})

	local Library = require(Root)

	local SubTitleBelow = Config.SubTitlePosition == "Below"
	local BarHeight = 42

	TitleBar.TitleLabel = New("TextLabel", {
		RichText = true,
		Text = Config.Title,
		FontFace = Font.new(
			"rbxasset://fonts/families/GothamSSm.json",
			Enum.FontWeight.Regular,
			Enum.FontStyle.Normal
		),
		TextSize = Config.TitleSize or 13,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = SubTitleBelow and UDim2.new(0, 0, 0, 13) or UDim2.fromScale(0, 1),
		AutomaticSize = SubTitleBelow and Enum.AutomaticSize.X or Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	TitleBar.SubTitleLabel = New("TextLabel", {
		RichText = true,
		Text = Config.SubTitle,
		TextTransparency = 0.4,
		FontFace = Font.new(
			"rbxasset://fonts/families/GothamSSm.json",
			Enum.FontWeight.Regular,
			Enum.FontStyle.Normal
		),
		TextSize = SubTitleBelow and 11 or 13,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = SubTitleBelow and UDim2.new(0, 0, 0, 12) or UDim2.fromScale(0, 1),
		AutomaticSize = SubTitleBelow and Enum.AutomaticSize.X or Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local function BarButton(Icon, Pos, Parent, Callback, IsClose)
		local Button = {
			Callback = Callback or function() end,
		}

		Button.Frame = New("TextButton", {
			Size = UDim2.new(0, 34, 1, -8),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Parent = Parent,
			Position = Pos,
			Text = "",
			ThemeTag = {
				BackgroundColor3 = "Text",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 7),
			}),
			New("ImageLabel", {
				Image = Icon,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Name = "Icon",
				ThemeTag = {
					ImageColor3 = "Text",
				},
			}),
		})

		local Motor, SetTransparency = Creator.SpringMotor(1, Button.Frame, "BackgroundTransparency")

		if IsClose then
			AddSignal(Button.Frame.MouseEnter, function()
				Button.Frame.BackgroundColor3 = Color3.fromRGB(232, 17, 35)
				Button.Frame.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
				SetTransparency(0)
			end)
			AddSignal(Button.Frame.MouseLeave, function()
				SetTransparency(1, true)
				task.delay(0.15, function()
					if Button.Frame.BackgroundTransparency >= 0.99 then
						Button.Frame.BackgroundColor3 = Creator.GetThemeProperty("Text")
						Button.Frame.Icon.ImageColor3 = Creator.GetThemeProperty("Text")
					end
				end)
			end)
			AddSignal(Button.Frame.MouseButton1Down, function()
				Button.Frame.BackgroundColor3 = Color3.fromRGB(175, 10, 25)
				SetTransparency(0)
			end)
			AddSignal(Button.Frame.MouseButton1Up, function()
				Button.Frame.BackgroundColor3 = Color3.fromRGB(232, 17, 35)
				SetTransparency(0)
			end)
		else
			AddSignal(Button.Frame.MouseEnter, function()
				SetTransparency(0.94)
			end)
			AddSignal(Button.Frame.MouseLeave, function()
				SetTransparency(1, true)
			end)
			AddSignal(Button.Frame.MouseButton1Down, function()
				SetTransparency(0.96)
			end)
			AddSignal(Button.Frame.MouseButton1Up, function()
				SetTransparency(0.94)
			end)
		end

		AddSignal(Button.Frame.MouseButton1Click, Button.Callback)

		Button.SetCallback = function(Func)
			Button.Callback = Func
		end

		return Button
	end

	TitleBar.Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, BarHeight),
		BackgroundTransparency = 1,
		Parent = Config.Parent,
	}, {
		New("Frame", {
			Size = UDim2.new(1, -136, 1, 0),
			Position = UDim2.new(0, 16, 0, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 8),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			New("Frame", {
				Size = SubTitleBelow and UDim2.new(0, 0, 1, -4) or UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
			}, {
				New("UIListLayout", {
					Padding = UDim.new(0, SubTitleBelow and 1 or 5),
					FillDirection = SubTitleBelow and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				TitleBar.TitleLabel,
				TitleBar.SubTitleLabel,

			}),
			TitleBar.TagsFrame,
		}),
		New("Frame", {
			BackgroundTransparency = 0.5,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			ThemeTag = {
				BackgroundColor3 = "TitleBarLine",
			},
		}),
	})

	TitleBar.CloseButton = BarButton(Assets.Close, UDim2.new(1, -4, 0, 4), TitleBar.Frame, function()
		Library.Window:Dialog({
			Title = "Close",
			Content = "Are you sure you want to unload the interface?",
			Buttons = {
				{
					Title = "Yes",
					Callback = function()
						Library:Destroy()
					end,
				},
				{
					Title = "No",
				},
			},
		})
	end, true)
	TitleBar.MaxButton = BarButton(Assets.Max, UDim2.new(1, -40, 0, 4), TitleBar.Frame, function()
		Config.Window.Maximize(not Config.Window.Maximized)
	end)
	TitleBar.MinButton = BarButton(Assets.Min, UDim2.new(1, -80, 0, 4), TitleBar.Frame, function()
		Library.Window:Minimize()
	end)

	function TitleBar:AddTag(Config)
		Config = Config or {}

		local IconImage
		if Config.Icon then
			IconImage = Library:GetIcon(Config.Icon)
		end

		local TextColor = Config.TextColor or Color3.fromRGB(255, 255, 255)
		local BgColor = Config.Color or Color3.fromRGB(0, 170, 255)
		local Radius = math.clamp(Config.Radius or 4, 0, 13)

		local Children = {
			New("UICorner", {
				CornerRadius = UDim.new(0, Radius),
			}),
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 3),
				PaddingBottom = UDim.new(0, 3),
			}),
			New("UIListLayout", {
				Padding = UDim.new(0, 4),
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),
		}

		if IconImage then
			table.insert(Children, New("ImageLabel", {
				Size = UDim2.fromOffset(14, 14),
				BackgroundTransparency = 1,
				Image = IconImage,
				ImageColor3 = TextColor,
			}))
		end

		table.insert(Children, New("TextLabel", {
			Text = Config.Title or "",
			FontFace = Font.new(
				"rbxasset://fonts/families/GothamSSm.json",
				Enum.FontWeight.SemiBold,
				Enum.FontStyle.Normal
			),
			TextSize = 12,
			TextColor3 = TextColor,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
		}))

		local TagFrame = New("Frame", {
			Size = UDim2.fromScale(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = BgColor,
			Parent = self.TagsFrame,
		}, Children)

		local Tag = {
			Frame = TagFrame,
		}

		function Tag:Destroy()
			TagFrame:Destroy()
		end

		function Tag:SetTitle(Text)
			local TextLabel = TagFrame:FindFirstChildOfClass("TextLabel")
			if TextLabel then
				TextLabel.Text = Text
			end
		end

		return Tag
	end

	function TitleBar:SetTitle(Text)
		if self.TitleLabel then
			self.TitleLabel.Text = Text
		end
	end

	function TitleBar:SetSubtitle(Text)
		if self.SubTitleLabel then
			self.SubTitleLabel.Text = Text
		end
	end

	return TitleBar
end
