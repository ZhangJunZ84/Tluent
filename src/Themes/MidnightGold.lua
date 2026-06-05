return {
	Name = "MidnightGold",
	Accent = Color3.fromRGB(255, 180, 0), -- Honey amber gold

	AcrylicMain = Color3.fromRGB(14, 14, 16), -- Deep charcoal obsidian base
	AcrylicBorder = Color3.fromRGB(60, 55, 45), -- Warm bronze/amber steel border
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(24, 22, 18), Color3.fromRGB(10, 10, 11)), -- Dark bronze-to-black gradient
	AcrylicNoise = 0.96, -- Clean sleek frosted grain

	TitleBarLine = Color3.fromRGB(42, 38, 32), -- Soft bronze divider
	Tab = Color3.fromRGB(255, 255, 255),

	Element = Color3.fromRGB(255, 255, 255), -- Clean translucent highlighted cards
	ElementBorder = Color3.fromRGB(32, 30, 26),
	InElementBorder = Color3.fromRGB(75, 68, 55),
	ElementTransparency = 0.95, -- Frosted high-transparency overlay

	ToggleSlider = Color3.fromRGB(160, 150, 135),
	ToggleToggled = Color3.fromRGB(255, 255, 255),

	SliderRail = Color3.fromRGB(48, 44, 38),

	DropdownFrame = Color3.fromRGB(255, 255, 255),
	DropdownHolder = Color3.fromRGB(20, 20, 22),
	DropdownBorder = Color3.fromRGB(42, 38, 32),
	DropdownOption = Color3.fromRGB(255, 255, 255),

	Keybind = Color3.fromRGB(255, 255, 255),

	Input = Color3.fromRGB(255, 255, 255),
	InputFocused = Color3.fromRGB(10, 10, 11),
	InputIndicator = Color3.fromRGB(160, 150, 135),

	Dialog = Color3.fromRGB(24, 22, 20),
	DialogHolder = Color3.fromRGB(16, 16, 18),
	DialogHolderLine = Color3.fromRGB(32, 30, 28),
	DialogButton = Color3.fromRGB(32, 30, 28),
	DialogButtonBorder = Color3.fromRGB(56, 52, 45),
	DialogBorder = Color3.fromRGB(48, 44, 38),
	DialogInput = Color3.fromRGB(18, 18, 20),
	DialogInputLine = Color3.fromRGB(160, 150, 135),

	Text = Color3.fromRGB(255, 255, 255), -- High contrast crisp white
	SubText = Color3.fromRGB(160, 150, 135), -- Soft golden bronze-silver subtext
	Hover = Color3.fromRGB(255, 255, 255),
	HoverChange = 0.03,

	SidebarBackground = Color3.fromRGB(14, 14, 16), -- Same as AcrylicMain — matches TitleBar
	ContentBackground = Color3.fromRGB(22, 20, 18), -- Slightly lighter charcoal
}
