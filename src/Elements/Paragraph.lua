local Root = script.Parent.Parent
local Components = Root.Components
local Creator = require(Root.Creator)

local Paragraph = {}
Paragraph.__index = Paragraph
Paragraph.__type = "Paragraph"

function Paragraph:New(Config)
	assert(Config.Title, "Paragraph - Missing Title")
	Config.Content = Config.Content or ""

	local JustifyMap = {
		Left = Enum.TextXAlignment.Left,
		Center = Enum.TextXAlignment.Center,
		Right = Enum.TextXAlignment.Right,
	}

	local Justify = JustifyMap[Config.Justify] or JustifyMap.Left

	local Paragraph = require(Components.Element)(Config.Title, Config.Content, Paragraph.Container, false)
	Paragraph.TitleLabel.TextXAlignment = Justify
	Paragraph.DescLabel.TextXAlignment = Justify

	return Paragraph
end

return Paragraph
