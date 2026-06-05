return {
	Name = "Cosmic",
	Accent = Color3.fromRGB(255, 210, 80), -- Glowing celestial starlight gold

	AcrylicMain = Color3.fromRGB(12, 10, 24), -- Deep space obsidian indigo base
	AcrylicBorder = Color3.fromRGB(85, 30, 95), -- Space-dust magenta/purple border
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(36, 16, 60), Color3.fromRGB(10, 8, 20)), -- Swirling nebula purple-to-indigo
	AcrylicNoise = 0.94, -- Soft stardust celestial grain

	TitleBarLine = Color3.fromRGB(56, 24, 76), -- Starfield divider
	Tab = Color3.fromRGB(255, 255, 255),

	Element = Color3.fromRGB(255, 255, 255), -- Clean translucent highlighted cards
	ElementBorder = Color3.fromRGB(42, 20, 64),
	InElementBorder = Color3.fromRGB(110, 40, 120),
	ElementTransparency = 0.95, -- Frosted high-transparency overlay

	ToggleSlider = Color3.fromRGB(170, 150, 190),
	ToggleToggled = Color3.fromRGB(255, 255, 255),

	SliderRail = Color3.fromRGB(56, 24, 76),

	DropdownFrame = Color3.fromRGB(255, 255, 255),
	DropdownHolder = Color3.fromRGB(16, 12, 32),
	DropdownBorder = Color3.fromRGB(48, 20, 72),
	DropdownOption = Color3.fromRGB(255, 255, 255),

	Keybind = Color3.fromRGB(255, 255, 255),

	Input = Color3.fromRGB(255, 255, 255),
	InputFocused = Color3.fromRGB(10, 8, 20),
	InputIndicator = Color3.fromRGB(170, 150, 190),

	Dialog = Color3.fromRGB(22, 16, 40),
	DialogHolder = Color3.fromRGB(14, 10, 26),
	DialogHolderLine = Color3.fromRGB(38, 22, 60),
	DialogButton = Color3.fromRGB(38, 22, 60),
	DialogButtonBorder = Color3.fromRGB(68, 32, 90),
	DialogBorder = Color3.fromRGB(58, 28, 80),
	DialogInput = Color3.fromRGB(18, 12, 32),
	DialogInputLine = Color3.fromRGB(170, 150, 190),

	Text = Color3.fromRGB(255, 255, 255), -- Crisp high-visibility white
	SubText = Color3.fromRGB(170, 150, 190), -- Soft cosmic stardust purple subtext
	Hover = Color3.fromRGB(255, 255, 255),
	HoverChange = 0.03,

	SidebarBackground = Color3.fromRGB(12, 10, 24), -- Same as AcrylicMain — matches TitleBar
	ContentBackground = Color3.fromRGB(20, 16, 38), -- Deep space obsidian
}
