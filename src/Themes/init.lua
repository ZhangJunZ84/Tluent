local MaterialColor = require(script.MaterialColor)

local Presets = {
	Dark = { Seed = Color3.fromRGB(0, 162, 255), IsDark = true },
	Darker = { Seed = Color3.fromRGB(128, 128, 128), IsDark = true },
	Light = { Seed = Color3.fromRGB(0, 162, 255), IsDark = false },
	Aqua = { Seed = Color3.fromRGB(0, 255, 255), IsDark = true },
	Amethyst = { Seed = Color3.fromRGB(155, 89, 182), IsDark = true },
	Rose = { Seed = Color3.fromRGB(255, 0, 127), IsDark = true },
	Sakura = { Seed = Color3.fromRGB(255, 183, 197), IsDark = false },
	Emerald = { Seed = Color3.fromRGB(46, 204, 113), IsDark = true },
}

local Themes = {
	Names = {},
	Presets = Presets,
	MaterialColor = MaterialColor
}

for Name, Preset in next, Presets do
	table.insert(Themes.Names, Name)
	Themes[Name] = MaterialColor.Generate(Preset.Seed, Preset.IsDark)
	Themes[Name].Name = Name
end

return Themes
