local Themes = {
	Names = {
		"Dark",
		"Darker",
		"Light",
		"Aqua",
		"Amethyst",
		"Rose",
		"Synthwave",
		"Sakura",
		"MidnightGold",
		"Emerald",
		"Aero",
		"Cosmic",
		"Nord",
		"Dracula",
		"Brasil",
	},
}

for _, Theme in next, script:GetChildren() do
	local Required = require(Theme)
	Themes[Required.Name] = Required
end

return Themes
