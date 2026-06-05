return {
	Name = "Aero",
	Accent = Color3.fromRGB(0, 210, 90), -- Vibrant nature-inspired grass green

	AcrylicMain = Color3.fromRGB(225, 245, 255), -- Crystal clear sky-blue water base
	AcrylicBorder = Color3.fromRGB(180, 225, 245), -- Glossy glass reflection border
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(240, 250, 255), Color3.fromRGB(205, 235, 250)), -- Sunny sky to pool-blue gradient
	AcrylicNoise = 0.97, -- Pristine glass finish

	TitleBarLine = Color3.fromRGB(180, 220, 240), -- Translucent glass line
	Tab = Color3.fromRGB(20, 50, 70),

	Element = Color3.fromRGB(255, 255, 255), -- Extremely glassy translucent card look
	ElementBorder = Color3.fromRGB(180, 220, 240),
	InElementBorder = Color3.fromRGB(215, 240, 250),
	ElementTransparency = 0.65, -- Premium high-transparency glassy overlay

	ToggleSlider = Color3.fromRGB(0, 200, 80), -- Glassy green active switch
	ToggleToggled = Color3.fromRGB(255, 255, 255),

	SliderRail = Color3.fromRGB(180, 220, 240),

	DropdownFrame = Color3.fromRGB(255, 255, 255),
	DropdownHolder = Color3.fromRGB(255, 255, 255),
	DropdownBorder = Color3.fromRGB(180, 220, 240),
	DropdownOption = Color3.fromRGB(20, 50, 70),

	Keybind = Color3.fromRGB(20, 50, 70),

	Input = Color3.fromRGB(255, 255, 255),
	InputFocused = Color3.fromRGB(240, 250, 255),
	InputIndicator = Color3.fromRGB(20, 50, 70),

	Dialog = Color3.fromRGB(230, 246, 255),
	DialogHolder = Color3.fromRGB(240, 250, 255),
	DialogHolderLine = Color3.fromRGB(215, 240, 250),
	DialogButton = Color3.fromRGB(255, 255, 255),
	DialogButtonBorder = Color3.fromRGB(180, 225, 245),
	DialogBorder = Color3.fromRGB(160, 215, 240),
	DialogInput = Color3.fromRGB(255, 255, 255),
	DialogInputLine = Color3.fromRGB(20, 50, 70),

	Text = Color3.fromRGB(20, 50, 70), -- High-readability sky-slate text
	SubText = Color3.fromRGB(75, 120, 140), -- Soft aquatic slate subtext
	Hover = Color3.fromRGB(10, 40, 60),
	HoverChange = 0.08, -- Smooth light hover transition

	SidebarBackground = Color3.fromRGB(225, 245, 255), -- Same as AcrylicMain — matches TitleBar
	ContentBackground = Color3.fromRGB(235, 248, 255), -- Slightly whiter crystal
}
