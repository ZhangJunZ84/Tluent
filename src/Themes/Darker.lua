return {
	Name = "Darker",
	Accent = Color3.fromRGB(10, 180, 255), -- Electric glowing cyan-blue

	AcrylicMain = Color3.fromRGB(10, 10, 10), -- Extreme pitch black
	AcrylicBorder = Color3.fromRGB(32, 32, 35), -- Sleek dark steel border
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(16, 16, 18), Color3.fromRGB(6, 6, 8)), -- Darkest vertical obsidian gradient
	AcrylicNoise = 0.97, -- Clean, minimal frosted grain

	TitleBarLine = Color3.fromRGB(28, 28, 30), -- Very subtle dark divider
	Tab = Color3.fromRGB(255, 255, 255),

	Element = Color3.fromRGB(255, 255, 255),
	ElementBorder = Color3.fromRGB(26, 26, 28), -- Minimalist element bounds
	InElementBorder = Color3.fromRGB(40, 40, 45),
	ElementTransparency = 0.96, -- Frosted high-transparency overlay

	ToggleSlider = Color3.fromRGB(150, 150, 160),
	ToggleToggled = Color3.fromRGB(255, 255, 255),

	SliderRail = Color3.fromRGB(40, 40, 45),

	DropdownFrame = Color3.fromRGB(255, 255, 255),
	DropdownHolder = Color3.fromRGB(20, 20, 22),
	DropdownBorder = Color3.fromRGB(28, 28, 30),
	DropdownOption = Color3.fromRGB(255, 255, 255),

	Keybind = Color3.fromRGB(255, 255, 255),

	Input = Color3.fromRGB(255, 255, 255),
	InputFocused = Color3.fromRGB(12, 12, 14),
	InputIndicator = Color3.fromRGB(150, 150, 160),

	Dialog = Color3.fromRGB(18, 18, 20),
	DialogHolder = Color3.fromRGB(12, 12, 14),
	DialogHolderLine = Color3.fromRGB(24, 24, 26),
	DialogButton = Color3.fromRGB(24, 24, 26),
	DialogButtonBorder = Color3.fromRGB(40, 40, 45),
	DialogBorder = Color3.fromRGB(32, 32, 35),
	DialogInput = Color3.fromRGB(16, 16, 18),
	DialogInputLine = Color3.fromRGB(150, 150, 160),

	Text = Color3.fromRGB(255, 255, 255), -- High contrast bright white
	SubText = Color3.fromRGB(130, 130, 140), -- Dimmed slate subtext
	Hover = Color3.fromRGB(255, 255, 255),
	HoverChange = 0.03, -- Smooth micro-animation hover effect
}
