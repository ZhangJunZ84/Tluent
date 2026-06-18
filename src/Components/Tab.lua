local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local Icons = require(Root.Icons)
local TweenService = game:GetService("TweenService")

local New = Creator.New
local Spring = Flipper.Spring.new
local Components = Root.Components

local TabModule = {
	Window = nil,
	Tabs = {},
	Containers = {},
	SelectedTab = 0,
	TabCount = 0,
}



function TabModule:Init(Window)
	TabModule.Window = Window
	return TabModule
end

function TabModule:GetCurrentTabPos()
	local TabHolderPos = TabModule.Window.TabHolder.AbsolutePosition.Y
	local TabPos = TabModule.Tabs[TabModule.SelectedTab].Frame.AbsolutePosition.Y

	return TabPos - TabHolderPos
end

function TabModule:New(Title, Icon, Parent, TabConfig)
	TabConfig = TabConfig or {}
	local Library = require(Root)
	local Window = TabModule.Window
	local Elements = Library.Elements

	TabModule.TabCount = TabModule.TabCount + 1
	local TabIndex = TabModule.TabCount

	local Tab = {
		Selected = false,
		Name = Title,
		Type = "Tab",
	}

	local IsIconMode = Window.TabStyle == "Icons"

	local IconObject = Icons.Image({
		Icon = Icon,
		Size = UDim2.fromOffset(16, 16),
		Colors = { "Tab" }
	})
	local IconFrame = IconObject.IconFrame
	IconFrame.AnchorPoint = IsIconMode and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5)
	IconFrame.Position = IsIconMode and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 12, 0.5, 0)

	local LabelOffset = Icon and 32 or 12
	local LabelRightPadding = 10
	local TextLabel = not IsIconMode and New("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, LabelOffset, 0.5, 0),
		Text = Title,
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0,
		FontFace = Font.new(
			"rbxassetid://12187372629",
			Enum.FontWeight.Medium,
			Enum.FontStyle.Normal
		),
		TextSize = 13,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.new(1, -LabelOffset - LabelRightPadding, 1, 0),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Tab",
		},
	}) or nil


	Tab.Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = "SelectedTabBackground",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		TextLabel,
		IconFrame,
	})

	Tab.Hovered = false

	local function UpdateTextLabelSize()
		if not TextLabel then return end
		if Tab.Badge and Tab.Badge.Frame then
			local BadgeWidth = Tab.Badge.Frame.AbsoluteSize.X
			TextLabel.Size = UDim2.new(1, -LabelOffset - LabelRightPadding - BadgeWidth - 6, 1, 0)
		else
			TextLabel.Size = UDim2.new(1, -LabelOffset - LabelRightPadding, 1, 0)
		end
	end

	local ContainerLayout = New("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local TabTitleLabel = New("TextLabel", {
		RichText = true,
		Text = Title,
		FontFace = Font.new("rbxassetid://12187372629", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		TextSize = 22,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		LayoutOrder = -1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Tab.ContainerFrame = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -16),
		Position = UDim2.fromOffset(0, 8),
		BackgroundTransparency = 1,
		Parent = Window.ContainerHolder,
		Visible = false,
		BottomImage = "rbxassetid://6889812791",
		MidImage = "rbxassetid://6889812721",
		TopImage = "rbxassetid://6276641225",
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.95,
		ScrollBarThickness = 3,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		ContainerLayout,
		TabTitleLabel,
		New("UIPadding", {
			PaddingRight = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 1),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
	})

	Creator.AddSignal(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Tab.ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 20)
	end)

	Tab.Motor, Tab.SetTransparency = Creator.SpringMotor(1, Tab.Frame, "BackgroundTransparency")

	Creator.CreateRipple(Tab.Frame)

	Creator.AddSignal(Tab.Frame.MouseEnter, function()
		Tab.Hovered = true
		if not Tab.Selected then
			Tab.SetTransparency(0.92)
		end
	end)
	Creator.AddSignal(Tab.Frame.MouseLeave, function()
		Tab.Hovered = false
		if not Tab.Selected then
			Tab.SetTransparency(1)
		end
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Down, function()
		if not Tab.Selected then
			Tab.SetTransparency(0.85)
		end
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Up, function()
		if not Tab.Selected then
			Tab.SetTransparency(Tab.Hovered and 0.92 or 1)
		end
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Click, function()
		TabModule:SelectTab(TabIndex)
	end)

	TabModule.Containers[TabIndex] = Tab.ContainerFrame
	TabModule.Tabs[TabIndex] = Tab

	Tab.Container = Tab.ContainerFrame
	Tab.ScrollFrame = Tab.Container

	function Tab:AddSection(Config)
		if type(Config) == "string" then
			Config = { Title = Config }
		end

		local SectionFrame = require(Components.Section)(Config.Title, Tab.Container, Config.Justify)
		local Section = { Type = "Section" }
		Section.Container = SectionFrame.Container
		Section.ScrollFrame = Tab.Container

		setmetatable(Section, Elements)
		return Section
	end

	function Tab:AddBadge(Config)
		if self.Badge then
			self.Badge:Destroy()
		end

		Config = Config or {}

		local BgColor = Config.Color
		local TextColor = Config.TextColor
		local UseTheme = (BgColor == nil)
		local IsGradient = typeof(BgColor) == "ColorSequence"

		-- Automatically compute text contrast color for custom backgrounds
		if not UseTheme and not TextColor then
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



		local Children = {
			New("UICorner", {
				CornerRadius = UDim.new(1, 0), -- MD3 pill shape
			}),
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			}),
			New("UIListLayout", {
				Padding = UDim.new(0, 3),
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),
		}

		if IsGradient then
			table.insert(Children, New("UIGradient", {
				Color = BgColor,
				Rotation = Config.Rotation or 0,
			}))
		end



		if Config.Icon then
			local IconObject = Icons.Image({
				Icon = Config.Icon,
				Size = UDim2.fromOffset(10, 10),
				Colors = { TextColor or (UseTheme and "Accent") or Color3.fromRGB(255, 255, 255) }
			})
			table.insert(Children, IconObject.IconFrame)
		end

		local LabelColor, LabelThemeTag
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

		table.insert(Children, New("TextLabel", {
			Text = Config.Title or "",
			FontFace = Font.new(
				"rbxassetid://12187372629",
				Enum.FontWeight.Bold,
				Enum.FontStyle.Normal
			),
			TextSize = 12,
			TextColor3 = LabelColor,
			ThemeTag = LabelThemeTag,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
		}))

		local TargetPosition
		local TargetAnchorPoint
		if IsIconMode then
			TargetAnchorPoint = Vector2.new(1, 0)
			TargetPosition = UDim2.new(1, -4, 0, 4)
		else
			TargetAnchorPoint = Vector2.new(1, 0.5)
			TargetPosition = UDim2.new(1, -8, 0.5, 0)
		end

		local TagFrame
		if UseTheme then
			TagFrame = New("Frame", {
				Size = UDim2.fromScale(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Creator.GetThemeProperty("Accent"),
				BackgroundTransparency = 0.89,
				ThemeTag = {
					BackgroundColor3 = "Accent",
				},
				AnchorPoint = TargetAnchorPoint,
				Position = TargetPosition,
				Parent = self.Frame,
			}, Children)
		else
			TagFrame = New("Frame", {
				Size = UDim2.fromScale(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = IsGradient and Color3.fromRGB(255, 255, 255) or BgColor,
				BackgroundTransparency = Config.BackgroundTransparency or 0,
				AnchorPoint = TargetAnchorPoint,
				Position = TargetPosition,
				Parent = self.Frame,
			}, Children)
		end

		local Tag = {
			Frame = TagFrame,
		}

		function Tag:Destroy()
			TagFrame:Destroy()
			if Tab.Badge == Tag then
				Tab.Badge = nil
			end
			UpdateTextLabelSize()
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

			local TextLabel = TagFrame:FindFirstChildOfClass("TextLabel")
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

		self.Badge = Tag

		Creator.AddSignal(TagFrame:GetPropertyChangedSignal("AbsoluteSize"), function()
			UpdateTextLabelSize()
		end)

		UpdateTextLabelSize()

		return Tag
	end

	setmetatable(Tab, Elements)
	return Tab
end

function TabModule:SelectTab(Tab)
	local Window = TabModule.Window

	if TabModule.SelectedTab == Tab then
		return
	end

	TabModule.SelectedTab = Tab

	for _, TabObject in next, TabModule.Tabs do
		TabObject.SetTransparency(1)
		TabObject.Selected = false
		Creator.OverrideTag(TabObject.Frame, { BackgroundColor3 = "SelectedTabBackground" })
		local TextLabel = TabObject.Frame:FindFirstChildOfClass("TextLabel")
		local IconFrame = TabObject.Frame:FindFirstChild("IconFrame")

		if TextLabel then
			Creator.OverrideTag(TextLabel, { TextColor3 = "Tab" })
		end
		if IconFrame and IconFrame:FindFirstChild("Icon") then
			Creator.OverrideTag(IconFrame.Icon, { ImageColor3 = "Tab" })
		end
	end
	
	Creator.OverrideTag(TabModule.Tabs[Tab].Frame, { BackgroundColor3 = "Accent" })
	TabModule.Tabs[Tab].SetTransparency(0.84)
	TabModule.Tabs[Tab].Selected = true

	local SelectedTextLabel = TabModule.Tabs[Tab].Frame:FindFirstChildOfClass("TextLabel")
	local SelectedIconFrame = TabModule.Tabs[Tab].Frame:FindFirstChild("IconFrame")

	if SelectedTextLabel then
		Creator.OverrideTag(SelectedTextLabel, { TextColor3 = "Tab" })
	end
	if SelectedIconFrame and SelectedIconFrame:FindFirstChild("Icon") then
		Creator.OverrideTag(SelectedIconFrame.Icon, { ImageColor3 = "Accent" })
	end

	-- Animate shared sidebar indicator to selected tab's Y position
	if Window.SidebarIndicator then
		local tabFrame = TabModule.Tabs[Tab].Frame
		local tabAbsY = tabFrame.AbsolutePosition.Y
		local windowAbsY = Window.Root.AbsolutePosition.Y
		local relY = tabAbsY - windowAbsY + tabFrame.AbsoluteSize.Y / 2
		TweenService:Create(
			Window.SidebarIndicator,
			TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = UDim2.fromOffset(0, relY), BackgroundTransparency = 0 }
		):Play()
	end


	for _, Container in next, TabModule.Containers do
		Container.Visible = false
	end
	TabModule.Containers[Tab].Visible = true
end

return TabModule
