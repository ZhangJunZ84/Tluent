local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

local Divider = {}
Divider.__index = Divider
Divider.__type = "Divider"

function Divider:New(Config)
	Config = Config or {}
	
	local LineWidth = UDim2.new(1, 0, 0, 1)
	if Config.Width then
		if typeof(Config.Width) == "UDim2" then
			LineWidth = UDim2.new(Config.Width.X.Scale, Config.Width.X.Offset, 0, 1)
		elseif typeof(Config.Width) == "number" then
			if Config.Width > 1 then
				LineWidth = UDim2.new(0, Config.Width, 0, 1)
			else
				LineWidth = UDim2.new(Config.Width, 0, 0, 1)
			end
		end
	end

	local DividerFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 9),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = self.Container,
		LayoutOrder = 7,
	}, {
		New("Frame", {
			Size = LineWidth,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.5,
			ThemeTag = {
				BackgroundColor3 = "TitleBarLine",
			},
		})
	})

	local DividerObj = {
		Frame = DividerFrame,
		Type = "Divider",
	}

	function DividerObj:Destroy()
		DividerFrame:Destroy()
	end

	return DividerObj
end

return Divider
