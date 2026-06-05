return {
	Name = "Dark",
	Accent = Color3.fromRGB(0, 162, 255), -- Vibrant electric neon blue

	AcrylicMain = Color3.fromRGB(32, 32, 35), -- Clean dark charcoal grey
	AcrylicBorder = Color3.fromRGB(65, 65, 72), -- Subtle dark grey border
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(35, 35, 38), Color3.fromRGB(28, 28, 31)), -- Smooth vertical sheet gradient
	AcrylicNoise = 0.96, -- Less visible grain for cleaner frosted glass

	TitleBarLine = Color3.fromRGB(55, 55, 62), -- Very subtle line separator
	Tab = Color3.fromRGB(255, 255, 255),

	Element = Color3.fromRGB(255, 255, 255), -- Clean translucent highlighted cards
	ElementBorder = Color3.fromRGB(68, 68, 76), -- More visible card border
	InElementBorder = Color3.fromRGB(78, 78, 88),
	ElementTransparency = 0.92, -- Slightly more opaque for visible card effect

	ToggleSlider = Color3.fromRGB(180, 180, 190),
	ToggleToggled = Color3.fromRGB(255, 255, 255),

	SliderRail = Color3.fromRGB(60, 60, 68),

	DropdownFrame = Color3.fromRGB(255, 255, 255),
	DropdownHolder = Color3.fromRGB(48, 48, 54),
	DropdownBorder = Color3.fromRGB(58, 58, 66),
	DropdownOption = Color3.fromRGB(255, 255, 255),

	Keybind = Color3.fromRGB(255, 255, 255),

	Input = Color3.fromRGB(255, 255, 255),
	InputFocused = Color3.fromRGB(28, 28, 32),
	InputIndicator = Color3.fromRGB(180, 180, 190),

	Dialog = Color3.fromRGB(45, 45, 52),
	DialogHolder = Color3.fromRGB(38, 38, 44),
	DialogHolderLine = Color3.fromRGB(50, 50, 58),
	DialogButton = Color3.fromRGB(50, 50, 58),
	DialogButtonBorder = Color3.fromRGB(68, 68, 76),
	DialogBorder = Color3.fromRGB(65, 65, 72),
	DialogInput = Color3.fromRGB(38, 38, 44),
	DialogInputLine = Color3.fromRGB(180, 180, 190),

	Text = Color3.fromRGB(255, 255, 255), -- Crisp high-visibility text
	SubText = Color3.fromRGB(160, 160, 172), -- Refined silver subtext
	Hover = Color3.fromRGB(255, 255, 255),
	HoverChange = 0.03, -- Smooth, subtle change on hover

	SidebarBackground = Color3.fromRGB(32, 32, 35), -- Same as AcrylicMain — matches TitleBar tone
	ContentBackground = Color3.fromRGB(38, 38, 42), -- Slightly lighter than sidebar

	SecondaryContainer = Color3.fromRGB(27, 30, 43), -- Dark indigo for selected tab
	OnSecondaryContainer = Color3.fromRGB(255, 255, 255),
}
