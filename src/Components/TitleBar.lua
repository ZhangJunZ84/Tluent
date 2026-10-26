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

	local BarHeight = Config.Height or 52
	local RailWidth = Config.RailWidth or 52

	TitleBar.TitleLabel = New("TextLabel", {
		RichText = true,
		Text = Config.Title,
		FontFace = Creator.Fonts.SemiBold,
		TextSize = Config.TitleSize or 15,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	-- Lives in the window footer; the window reparents it
	TitleBar.SubTitleLabel = New("TextLabel", {
		RichText = true,
		Text = Config.SubTitle,
		FontFace = Creator.Fonts.Mono,
		TextSize = 12,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Soft",
		},
	})

	-- Breadcrumb with the selected tab, since the rail only shows icons
	TitleBar.CrumbSeparator = New("TextLabel", {
		Text = "/",
		FontFace = Creator.Fonts.Regular,
		TextSize = 15,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 2,
		ThemeTag = {
			TextColor3 = "Line2",
		},
	})

	TitleBar.CrumbLabel = New("TextLabel", {
		Text = "",
		FontFace = Creator.Fonts.Medium,
		TextSize = 15,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 3,
		ThemeTag = {
			TextColor3 = "Muted",
		},
	})

	-- Logo cell above the rail: the logo image, a small brand lockup, or the title's initial
	local Mark
	if Config.Logo then
		Mark = New("ImageLabel", {
			Image = Config.Logo,
			Size = UDim2.fromOffset(30, 30),
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			ThemeTag = {
				ImageColor3 = "Text",
			},
		})
	elseif Config.Brand then
		local Wordmark = New("TextLabel", {
			Text = Config.Brand,
			FontFace = Creator.Fonts.Bold,
			TextSize = 12,
			Size = UDim2.fromOffset(0, 11),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})

		-- Parented to the wordmark so the frame's padding doesn't push it in; the offsets reach
		-- out to the frame's bottom-left corner
		New("Frame", {
			Size = UDim2.new(0.34, 0, 0, 2),
			Position = UDim2.new(0, -5, 1, 4),
			AnchorPoint = Vector2.new(0, 1),
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = Wordmark,
			ThemeTag = {
				BackgroundColor3 = "Accent",
			},
		})

		Mark = New("Frame", {
			Size = UDim2.fromScale(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}, {
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 3),
				PaddingBottom = UDim.new(0, 3),
			}),
			New("UIStroke", {
				Thickness = 1.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				ThemeTag = {
					Color = "BrandFrame",
				},
			}),
			Wordmark,
		})
	else
		Mark = New("TextLabel", {
			Text = string.upper(string.sub(Config.Title or "", 1, 1)),
			FontFace = Creator.Fonts.Bold,
			TextSize = 18,
			Size = UDim2.fromOffset(20, 20),
			BackgroundTransparency = 1,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})
	end
	Mark.AnchorPoint = Vector2.new(0.5, 0.5)
	Mark.Position = UDim2.fromScale(0.5, 0.5)

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

	-- Small ghost buttons: soft icon, surface fill on hover
	local function BarButton(Icon, Index, Parent, Callback, IsClose, IconSize)
		local Button = {
			Callback = Callback or function() end,
		}

		local IconObject = Icons.Image({
			Icon = Icon,
			Size = UDim2.fromOffset(IconSize or 15, IconSize or 15),
			Colors = { "Soft" },
		})
		local IconFrame = IconObject.IconFrame
		IconFrame.Position = UDim2.fromScale(0.5, 0.5)
		IconFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		IconFrame.Name = "Icon"

		Button.SetIcon = function(NewIcon)
			SetIconFrame(IconFrame, NewIcon)
		end

		Button.Frame = New("TextButton", {
			Size = UDim2.fromOffset(30, 30),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -11 - (Index - 1) * 32, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = Parent,
			Text = "",
			ThemeTag = {
				BackgroundColor3 = "Surface2",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 0),
			}),
			IconFrame,
		})

		AddSignal(Button.Frame.MouseEnter, function()
			Button.Frame.BackgroundTransparency = 0
			Creator.OverrideTag(IconFrame, { ImageColor3 = IsClose and "Danger" or "Text" })
		end)
		AddSignal(Button.Frame.MouseLeave, function()
			Button.Frame.BackgroundTransparency = 1
			Creator.OverrideTag(IconFrame, { ImageColor3 = "Soft" })
		end)

		AddSignal(Button.Frame.MouseButton1Click, function()
			Button.Callback()
		end)

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
			Name = "Logo",
			Size = UDim2.fromOffset(RailWidth, BarHeight),
			BackgroundTransparency = 1,
		}, {
			Mark,
		}),
		New("Frame", {
			Size = UDim2.new(1, -(RailWidth + 1 + 16 + 110), 1, 0),
			Position = UDim2.fromOffset(RailWidth + 1 + 16, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 8),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			TitleBar.TitleLabel,
			TitleBar.CrumbSeparator,
			TitleBar.CrumbLabel,
		}),
	})

	TitleBar.CloseButton = BarButton("lucide:x", 1, TitleBar.Frame, function()
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
	TitleBar.MaxButton = BarButton("lucide:square", 2, TitleBar.Frame, function()
		Config.Window.Maximize(not Config.Window.Maximized)
	end, false, 13)
	TitleBar.MinButton = BarButton("lucide:minus", 3, TitleBar.Frame, function()
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

		local Radius = Config.Radius or 0



		local Children = {
			New("UICorner", {
				CornerRadius = UDim.new(0, 0),
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
				LabelColor = Creator.GetThemeProperty("Muted")
				LabelThemeTag = { TextColor3 = "Muted" }
			else
				LabelColor = Color3.fromRGB(255, 255, 255)
				LabelThemeTag = nil
			end
		end

		table.insert(Children, New("TextLabel", {
			Text = Config.Title or "",
			FontFace = Creator.Fonts.Mono,
			TextSize = 12,
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
			-- Neutral chip for default theme tags
			table.insert(Children, New("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				ThemeTag = {
					Color = "Line",
				},
			}))
			TagFrame = New("Frame", {
				Size = UDim2.fromScale(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				ThemeTag = {
					BackgroundColor3 = "Surface",
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

	function TitleBar:SetCrumb(Text)
		local Visible = Text ~= nil and Text ~= ""
		self.CrumbLabel.Text = Text or ""
		self.CrumbLabel.Visible = Visible
		self.CrumbSeparator.Visible = Visible
	end

	function TitleBar:SetSubtitle(Text)
		if self.SubTitleLabel then
			self.SubTitleLabel.Text = Text
		end
	end

	return TitleBar
end
