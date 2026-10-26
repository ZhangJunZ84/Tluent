local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New

return function(Title, Parent, Justify)
	local Section = {}

	local JustifyMap = {
		Left = Enum.TextXAlignment.Left,
		Center = Enum.TextXAlignment.Center,
		Right = Enum.TextXAlignment.Right,
	}
	local Alignment = JustifyMap[Justify] or JustifyMap.Left

	-- The label sits centered in its strip, so the gap to the rows above and below matches; the
	-- rule next to the title is the only line, so the rows hang from it
	local HeaderHeight = 36
	local LabelTop = 6

	-- 1px gaps between rows hold the hairlines each row draws under itself
	Section.Layout = New("UIListLayout", {
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})

	-- Rows read this to stay flat
	Section.Container = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.fromOffset(0, HeaderHeight),
		BackgroundTransparency = 1,
	}, {
		Section.Layout,
	})
	Section.Container:SetAttribute("Card", true)

	local Plain = Alignment ~= Enum.TextXAlignment.Left

	-- Group header: accent mark, the title in full text color, and a rule running to the edge
	local Marker = New("Frame", {
		Size = UDim2.fromOffset(6, 6),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0, LabelTop + 12),
		BorderSizePixel = 0,
		Visible = not Plain,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	})

	local TitleLabel = New("TextLabel", {
		RichText = true,
		Text = Title,
		FontFace = Creator.Fonts.SemiBold,
		TextSize = 13,
		TextXAlignment = Alignment,
		Size = Plain and UDim2.new(1, -32, 0, 24) or UDim2.fromOffset(0, 24),
		AutomaticSize = not Plain and Enum.AutomaticSize.X or nil,
		Position = UDim2.fromOffset(Plain and 16 or 30, LabelTop),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local Rule = New("Frame", {
		Size = UDim2.new(1, -60, 0, 1),
		Position = UDim2.fromOffset(44, LabelTop + 12),
		BorderSizePixel = 0,
		Visible = not Plain,
		ThemeTag = {
			BackgroundColor3 = "Line",
		},
	})

	Section.Root = New("Frame", {
		Size = UDim2.new(1, 0, 0, HeaderHeight),
		BackgroundTransparency = 1,
		LayoutOrder = 7,
		Parent = Parent,
	}, {
		Marker,
		TitleLabel,
		Rule,
		Section.Container,
	})

	-- The rule starts after the title, whatever its width
	local function PlaceRule()
		local Left = 30 + TitleLabel.AbsoluteSize.X + 12
		Rule.Position = UDim2.fromOffset(Left, LabelTop + 12)
		Rule.Size = UDim2.new(1, -(Left + 16), 0, 1)
	end

	local function Update()
		local ContentHeight = Section.Layout.AbsoluteContentSize.Y
		Section.Container.Size = UDim2.new(1, 0, 0, ContentHeight)
		Section.Root.Size = UDim2.new(1, 0, 0, HeaderHeight + ContentHeight)
	end

	if not Plain then
		Creator.AddSignal(TitleLabel:GetPropertyChangedSignal("AbsoluteSize"), PlaceRule)
		PlaceRule()
	end
	Creator.AddSignal(Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"), Update)
	Update()
	return Section
end
