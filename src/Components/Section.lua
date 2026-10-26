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

	local HeaderHeight = 34

	-- 1px gaps between rows hold the hairlines each row draws under itself
	Section.Layout = New("UIListLayout", {
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})

	-- Rows read this to stay flat
	Section.Container = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.fromOffset(0, HeaderHeight + 1),
		BackgroundTransparency = 1,
	}, {
		Section.Layout,
	})
	Section.Container:SetAttribute("Card", true)

	-- Group header: a tinted strip closed by a hairline, then the rows edge to edge
	Section.Root = New("Frame", {
		Size = UDim2.new(1, 0, 0, HeaderHeight + 1),
		BackgroundTransparency = 1,
		LayoutOrder = 7,
		Parent = Parent,
	}, {
		New("Frame", {
			Size = UDim2.new(1, 0, 0, HeaderHeight),
			BorderSizePixel = 0,
			ThemeTag = {
				BackgroundColor3 = "Surface",
			},
		}, {
			New("TextLabel", {
				RichText = true,
				Text = Title,
				FontFace = Creator.Fonts.Mono,
				TextSize = 12,
				TextXAlignment = JustifyMap[Justify] or JustifyMap.Left,
				Size = UDim2.new(1, -32, 1, 0),
				Position = UDim2.fromOffset(16, 0),
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Muted",
				},
			}),
		}),
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.fromOffset(0, HeaderHeight),
			BorderSizePixel = 0,
			ThemeTag = {
				BackgroundColor3 = "Line",
			},
		}),
		Section.Container,
	})

	local function Update()
		local ContentHeight = Section.Layout.AbsoluteContentSize.Y
		Section.Container.Size = UDim2.new(1, 0, 0, ContentHeight)
		Section.Root.Size = UDim2.new(1, 0, 0, HeaderHeight + 1 + ContentHeight)
	end

	Creator.AddSignal(Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"), Update)
	Update()
	return Section
end
