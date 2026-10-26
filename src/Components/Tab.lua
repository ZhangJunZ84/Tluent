local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Icons = require(Root.Icons)

local New = Creator.New
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

local function FirstColor(Color)
	return typeof(Color) == "ColorSequence" and Color.Keypoints[1].Value or Color
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
		Pinned = TabConfig.Pinned == true,
	}

	-- Rail cell: the icon, or the title's initial when there is none
	local Glyph, ColorProperty
	if Icon then
		Glyph = Icons.Image({
			Icon = Icon,
			Size = UDim2.fromOffset(19, 19),
			Colors = { "Soft" },
		}).IconFrame
		ColorProperty = "ImageColor3"
	else
		Glyph = New("TextLabel", {
			Text = string.upper(string.sub(Title, 1, 1)),
			FontFace = Creator.Fonts.SemiBold,
			TextSize = 17,
			Size = UDim2.fromOffset(19, 19),
			BackgroundTransparency = 1,
			ThemeTag = {
				TextColor3 = "Soft",
			},
		})
		ColorProperty = "TextColor3"
	end
	Glyph.AnchorPoint = Vector2.new(0.5, 0.5)
	Glyph.Position = UDim2.fromScale(0.5, 0.5)

	Tab.Frame = New("TextButton", {
		Size = Tab.Pinned and UDim2.fromScale(1, 1) or UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		LayoutOrder = TabIndex * 2,
		Text = "",
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = "Surface2",
		},
	}, {
		Glyph,
	})

	if not Tab.Pinned then
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			BorderSizePixel = 0,
			LayoutOrder = TabIndex * 2 + 1,
			Parent = Parent,
			ThemeTag = {
				BackgroundColor3 = "Line",
			},
		})
	end

	local function SetForeground(Color)
		Creator.OverrideTag(Glyph, { [ColorProperty] = Color })
	end

	local function TooltipText()
		local Badge = Tab.Badge
		if Badge and Badge.Title and Badge.Title ~= "" then
			return ('%s  <font transparency="0.45">%s</font>'):format(Tab.Name, Badge.Title)
		end
		return Tab.Name
	end

	function Tab.SetSelected(Selected)
		Tab.Selected = Selected
		Tab.Frame.BackgroundTransparency = Selected and 0 or 1
		SetForeground(Selected and "Text" or "Soft")
	end

	Creator.AddSignal(Tab.Frame.MouseEnter, function()
		if not Tab.Selected then
			SetForeground("Text")
		end
		Window.ShowTooltip(TooltipText(), Tab.Frame)
	end)
	Creator.AddSignal(Tab.Frame.MouseLeave, function()
		if not Tab.Selected then
			SetForeground("Soft")
		end
		Window.HideTooltip()
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Click, function()
		TabModule:SelectTab(TabIndex)
	end)

	-- Rows run edge to edge between hairlines, so the page has no padding of its own
	local ContainerLayout = New("UIListLayout", {
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})

	Tab.ContainerFrame = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = Window.ContainerHolder,
		Visible = false,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ThemeTag = {
			ScrollBarImageColor3 = "Line2",
		},
	}, {
		ContainerLayout,
	})
	Tab.ContainerFrame:SetAttribute("Card", true)

	Creator.AddSignal(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		-- +1 keeps the last row's hairline, which sits just below the content
		Tab.ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 1)
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

	-- In the rail a badge is a dot on the icon; its title shows in the tooltip
	function Tab:AddBadge(Config)
		if self.Badge then
			self.Badge:Destroy()
		end

		Config = Config or {}
		local Custom = Config.Color and FirstColor(Config.Color)

		local Dot = New("Frame", {
			Size = UDim2.fromOffset(7, 7),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 10, 0.5, -10),
			BackgroundColor3 = Custom or Creator.GetThemeProperty("Accent"),
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = Tab.Frame,
			ThemeTag = not Custom and { BackgroundColor3 = "Accent" } or nil,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 0),
			}),
		})

		local Tag = {
			Frame = Dot,
			Title = Config.Title,
		}

		function Tag:Destroy()
			Dot:Destroy()
			if Tab.Badge == Tag then
				Tab.Badge = nil
			end
		end

		function Tag:SetTitle(Text)
			Tag.Title = Text
		end

		function Tag:SetColor(ColorData)
			local TargetColor = typeof(ColorData) == "table" and ColorData.Color or ColorData
			if not TargetColor then
				return
			end

			-- Detach from theme updates so the custom color sticks
			if Creator.Registry[Dot] then
				Creator.Registry[Dot].Properties = {}
			end
			Dot.BackgroundColor3 = FirstColor(TargetColor)
		end

		self.Badge = Tag
		return Tag
	end

	setmetatable(Tab, Elements)
	return Tab
end

function TabModule:SelectTab(Tab)
	if TabModule.SelectedTab == Tab then
		return
	end

	TabModule.SelectedTab = Tab

	for _, TabObject in next, TabModule.Tabs do
		TabObject.SetSelected(false)
	end
	local Selected = TabModule.Tabs[Tab]
	Selected.SetSelected(true)

	for _, Container in next, TabModule.Containers do
		Container.Visible = false
	end
	TabModule.Containers[Tab].Visible = true

	TabModule.Window.TitleBar:SetCrumb(Selected.Name)

	if Selected.Pinned then
		return
	end

	-- Scroll the rail only when the active cell is partly out of view
	local Holder = TabModule.Window.TabHolder
	local Top = TabModule:GetCurrentTabPos()
	local Bottom = Top + Selected.Frame.AbsoluteSize.Y
	if Top < 0 then
		Holder.CanvasPosition = Vector2.new(0, Holder.CanvasPosition.Y + Top)
	elseif Bottom > Holder.AbsoluteSize.Y then
		Holder.CanvasPosition = Vector2.new(0, Holder.CanvasPosition.Y + Bottom - Holder.AbsoluteSize.Y)
	end
end

return TabModule
