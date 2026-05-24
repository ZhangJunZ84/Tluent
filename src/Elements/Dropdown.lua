local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Dropdown"

function Element:New(Idx, Config)
	local Library = self.Library

	local Dropdown = {
		Values = Config.Values,
		Value = Config.Default,
		Multi = Config.Multi,
		Buttons = {},
		Opened = false,
		SearchFilter = "",
		Type = "Dropdown",
		Callback = Config.Callback or function() end,
	}

	local SearchEnabled = Config.Search == true

	local DropdownFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false)
	DropdownFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Dropdown.SetTitle = DropdownFrame.SetTitle
	Dropdown.SetDesc = DropdownFrame.SetDesc

	local DropdownDisplay = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		Text = "Value",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -30, 0, 14),
		Position = UDim2.new(0, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local DropdownIco = New("ImageLabel", {
		Image = "rbxassetid://10709790948",
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundTransparency = 1,
		ThemeTag = {
			ImageColor3 = "SubText",
		},
	})

	local DropdownInner = New("TextButton", {
		Size = UDim2.fromOffset(160, 30),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 0.9,
		Parent = DropdownFrame.Frame,
		ThemeTag = {
			BackgroundColor3 = "DropdownFrame",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		DropdownIco,
		DropdownDisplay,
	})

	local DropdownListLayout = New("UIListLayout", {
		Padding = UDim.new(0, 3),
	})

	local DropdownScrollFrame = New("ScrollingFrame", {
		Size = UDim2.new(1, -5, 1, -10),
		Position = UDim2.fromOffset(5, 5),
		BackgroundTransparency = 1,
		BottomImage = "rbxassetid://6889812791",
		MidImage = "rbxassetid://6889812721",
		TopImage = "rbxassetid://6276641225",
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.95,
		ScrollBarThickness = 4,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
	}, {
		DropdownListLayout,
	})

	local DropdownHolderFrame = New("Frame", {
		Size = UDim2.fromScale(1, 0.6),
		ThemeTag = {
			BackgroundColor3 = "DropdownHolder",
		},
	}, {
		DropdownScrollFrame,
		New("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "DropdownBorder",
			},
		}),
		New("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=5554236805",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(23, 23, 277, 277),
			Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30),
			Position = UDim2.fromOffset(-15, -15),
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.1,
		}),
	})

	local DropdownHolderCanvas = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(170, 300),
		Parent = self.Library.GUI,
		Visible = false,
	}, {
		DropdownHolderFrame,
		New("UISizeConstraint", {
			MinSize = Vector2.new(170, 0),
		}),
	})
	table.insert(Library.OpenFrames, DropdownHolderCanvas)

	local SearchFrame
	local SearchBox

	if SearchEnabled then
		local SearchIcon = New("ImageLabel", {
			Image = "rbxassetid://10734943674",
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.new(0, 8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			ThemeTag = {
				ImageColor3 = "SubText",
			},
		})

		SearchBox = New("TextBox", {
			FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			Text = "",
			PlaceholderText = "Search...",
			TextColor3 = Color3.fromRGB(200, 200, 200),
			PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -28, 1, 0),
			Position = UDim2.fromOffset(28, 0),
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			ThemeTag = {
				TextColor3 = "Text",
				PlaceholderColor3 = "SubText",
			},
		})

		SearchFrame = New("Frame", {
			Size = UDim2.new(1, -10, 0, 26),
			Position = UDim2.fromOffset(5, 5),
			BackgroundTransparency = 0.9,
			Parent = DropdownHolderFrame,
			ThemeTag = {
				BackgroundColor3 = "DropdownFrame",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			SearchIcon,
			SearchBox,
		})

		DropdownScrollFrame.Size = UDim2.new(1, -5, 1, -36)
		DropdownScrollFrame.Position = UDim2.fromOffset(5, 31)
	end

	local function RecalculateListPosition()
		local Add = 0
		if Camera.ViewportSize.Y - DropdownInner.AbsolutePosition.Y < DropdownHolderCanvas.AbsoluteSize.Y - 5 then
			Add = DropdownHolderCanvas.AbsoluteSize.Y
				- 5
				- (Camera.ViewportSize.Y - DropdownInner.AbsolutePosition.Y)
				+ 40
		end
		DropdownHolderCanvas.Position =
			UDim2.fromOffset(DropdownInner.AbsolutePosition.X - 1, DropdownInner.AbsolutePosition.Y - 5 - Add)
	end

	local ListSizeX = 0
	local VisibleCount = #Dropdown.Values
	local SearchHeightOffset = SearchEnabled and 31 or 0

	local function RecalculateListSize()
		if VisibleCount > 10 then
			DropdownHolderCanvas.Size = UDim2.fromOffset(ListSizeX, 392 + SearchHeightOffset)
		else
			DropdownHolderCanvas.Size = UDim2.fromOffset(ListSizeX, DropdownListLayout.AbsoluteContentSize.Y + 10 + SearchHeightOffset)
		end
	end

	local function RecalculateCanvasSize()
		DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0, DropdownListLayout.AbsoluteContentSize.Y)
	end

	RecalculateListPosition()
	RecalculateListSize()

	Creator.AddSignal(DropdownInner:GetPropertyChangedSignal("AbsolutePosition"), RecalculateListPosition)
	Creator.AddSignal(DropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		RecalculateCanvasSize()
		RecalculateListSize()
	end)

	Creator.AddSignal(DropdownInner.MouseButton1Click, function()
		Dropdown:Open()
	end)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			local AbsPos, AbsSize = DropdownHolderFrame.AbsolutePosition, DropdownHolderFrame.AbsoluteSize
			if
				Mouse.X < AbsPos.X
				or Mouse.X > AbsPos.X + AbsSize.X
				or Mouse.Y < (AbsPos.Y - 20 - 1)
				or Mouse.Y > AbsPos.Y + AbsSize.Y
			then
				Dropdown:Close()
			end
		end
	end)

	if SearchEnabled then
		Creator.AddSignal(SearchBox:GetPropertyChangedSignal("Text"), function()
			Dropdown.SearchFilter = SearchBox.Text
			Dropdown:ApplySearch()
		end)
	end

	local ScrollFrame = self.ScrollFrame
	function Dropdown:Open()
		Dropdown.Opened = true
		ScrollFrame.ScrollingEnabled = false
		DropdownHolderCanvas.Visible = true
		TweenService:Create(
			DropdownHolderFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Size = UDim2.fromScale(1, 1) }
		):Play()
		
	end

	function Dropdown:Close()
		Dropdown.Opened = false
		ScrollFrame.ScrollingEnabled = true
		DropdownHolderFrame.Size = UDim2.fromScale(1, 0.6)
		DropdownHolderCanvas.Visible = false
		if SearchEnabled then
			SearchBox.Text = ""
			Dropdown.SearchFilter = ""
		end
	end

	function Dropdown:Display()
		local Values = Dropdown.Values
		local Str = ""

		if Config.Multi then
			for Idx, Value in next, Values do
				if Dropdown.Value[Value] then
					Str = Str .. Value .. ", "
				end
			end
			Str = Str:sub(1, #Str - 2)
		else
			Str = Dropdown.Value or ""
		end

		DropdownDisplay.Text = (Str == "" and "--" or Str)
	end

	function Dropdown:GetActiveValues()
		if Config.Multi then
			local T = {}

			for Value, Bool in next, Dropdown.Value do
				table.insert(T, Value)
			end

			return T
		else
			return Dropdown.Value and 1 or 0
		end
	end

	function Dropdown:BuildDropdownList()
		if not Dropdown.ButtonPool then
			Dropdown.ButtonPool = {}
		end

		Dropdown.Buttons = {}

		if Dropdown.NoResultsLabel then
			Dropdown.NoResultsLabel:Destroy()
			Dropdown.NoResultsLabel = nil
		end

		local Count = 0

		for Idx, Value in next, Dropdown.Values do
			local Table = {
				Value = Value,
				Selected = false
			}

			Count = Count + 1
			local CurrentCount = Count

			local Button, ButtonLabel, ButtonSelector
			local Cache

			if CurrentCount <= #Dropdown.ButtonPool then
				Cache = Dropdown.ButtonPool[CurrentCount]
				Button = Cache.Button
				ButtonLabel = Cache.Label
				ButtonSelector = Cache.Selector
				
				Button.Visible = true
				ButtonLabel.Text = Value
			else
				ButtonSelector = New("Frame", {
					Size = UDim2.fromOffset(4, 14),
					BackgroundColor3 = Color3.fromRGB(76, 194, 255),
					Position = UDim2.fromOffset(-1, 16),
					AnchorPoint = Vector2.new(0, 0.5),
					ThemeTag = {
						BackgroundColor3 = "Accent",
					},
				}, {
					New("UICorner", { CornerRadius = UDim.new(0, 2) }),
				})

				ButtonLabel = New("TextLabel", {
					FontFace = Font.new("rbxasset://fonts/families/Roboto.json"),
					Text = Value,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromOffset(10, 0),
					Name = "ButtonLabel",
					ThemeTag = { TextColor3 = "Text" },
				})

				Button = New("TextButton", {
					Size = UDim2.new(1, -5, 0, 32),
					BackgroundTransparency = 1,
					ZIndex = 23,
					Text = "",
					Parent = DropdownScrollFrame,
					ThemeTag = { BackgroundColor3 = "DropdownOption" },
				}, {
					ButtonSelector,
					ButtonLabel,
					New("UICorner", { CornerRadius = UDim.new(0, 6) }),
				})

				local BackMotor, SetBackTransparency = Creator.SpringMotor(1, Button, "BackgroundTransparency")
				local SelMotor, SetSelTransparency = Creator.SpringMotor(1, ButtonSelector, "BackgroundTransparency")
				local SelectorSizeMotor = Flipper.SingleMotor.new(6)

				SelectorSizeMotor:onStep(function(value)
					ButtonSelector.Size = UDim2.new(0, 4, 0, value)
				end)

				Creator.AddSignal(Button.MouseEnter, function()
					local CurrentTable = Dropdown.ButtonPool[CurrentCount].Table
					SetBackTransparency(CurrentTable.Selected and 0.85 or 0.89)
				end)
				Creator.AddSignal(Button.MouseLeave, function()
					local CurrentTable = Dropdown.ButtonPool[CurrentCount].Table
					SetBackTransparency(CurrentTable.Selected and 0.89 or 1)
				end)
				Creator.AddSignal(Button.MouseButton1Down, function()
					SetBackTransparency(0.92)
				end)
				Creator.AddSignal(Button.MouseButton1Up, function()
					local CurrentTable = Dropdown.ButtonPool[CurrentCount].Table
					SetBackTransparency(CurrentTable.Selected and 0.85 or 0.89)
				end)

				ButtonLabel.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						local CurrentTable = Dropdown.ButtonPool[CurrentCount].Table
						local CurrentValue = CurrentTable.Value
						local Try = not CurrentTable.Selected

						if Dropdown:GetActiveValues() == 1 and not Try and not Config.AllowNull then
						else
							if Config.Multi then
								CurrentTable.Selected = Try
								Dropdown.Value[CurrentValue] = CurrentTable.Selected and true or nil
							else
								CurrentTable.Selected = Try
								Dropdown.Value = CurrentTable.Selected and CurrentValue or nil

								for _, OtherButton in next, Dropdown.Buttons do
									OtherButton:UpdateButton()
								end
							end

							CurrentTable:UpdateButton()
							Dropdown:Display()

							Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
							Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
						end
					end
				end)

				Cache = {
					Button = Button,
					Label = ButtonLabel,
					Selector = ButtonSelector,
					SetBackTransparency = SetBackTransparency,
					SetSelTransparency = SetSelTransparency,
					SelectorSizeMotor = SelectorSizeMotor
				}
				Dropdown.ButtonPool[CurrentCount] = Cache
			end

			Cache.Table = Table

			function Table:UpdateButton()
				local CurrentValue = Table.Value
				if Config.Multi then
					Table.Selected = Dropdown.Value[CurrentValue]
					if Table.Selected then
						Cache.SetBackTransparency(0.89)
					end
				else
					Table.Selected = Dropdown.Value == CurrentValue
					Cache.SetBackTransparency(Table.Selected and 0.89 or 1)
				end

				Cache.SelectorSizeMotor:setGoal(Flipper.Spring.new(Table.Selected and 14 or 6, { frequency = 6 }))
				Cache.SetSelTransparency(Table.Selected and 0 or 1)
			end

			Table:UpdateButton()
			Dropdown:Display()

			Dropdown.Buttons[Button] = Table
		end

		if Dropdown.ButtonPool then
			for i = Count + 1, #Dropdown.ButtonPool do
				Dropdown.ButtonPool[i].Button.Visible = false
			end
		end

		VisibleCount = Count

		if Count > 0 then
			ListSizeX = 0
			for Button, Table in next, Dropdown.Buttons do
				if Button.ButtonLabel then
					if Button.ButtonLabel.TextBounds.X > ListSizeX then
						ListSizeX = Button.ButtonLabel.TextBounds.X
					end
				end
			end
			ListSizeX = ListSizeX + 30
		end

		RecalculateCanvasSize()
		RecalculateListSize()
	end

	function Dropdown:ApplySearch()
		local filterText = SearchEnabled and Dropdown.SearchFilter ~= "" and string.lower(Dropdown.SearchFilter) or nil
		local Count = 0

		for Button, Table in next, Dropdown.Buttons do
			local Value = Table.Value
			local matches = true
			if filterText then
				if not string.find(string.lower(tostring(Value)), filterText, 1, true) then
					matches = false
				end
			end

			Button.Visible = matches
			if matches then
				Count = Count + 1
			end
		end

		VisibleCount = Count

		if Count == 0 and SearchEnabled and Dropdown.SearchFilter ~= "" then
			if not Dropdown.NoResultsLabel then
				Dropdown.NoResultsLabel = New("TextLabel", {
					FontFace = Font.new("rbxasset://fonts/families/Roboto.json"),
					Text = "No results found",
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 14,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -5, 0, 32),
					ThemeTag = {
						TextColor3 = "SubText",
					},
				})
			end
			Dropdown.NoResultsLabel.Parent = DropdownScrollFrame
			Dropdown.NoResultsLabel.Visible = true
		else
			if Dropdown.NoResultsLabel then
				Dropdown.NoResultsLabel.Visible = false
			end
		end

		RecalculateCanvasSize()
		RecalculateListSize()
	end

	function Dropdown:SetValues(NewValues)
		if NewValues then
			Dropdown.Values = NewValues
		end

		Dropdown:BuildDropdownList()
	end

	function Dropdown:OnChanged(Func)
		Dropdown.Changed = Func
		Func(Dropdown.Value)
	end

	function Dropdown:SetValue(Val)
		if Dropdown.Multi then
			local nTable = {}

			for Value, Bool in next, Val do
				if table.find(Dropdown.Values, Value) then
					nTable[Value] = true
				end
			end

			Dropdown.Value = nTable
		else
			if not Val then
				Dropdown.Value = nil
			elseif table.find(Dropdown.Values, Val) then
				Dropdown.Value = Val
			end
		end

		for _, ButtonTable in next, Dropdown.Buttons do
			ButtonTable:UpdateButton()
		end
		Dropdown:Display()

		Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
		Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
	end

	function Dropdown:Destroy()
		DropdownFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Dropdown:BuildDropdownList()
	Dropdown:Display()

	local Defaults = {}

	if type(Config.Default) == "string" then
		local Idx = table.find(Dropdown.Values, Config.Default)
		if Idx then
			table.insert(Defaults, Idx)
		end
	elseif type(Config.Default) == "table" then
		for _, Value in next, Config.Default do
			local Idx = table.find(Dropdown.Values, Value)
			if Idx then
				table.insert(Defaults, Idx)
			end
		end
	elseif type(Config.Default) == "number" and Dropdown.Values[Config.Default] ~= nil then
		table.insert(Defaults, Config.Default)
	end

	if next(Defaults) then
		for i = 1, #Defaults do
			local Index = Defaults[i]
			if Config.Multi then
				Dropdown.Value[Dropdown.Values[Index]] = true
			else
				Dropdown.Value = Dropdown.Values[Index]
			end

			if not Config.Multi then
				break
			end
		end

		for _, ButtonTable in next, Dropdown.Buttons do
			ButtonTable:UpdateButton()
		end
		Dropdown:Display()
	end

	Library.Options[Idx] = Dropdown
	return Dropdown
end

return Element
