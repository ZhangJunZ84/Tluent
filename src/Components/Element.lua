local TweenService = game:GetService("TweenService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

return function(Title, Desc, Parent, Hover)
	local Element = {}

	-- Rows in a section or tab page run edge to edge, flat until hovered, with a hairline under each;
	-- anywhere else they draw their own outline
	local InCard = Parent and Parent:GetAttribute("Card") == true
	local BaseColor = InCard and "Surface2" or "Surface"
	local BaseTransparency = InCard and 1 or 0
	local Active = false

	Element.TitleLabel = New("TextLabel", {
		FontFace = Creator.Fonts.SemiBold,
		Text = Title,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 17),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Element.DescLabel = New("TextLabel", {
		FontFace = Creator.Fonts.Regular,
		Text = Desc,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 15),
		ThemeTag = {
			TextColor3 = "Soft",
		},
	})

	Element.LabelHolder = New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(InCard and 16 or 10, 0),
		Size = UDim2.new(1, InCard and -34 or -28, 0, 0),
	}, {
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 1),
		}),
		New("UIPadding", {
			PaddingBottom = UDim.new(0, 13),
			PaddingTop = UDim.new(0, 13),
		}),
		Element.TitleLabel,
		Element.DescLabel,
	})

	Element.Border = New("UIStroke", {
		Transparency = InCard and 1 or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		ThemeTag = {
			Color = "Line",
		},
	})

	-- Strokes draw outside their frame and the page clips its sides, so in a page the outline
	-- lives on a frame inset by its own width
	local Outline = InCard and New("Frame", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.fromOffset(1, 1),
		BackgroundTransparency = 1,
	}, {
		Element.Border,
	}) or Element.Border

	Element.Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = BaseTransparency,
		Parent = Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		LayoutOrder = 7,
		ThemeTag = {
			BackgroundColor3 = BaseColor,
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),
		New("UISizeConstraint", {
			MinSize = Vector2.new(0, 46),
		}),
		Outline,
		Element.LabelHolder,
	})

	-- Sits in the layout's 1px gap below the row
	if InCard then
		New("Frame", {
			Name = "RowDivider",
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.fromScale(0, 1),
			BorderSizePixel = 0,
			Parent = Element.Frame,
			ThemeTag = {
				BackgroundColor3 = "Line",
			},
		})
	end

	function Element:SetTitle(Set)
		Element.TitleLabel.Text = Set
	end

	function Element:SetDesc(Set)
		if Set == nil then
			Set = ""
		end
		if Set == "" then
			Element.DescLabel.Visible = false
		else
			Element.DescLabel.Visible = true
		end
		Element.DescLabel.Text = Set
	end

	function Element:Destroy()
		Element.Frame:Destroy()
	end

	local function ShowRest()
		if Active then
			Creator.OverrideTag(Element.Frame, { BackgroundColor3 = "ActiveRow" })
			Element.Frame.BackgroundTransparency = 0
		else
			Creator.OverrideTag(Element.Frame, { BackgroundColor3 = BaseColor })
			Element.Frame.BackgroundTransparency = BaseTransparency
		end
	end

	-- Light effects on the border: a UIStroke whose UIGradient draws a bright band.
	-- Rotation 0 puts the band across the middle of the top and bottom edges; 90 on the side edges
	local Shimmer, ShimmerStroke, ShimmerGradient, ShimmerTweens
	local function PrepareShimmer(Color, Width)
		if not Shimmer then
			ShimmerGradient = New("UIGradient", {})
			ShimmerStroke = New("UIStroke", {
				Color = Color3.new(1, 1, 1),
				Transparency = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}, {
				ShimmerGradient,
			})
			Shimmer = New("Frame", {
				Size = InCard and UDim2.new(1, -2, 1, -2) or UDim2.fromScale(1, 1),
				Position = InCard and UDim2.fromOffset(1, 1) or nil,
				BackgroundTransparency = 1,
				ZIndex = 2,
				Parent = Element.Frame,
			}, {
				ShimmerStroke,
			})
		end

		if ShimmerTweens then
			for _, Tween in next, ShimmerTweens do
				Tween:Cancel()
			end
		end

		ShimmerGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color),
			ColorSequenceKeypoint.new(0.5 - Width * 0.3, Color),
			ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.5 + Width * 0.3, Color),
			ColorSequenceKeypoint.new(1, Color),
		})
		ShimmerGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5 - Width, 1),
			NumberSequenceKeypoint.new(0.5 - Width * 0.3, 0.2),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(0.5 + Width * 0.3, 0.2),
			NumberSequenceKeypoint.new(0.5 + Width, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
		ShimmerStroke.Transparency = 0
	end

	local function PlayTweens(Tweens)
		ShimmerTweens = Tweens
		for _, Tween in next, Tweens do
			Tween:Play()
		end
	end

	-- Turning on: the band lights two opposite points, so half a turn of the gradient sweeps the
	-- whole border once; it starts on the sides and fades back there
	local function PlayShimmer()
		PrepareShimmer(Creator.GetThemeProperty("Accent"), 0.2)
		ShimmerGradient.Rotation = 90
		PlayTweens({
			TweenService:Create(ShimmerGradient, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Rotation = 270,
			}),
			TweenService:Create(ShimmerStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.1), {
				Transparency = 1,
			}),
		})
	end

	-- Turning off: a short blink on the top and bottom edges
	local function PlayBlink()
		PrepareShimmer(Creator.GetThemeProperty("Muted"), 0.35)
		ShimmerGradient.Rotation = 0
		PlayTweens({
			TweenService:Create(ShimmerStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
			}),
		})
	end

	-- Active rows get an accent outline and a faint accent tint; Animate plays the matching light effect
	function Element:SetActive(Value, Animate)
		Active = Value and true or false
		if Active then
			Creator.OverrideTag(Element.Border, { Color = "AccentLine" })
			Element.Border.Transparency = 0
		else
			Creator.OverrideTag(Element.Border, { Color = "Line" })
			Element.Border.Transparency = InCard and 1 or 0
		end
		ShowRest()

		if Animate then
			if Active then
				PlayShimmer()
			else
				PlayBlink()
			end
		end
	end

	Element:SetTitle(Title)
	Element:SetDesc(Desc)

	if Hover then
		Creator.AddSignal(Element.Frame.MouseEnter, function()
			if not Active then
				Creator.OverrideTag(Element.Frame, { BackgroundColor3 = "Surface2" })
				Element.Frame.BackgroundTransparency = 0
			end
		end)
		Creator.AddSignal(Element.Frame.MouseLeave, ShowRest)
	end

	return Element
end
