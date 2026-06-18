local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Icons = require(Root.Icons)

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
	local BarHeight = 40

	TitleBar.TitleLabel = New("TextLabel", {
		RichText = true,
		Text = Config.Title,
		FontFace = Font.new(
			"rbxassetid://12187372629",
			Enum.FontWeight.Bold,
			Enum.FontStyle.Normal
		),
		TextSize = Config.TitleSize or 17,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = SubTitleBelow and UDim2.new(0, 0, 0, 16) or UDim2.fromScale(0, 1),
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
			"rbxassetid://12187372629",
			Enum.FontWeight.SemiBold,
			Enum.FontStyle.Normal
		),
		TextSize = SubTitleBelow and 13 or 15,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = SubTitleBelow and UDim2.new(0, 0, 0, 12) or UDim2.fromScale(0, 1),
		AutomaticSize = SubTitleBelow and Enum.AutomaticSize.X or Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local function SetIconFrame(IconFrame, Icon)
		local IconLabel = Icons.Icon2(Icon)
		if IconLabel then
			local isrbxassetid = typeof(IconLabel) == "string" and string.find(IconLabel, "rbxassetid://")
			if isrbxassetid then
				IconFrame.Image = IconLabel
				IconFrame.ImageRectSize = Vector2.new(0, 0)
				IconFrame.ImageRectOffset = Vector2.new(0, 0)
			else
				IconFrame.Image = IconLabel[1] or ""
				if IconLabel[2] then
					IconFrame.ImageRectSize = IconLabel[2].ImageRectSize
					IconFrame.ImageRectOffset = IconLabel[2].ImageRectPosition
				end
			end
		end
	end

	local function BarButton(Icon, Pos, Parent, Callback, IsClose, IconSize)
		local Button = {
			Callback = Callback or function() end,
		}

		local IconObject = Icons.Image({
			Icon = Icon,
			Size = UDim2.fromOffset(IconSize or 14, IconSize or 14),
			Colors = { "Text" },
		})
		local IconFrame = IconObject.IconFrame
		IconFrame.Position = UDim2.fromScale(0.5, 0.5)
		IconFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		IconFrame.Name = "Icon"

		Button.SetIcon = function(NewIcon)
			SetIconFrame(IconFrame, NewIcon)
		end

		Button.Frame = New("TextButton", {
			Size = UDim2.new(0, 30, 1, -12),
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
				CornerRadius = UDim.new(1, 0), -- MD3 circular hover states
			}),
			IconFrame,
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
				SetTransparency(0.92)
			end)
			AddSignal(Button.Frame.MouseLeave, function()
				SetTransparency(1, true)
			end)
			AddSignal(Button.Frame.MouseButton1Down, function()
				SetTransparency(0.88)
			end)
			AddSignal(Button.Frame.MouseButton1Up, function()
				SetTransparency(0.92)
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
			Size = UDim2.new(1, -110, 1, 0),
			Position = UDim2.new(0, 16, 0, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 10),
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
					Padding = UDim.new(0, SubTitleBelow and 2 or 6),
					FillDirection = SubTitleBelow and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				TitleBar.TitleLabel,
				TitleBar.SubTitleLabel,

			}),
			TitleBar.TagsFrame,
		})
	})

	TitleBar.CloseButton = BarButton("lucide:x", UDim2.new(1, -4, 0, 4), TitleBar.Frame, function()
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
	TitleBar.MaxButton = BarButton("lucide:square", UDim2.new(1, -38, 0, 4), TitleBar.Frame, function()
		Config.Window.Maximize(not Config.Window.Maximized)
	end, false, 12)
	TitleBar.MinButton = BarButton("lucide:minus", UDim2.new(1, -72, 0, 4), TitleBar.Frame, function()
		Library.Window:Minimize()
	end)

	function TitleBar:AddTag(Config)
		Config = Config or {}

		local BgColor = Config.Color
		local TextColor = Config.TextColor
		local UseTheme = (BgColor == nil)
		local IsGradient = typeof(BgColor) == "ColorSequence"
		local IsTransparent = Config.Transparent or Config.BackgroundTransparency == 1

		-- Automatically compute text contrast color for custom backgrounds
		if not UseTheme and not TextColor and not IsTransparent then
			if IsGradient then
				local Total = 0
				local Keypoints = BgColor.Keypoints
				for _, Keypoint in ipairs(Keypoints) do
					local C = Keypoint.Value
					Total = Total + (0.299 * C.R + 0.587 * C.G + 0.114 * C.B)
				end
				local AvgLuminance = Total / #Keypoints
				if AvgLuminance > 0.55 then
					TextColor = Color3.fromRGB(30, 30, 30)
				else
					TextColor = Color3.fromRGB(255, 255, 255)
				end
			else
				local r, g, b = BgColor.R, BgColor.G, BgColor.B
				local luminance = 0.299 * r + 0.587 * g + 0.114 * b
				if luminance > 0.55 then
					TextColor = Color3.fromRGB(30, 30, 30)
				else
					TextColor = Color3.fromRGB(255, 255, 255)
				end
			end
		end

		local Radius = math.clamp(Config.Radius or 4, 0, 10)



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

		if IsGradient and not IsTransparent then
			table.insert(Children, New("UIGradient", {
				Color = BgColor,
				Rotation = Config.Rotation or 0,
			}))
		end



		-- Only show icon if not transparent, or if explicitly requested to show on transparent
		if Config.Icon and (not IsTransparent or Config.ShowIconOnTransparent) then
			local IconObject = Icons.Image({
				Icon = Config.Icon,
				Size = UDim2.fromOffset(12, 12),
				Colors = { TextColor or (UseTheme and "Accent") or Color3.fromRGB(255, 255, 255) }
			})
			table.insert(Children, IconObject.IconFrame)
		end

		local LabelColor, LabelThemeTag
		local TextChildren = {}

		if IsTransparent then
			if IsGradient then
				LabelColor = Color3.fromRGB(255, 255, 255)
				LabelThemeTag = nil
				table.insert(TextChildren, New("UIGradient", {
					Color = BgColor,
					Rotation = Config.Rotation or 0,
				}))
			else
				LabelColor = BgColor or Creator.GetThemeProperty("Accent")
				LabelThemeTag = (BgColor == nil) and { TextColor3 = "Accent" } or nil
			end
		else
			if TextColor then
				LabelColor = TextColor
				LabelThemeTag = nil
			elseif UseTheme then
				LabelColor = Creator.GetThemeProperty("Accent")
				LabelThemeTag = { TextColor3 = "Accent" }
			else
				LabelColor = Color3.fromRGB(255, 255, 255)
				LabelThemeTag = nil
			end
		end

		table.insert(Children, New("TextLabel", {
			Text = Config.Title or "",
			FontFace = Font.new(
				"rbxassetid://12187372629",
				Enum.FontWeight.Bold,
				Enum.FontStyle.Normal
			),
			TextSize = 13,
			TextColor3 = LabelColor,
			ThemeTag = LabelThemeTag,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
		}, TextChildren))

		local TagFrame
		if IsTransparent then
			TagFrame = New("Frame", {
				Size = UDim2.fromScale(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Parent = self.TagsFrame,
			}, Children)
		elseif UseTheme then
			-- Accent-tinted pill for default theme tags
			TagFrame = New("Frame", {
				Size = UDim2.fromScale(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Creator.GetThemeProperty("Accent"),
				BackgroundTransparency = 0.85,
				ThemeTag = {
					BackgroundColor3 = "Accent",
				},
				Parent = self.TagsFrame,
			}, Children)
		else
			TagFrame = New("Frame", {
				Size = UDim2.fromScale(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = IsGradient and Color3.fromRGB(255, 255, 255) or BgColor,
				BackgroundTransparency = Config.BackgroundTransparency or 0,
				Parent = self.TagsFrame,
			}, Children)
		end

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

		function Tag:SetColor(ColorData)
			local TargetColor
			local Rotation = 0
			local IsColorSequence = false

			if typeof(ColorData) == "Color3" then
				TargetColor = ColorData
			elseif typeof(ColorData) == "ColorSequence" then
				TargetColor = ColorData
				IsColorSequence = true
			elseif typeof(ColorData) == "table" then
				TargetColor = ColorData.Color
				Rotation = ColorData.Rotation or 0
				IsColorSequence = typeof(TargetColor) == "ColorSequence"
			end

			if not TargetColor then return end

			local TextLabel = TagFrame:FindFirstChildOfClass("TextLabel")

			if IsTransparent then
				TagFrame.BackgroundTransparency = 1
				if TextLabel then
					local textGradient = TextLabel:FindFirstChildOfClass("UIGradient")
					if IsColorSequence then
						if not textGradient then
							textGradient = New("UIGradient", {
								Parent = TextLabel,
							})
						end
						textGradient.Enabled = true
						textGradient.Color = TargetColor
						textGradient.Rotation = Rotation
						TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					else
						if textGradient then
							textGradient.Enabled = false
						end
						TextLabel.TextColor3 = TargetColor
					end
					if Creator.Registry[TextLabel] then
						Creator.Registry[TextLabel].Properties.TextColor3 = nil
					end
				end
			else
				local Gradient = TagFrame:FindFirstChildOfClass("UIGradient")
				local TextColor
				local StrokeColor

				if IsColorSequence then
					local Total = 0
					local Keypoints = TargetColor.Keypoints
					for _, Keypoint in ipairs(Keypoints) do
						local C = Keypoint.Value
						Total = Total + (0.299 * C.R + 0.587 * C.G + 0.114 * C.B)
					end
					local AvgLuminance = Total / #Keypoints

					if AvgLuminance > 0.55 then
						TextColor = Color3.fromRGB(30, 30, 30)
					else
						TextColor = Color3.fromRGB(255, 255, 255)
					end
					StrokeColor = TextColor

					if not Gradient then
						Gradient = New("UIGradient", {
							Parent = TagFrame,
						})
					end
					Gradient.Enabled = true
					Gradient.Color = TargetColor
					Gradient.Rotation = Rotation
					TagFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					TagFrame.BackgroundTransparency = (typeof(ColorData) == "table" and ColorData.BackgroundTransparency) or 0
				else
					if Gradient then
						Gradient.Enabled = false
					end

					local r, g, b = TargetColor.R, TargetColor.G, TargetColor.B
					local luminance = 0.299 * r + 0.587 * g + 0.114 * b
					if luminance > 0.55 then
						TextColor = Color3.fromRGB(30, 30, 30)
					else
						TextColor = Color3.fromRGB(255, 255, 255)
					end
					StrokeColor = TextColor

					TagFrame.BackgroundColor3 = TargetColor
					TagFrame.BackgroundTransparency = (typeof(ColorData) == "table" and ColorData.BackgroundTransparency) or 0
				end

				-- Update elements and detach ThemeTag updates to prevent overrides
				if TextLabel then
					TextLabel.TextColor3 = TextColor
					if Creator.Registry[TextLabel] then
						Creator.Registry[TextLabel].Properties.TextColor3 = nil
					end
				end

				local ImageLabel = TagFrame:FindFirstChildOfClass("ImageLabel")
				if ImageLabel then
					ImageLabel.ImageColor3 = TextColor
					if Creator.Registry[ImageLabel] then
						Creator.Registry[ImageLabel].Properties.ImageColor3 = nil
					end
				end



				if Creator.Registry[TagFrame] then
					Creator.Registry[TagFrame].Properties.BackgroundColor3 = nil
				end
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
