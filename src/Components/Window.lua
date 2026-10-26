-- i will rewrite this someday
local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local Acrylic = require(Root.Acrylic)
local Components = script.Parent

local Spring = Flipper.Spring.new
local Instant = Flipper.Instant.new
local New = Creator.New

return function(Config)
	local Library = require(Root)

	local BarOffset = 0

	local Window = {
		Minimized = false,
		Maximized = false,
		Size = Config.Size,
		CurrentPos = 0,
		TabWidth = 0,
		TabStyle = Config.TabStyle or "Tabs",

		Position = UDim2.fromOffset(
			Camera.ViewportSize.X / 2 - Config.Size.X.Offset / 2,
			Camera.ViewportSize.Y / 2 - Config.Size.Y.Offset / 2
		),
	}

	local Dragging, DragInput, MousePos, StartPos = false
	local Resizing, ResizePos = false
	local MinimizeNotif = false

	local RailWidth = 52
	local HeaderHeight = 44
	local FooterHeight = 44
	local BodyHeight = HeaderHeight + FooterHeight + 2

	Window.AcrylicPaint = Acrylic.AcrylicPaint()

	local ResizeStartFrame = New("Frame", {
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -20, 1, -20),
	})

	local function Line(Size, Position)
		return New("Frame", {
			Size = Size,
			Position = Position,
			BorderSizePixel = 0,
			ThemeTag = {
				BackgroundColor3 = "Line",
			},
		})
	end

	-- Icon rail: one cell per tab, split by hairlines (Tab.lua adds them); scrolls when it overflows
	Window.TabHolder = New("ScrollingFrame", {
		Size = UDim2.new(0, RailWidth, 1, -BodyHeight),
		Position = UDim2.fromOffset(0, HeaderHeight + 1),
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- Footer cell under the rail, for the tab added with Pinned = true (usually Settings)
	Window.PinnedHolder = New("Frame", {
		Size = UDim2.fromOffset(RailWidth, FooterHeight),
		Position = UDim2.new(0, 0, 1, -FooterHeight),
		BackgroundTransparency = 1,
	})

	Window.Footer = New("Frame", {
		Size = UDim2.new(1, -(RailWidth + 1), 0, FooterHeight),
		Position = UDim2.new(0, RailWidth + 1, 1, -FooterHeight),
		BackgroundTransparency = 1,
	})

	Window.Tooltip = New("TextLabel", {
		Text = "",
		RichText = true,
		FontFace = Creator.Fonts.Medium,
		TextSize = 13,
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(1, 0.5),
		Visible = false,
		ZIndex = 20,
		ThemeTag = {
			BackgroundColor3 = "Surface2",
			TextColor3 = "Text",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "Line2",
			},
		}),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 9),
			PaddingRight = UDim.new(0, 9),
		}),
	})

	function Window.ShowTooltip(Text, Anchor)
		local Y = Anchor.AbsolutePosition.Y - Window.Root.AbsolutePosition.Y + Anchor.AbsoluteSize.Y / 2
		Window.Tooltip.Text = Text
		Window.Tooltip.Position = UDim2.fromOffset(-8, Y)
		Window.Tooltip.Visible = true
	end

	function Window.HideTooltip()
		Window.Tooltip.Visible = false
	end

	Window.ContainerHolder = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})

	Window.ContainerCanvas = New("Frame", {
		Size = UDim2.new(1, -(RailWidth + 1), 1, -BodyHeight),
		Position = UDim2.fromOffset(RailWidth + 1, HeaderHeight + 1),
		BackgroundTransparency = 1,
	}, {
		Window.ContainerHolder,
	})

	Window.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = Window.Size,
		Position = Window.Position,
		Parent = Config.Parent,
	}, {
		Window.AcrylicPaint.Frame,
		Line(UDim2.new(0, 1, 1, 0), UDim2.fromOffset(RailWidth, 0)),
		Line(UDim2.new(1, 0, 0, 1), UDim2.fromOffset(0, HeaderHeight)),
		Line(UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -(FooterHeight + 1))),
		Window.TabHolder,
		Window.PinnedHolder,
		Window.Footer,
		Window.ContainerCanvas,
		ResizeStartFrame,
		Window.Tooltip,
	})

	Window.TitleBar = require(script.Parent.TitleBar)({
		Title = Config.Title,
		SubTitle = Config.SubTitle,
		Brand = Config.Brand,
		Logo = Config.Logo,
		Height = HeaderHeight,
		RailWidth = RailWidth,
		Parent = Window.Root,
		Window = Window,
	})

	-- Footer: subtitle on the left, tags on the right (clear of the resize grip)
	Window.TitleBar.SubTitleLabel.Position = UDim2.fromOffset(16, 0)
	Window.TitleBar.SubTitleLabel.Parent = Window.Footer
	Window.TitleBar.TagsFrame.AnchorPoint = Vector2.new(1, 0.5)
	Window.TitleBar.TagsFrame.Position = UDim2.new(1, -22, 0.5, 0)
	Window.TitleBar.TagsFrame.Parent = Window.Footer

	if require(Root).UseAcrylic then
		Window.AcrylicPaint.AddParent(Window.Root)
	end

	local SizeMotor = Flipper.GroupMotor.new({
		X = Window.Size.X.Offset,
		Y = Window.Size.Y.Offset,
	})

	local PosMotor = Flipper.GroupMotor.new({
		X = Window.Position.X.Offset,
		Y = Window.Position.Y.Offset,
	})

	SizeMotor:onStep(function(values)
		Window.Root.Size = UDim2.new(0, values.X, 0, values.Y)
	end)

	PosMotor:onStep(function(values)
		Window.Root.Position = UDim2.new(0, values.X, 0, values.Y)
	end)

	local OldSizeX
	local OldSizeY
	Window.Maximize = function(Value, NoPos, Instant)
		Window.Maximized = Value
		Window.TitleBar.MaxButton.SetIcon(Value and "lucide:copy" or "lucide:square")

		if Value then
			OldSizeX = Window.Size.X.Offset
			OldSizeY = Window.Size.Y.Offset
		end
		local SizeX = Value and Camera.ViewportSize.X or OldSizeX
		local SizeY = Value and Camera.ViewportSize.Y or OldSizeY
		SizeMotor:setGoal({
			X = Flipper[Instant and "Instant" or "Spring"].new(SizeX, { frequency = 6 }),
			Y = Flipper[Instant and "Instant" or "Spring"].new(SizeY, { frequency = 6 }),
		})
		Window.Size = UDim2.fromOffset(SizeX, SizeY)

		if not NoPos then
			PosMotor:setGoal({
				X = Spring(Value and 0 or Window.Position.X.Offset, { frequency = 6 }),
				Y = Spring(Value and 0 or Window.Position.Y.Offset, { frequency = 6 }),
			})
		end
	end

	Creator.AddSignal(Window.TitleBar.Frame.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = true
			MousePos = Input.Position
			StartPos = Window.Root.Position

			if Window.Maximized then
				StartPos = UDim2.fromOffset(
					Mouse.X - (Mouse.X * ((OldSizeX - 100) / Window.Root.AbsoluteSize.X)),
					Mouse.Y - (Mouse.Y * (OldSizeY / Window.Root.AbsoluteSize.Y))
				)
			end

			local DragConnection
			DragConnection = Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
					if DragConnection then
						DragConnection:Disconnect()
					end
				end
			end)
		end
	end)

	Creator.AddSignal(Window.TitleBar.Frame.InputChanged, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			DragInput = Input
		end
	end)

	Creator.AddSignal(ResizeStartFrame.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Resizing = true
			ResizePos = Input.Position
		end
	end)

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - MousePos
			Window.Position = UDim2.fromOffset(StartPos.X.Offset + Delta.X, StartPos.Y.Offset + Delta.Y)
			PosMotor:setGoal({
				X = Instant(Window.Position.X.Offset),
				Y = Instant(Window.Position.Y.Offset),
			})

			if Window.Maximized then
				Window.Maximize(false, true, true)
			end
		end

		if
			(Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
			and Resizing
		then
			local Delta = Input.Position - ResizePos
			local StartSize = Window.Size

			local TargetSize = Vector3.new(StartSize.X.Offset, StartSize.Y.Offset, 0) + Vector3.new(1, 1, 0) * Delta
			local TargetSizeClamped =
				Vector2.new(math.clamp(TargetSize.X, 470, 2048), math.clamp(TargetSize.Y, 380, 2048))

			SizeMotor:setGoal({
				X = Flipper.Instant.new(TargetSizeClamped.X),
				Y = Flipper.Instant.new(TargetSizeClamped.Y),
			})
		end
	end)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if Resizing == true or Input.UserInputType == Enum.UserInputType.Touch then
			Resizing = false
			Window.Size = UDim2.fromOffset(SizeMotor:getValue().X, SizeMotor:getValue().Y)
		end
	end)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if Input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if UserInputService:GetFocusedTextBox() then return end

		if
			type(Library.MinimizeKeybind) == "table"
			and Library.MinimizeKeybind.Type == "Keybind"
		then
			if Input.KeyCode.Name == Library.MinimizeKeybind.Value then
				Window:Minimize()
			end
		elseif Input.KeyCode == Library.MinimizeKey then
			Window:Minimize()
		end
	end)

	function Window:Minimize()
		Window.Minimized = not Window.Minimized
		Window.Root.Visible = not Window.Minimized
		if not MinimizeNotif then
			MinimizeNotif = true
			local Key = Library.MinimizeKeybind and Library.MinimizeKeybind.Value or Library.MinimizeKey.Name
			Library:Notify({
				Title = "Interface",
				Content = "Press " .. Key .. " to toggle the interface.",
				Duration = 6
			})
		end
	end

	function Window:Destroy()
		if require(Root).UseAcrylic then
			Window.AcrylicPaint.Model:Destroy()
		end
		Window.Root:Destroy()
		if Window.MinimizeGui then
			Window.MinimizeGui:Destroy()
		end
	end

	----------------------------------------------------------------
	-- MINIMIZE BUTTON
	----------------------------------------------------------------
	if Config.MinimizeButton then
		local RunService = game:GetService("RunService")
		local LocalPlayer = game:GetService("Players").LocalPlayer

		local COREGUI = nil
		if not RunService:IsStudio() then
			local ok, cg = pcall(game.GetService, game, "CoreGui")
			if ok and cg then
				COREGUI = cg
			end
		end

		local guiParent = COREGUI or LocalPlayer:WaitForChild("PlayerGui")

		local MINIMIZE_GUI_NAME = "zM_GUI"
		local MINIMIZE_BUTTON_NAME = "zM_BTN"

		local MinButtonImage = Config.MinimizeButtonImage or "rbxassetid://114275042403258"
		local MinButtonSize = Config.MinimizeButtonSize or 50

		-- Create or reuse the ScreenGui
		local screenGui = guiParent:FindFirstChild(MINIMIZE_GUI_NAME)
		if not screenGui then
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = MINIMIZE_GUI_NAME
			screenGui.ResetOnSpawn = false
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.DisplayOrder = 999
			screenGui.Parent = guiParent
		elseif screenGui.Parent ~= guiParent then
			screenGui.Parent = guiParent
		end

		-- Create or reuse the button
		local frame = screenGui:FindFirstChild(MINIMIZE_BUTTON_NAME)
		if not frame then
			frame = Instance.new("ImageButton")
			frame.Name = MINIMIZE_BUTTON_NAME
			frame.Size = UDim2.new(0, MinButtonSize, 0, MinButtonSize)
			frame.Image = MinButtonImage
			frame.ScaleType = Enum.ScaleType.Stretch
			frame.BackgroundTransparency = 1
			frame.Parent = screenGui

			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 0)
			uiCorner.Parent = frame

			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 1.8
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.Parent = frame
		end

		-- Position persistence
		local framePosition = UDim2.new(0, 100, 0, 100)
		if getgenv and getgenv().MFP then
			framePosition = getgenv().MFP
		end
		frame.Position = framePosition

		if getgenv then
			getgenv().MG = screenGui
		end

		Window.MinimizeGui = screenGui

		-- Theme-aware border colors
		local cachedStroke = frame:FindFirstChildOfClass("UIStroke")
		local function getAccentColor()
			return Creator.GetThemeProperty("Accent")
		end

		local function brighten(color, factor)
			local r = math.clamp(color.R + factor, 0, 1)
			local g = math.clamp(color.G + factor, 0, 1)
			local b = math.clamp(color.B + factor, 0, 1)
			return Color3.new(r, g, b)
		end

		local function setBorderColor(color)
			if cachedStroke then
				cachedStroke.Color = color
			end
		end

		-- Set initial accent color
		setBorderColor(getAccentColor())

		-- Register the stroke with the theme system so it updates on theme change
		Creator.AddThemeObject(cachedStroke, {
			Color = function(GetTheme)
				-- Only update if not hovering/dragging (base state)
				if not Window._minBtnHovering and not Window._minBtnDragging then
					cachedStroke.Color = GetTheme("Accent")
				end
			end,
		})

		-- Drag state
		local dragging = false
		local isHovering = false
		local dragStart = nil
		local startPos = nil
		local totalDragDistance = 0
		local DRAG_THRESHOLD = 5
		local LERP_SPEED = 0.5
		local targetPosition = frame.Position

		Window._minBtnHovering = false
		Window._minBtnDragging = false

		Creator.AddSignal(frame.MouseEnter, function()
			isHovering = true
			Window._minBtnHovering = true
			setBorderColor(brighten(getAccentColor(), 0.2))
		end)

		Creator.AddSignal(frame.MouseLeave, function()
			isHovering = false
			Window._minBtnHovering = false
			if not dragging then
				setBorderColor(getAccentColor())
			end
		end)

		Creator.AddSignal(frame.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				Window._minBtnDragging = true
				dragStart = Vector2.new(input.Position.X, input.Position.Y)
				startPos = frame.Position
				totalDragDistance = 0
				setBorderColor(brighten(getAccentColor(), 0.35))
			end
		end)

		Creator.AddSignal(UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local currentPos = Vector2.new(input.Position.X, input.Position.Y)
				local delta = currentPos - dragStart
				totalDragDistance = delta.Magnitude

				targetPosition = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)

		Creator.AddSignal(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if dragging then
					dragging = false
					Window._minBtnDragging = false
					if totalDragDistance < DRAG_THRESHOLD then
						Window:Minimize()
					end

					-- Clamp to viewport so the button can't be lost off-screen
					local vpSize = Camera.ViewportSize
					local clampedX = math.clamp(targetPosition.X.Offset, 0, vpSize.X - MinButtonSize)
					local clampedY = math.clamp(targetPosition.Y.Offset, 0, vpSize.Y - MinButtonSize)
					framePosition = UDim2.new(0, clampedX, 0, clampedY)

					if getgenv then
						getgenv().MFP = framePosition
					end
					frame.Position = framePosition
					setBorderColor(isHovering and brighten(getAccentColor(), 0.2) or getAccentColor())
				end
			end
		end)

		Creator.AddSignal(RunService.RenderStepped, function()
			if dragging then
				local currentPos = frame.Position
				local newX = currentPos.X.Offset + (targetPosition.X.Offset - currentPos.X.Offset) * LERP_SPEED
				local newY = currentPos.Y.Offset + (targetPosition.Y.Offset - currentPos.Y.Offset) * LERP_SPEED

				frame.Position = UDim2.new(
					targetPosition.X.Scale,
					newX,
					targetPosition.Y.Scale,
					newY
				)
			end
		end)

		Creator.AddSignal(frame.AncestryChanged, function()
			if not frame:IsDescendantOf(game) then
				Window.MinimizeGui = nil
			end
		end)
	end

	local DialogModule = require(Components.Dialog):Init(Window)
	function Window:Dialog(Config)
		local Dialog = DialogModule:Create()
		Dialog.Title.Text = Config.Title

		local Content = New("TextLabel", {
			FontFace = Creator.Fonts.Regular,
			Text = Config.Content,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, -48, 1, 0),
			Position = UDim2.fromOffset(24, 64),
			BackgroundTransparency = 1,
			Parent = Dialog.Root,
			ClipsDescendants = false,
			ThemeTag = {
				TextColor3 = "Muted",
			},
		})

		New("UISizeConstraint", {
			MinSize = Vector2.new(300, 165),
			MaxSize = Vector2.new(620, math.huge),
			Parent = Dialog.Root,
		})

		local dialogWidth = math.clamp(Content.TextBounds.X + 48, 300, math.max(300, Window.Size.X.Offset - 120))
		Content.Size = UDim2.new(0, dialogWidth - 48, 0, 0)
		Content.TextWrapped = true
		
		local dialogHeight = math.max(165, Content.TextBounds.Y + 150)
		Dialog.Root.Size = UDim2.fromOffset(dialogWidth, dialogHeight)
		Content.Size = UDim2.new(1, -48, 0, Content.TextBounds.Y)

		for _, Button in next, Config.Buttons do
			Dialog:Button(Button.Title, Button.Callback)
		end

		Dialog:Open()
	end

	function Window:Tag(Config)
		return self.TitleBar:AddTag(Config)
	end

	function Window:SetTitle(Text)
		self.TitleBar:SetTitle(Text)
	end

	function Window:SetSubtitle(Text)
		self.TitleBar:SetSubtitle(Text)
	end

	local TabModule = require(Components.Tab):Init(Window)
	function Window:AddTab(TabConfig)
		local Parent = TabConfig.Pinned and Window.PinnedHolder or Window.TabHolder
		local Tab = TabModule:New(TabConfig.Title, TabConfig.Icon, Parent, TabConfig)
		if TabConfig.Badge then
			Tab:AddBadge(TabConfig.Badge)
		end
		return Tab
	end

	function Window:SelectTab(Tab)
		TabModule:SelectTab(Tab)
	end

	return Window
end
