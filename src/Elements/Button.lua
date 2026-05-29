local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Icons = require(Root.Icons)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Button"

function Element:New(Config)
	assert(Config.Title, "Button - Missing Title")
	Config.Callback = Config.Callback or function() end
	Config.IconPosition = Config.IconPosition or "end"

	local ButtonFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true)

	local DefaultIcon = Config.Title:lower():find("refresh") and "refresh-cw" or "mouse-pointer-click"
	local IconValue = Config.Icon ~= false and (Config.Icon or DefaultIcon) or nil

	if IconValue then
		local IconObject = Icons.Image({
			Icon = IconValue,
			Size = UDim2.fromOffset(16, 16),
			Colors = { "Text" },
		})
		local IconFrame = IconObject.IconFrame

		if Config.IconPosition == "start" then
			IconFrame.AnchorPoint = Vector2.new(0, 0.5)
			IconFrame.Position = UDim2.new(0, 10, 0.5, 0)
			ButtonFrame.LabelHolder.Position = UDim2.fromOffset(34, 0)
			ButtonFrame.LabelHolder.Size = UDim2.new(1, -44, 0, 0)
		else
			IconFrame.AnchorPoint = Vector2.new(1, 0.5)
			IconFrame.Position = UDim2.new(1, -10, 0.5, 0)
		end

		IconFrame.Parent = ButtonFrame.Frame
	end

	Creator.AddSignal(ButtonFrame.Frame.MouseButton1Click, function()
		self.Library:SafeCallback(Config.Callback)
	end)

	return ButtonFrame
end

return Element
