local Root = script.Parent
local Themes = require(Root.Themes)
local Flipper = require(Root.Packages.Flipper)
local TweenService = game:GetService("TweenService")

local Creator = {
	Registry = {},
	Signals = {},
	TransparencyMotors = {},
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ScrollingFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ScrollBarImageColor3 = Color3.new(0, 0, 0),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.Roboto,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			TextSize = 16,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
			Font = Enum.Font.Roboto,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 16,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.Roboto,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 16,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
		},
		CanvasGroup = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
	},
}

Creator.Typography = {
	Display = { Font = Enum.Font.Roboto, Size = 36 },
	Headline = { Font = Enum.Font.Roboto, Size = 24 },
	Title = { Font = Enum.Font.Roboto, Size = 16, Weight = Enum.FontWeight.Medium },
	Label = { Font = Enum.Font.Roboto, Size = 14, Weight = Enum.FontWeight.Medium },
	Body = { Font = Enum.Font.Roboto, Size = 14 },
}

-- Geist (the TWVZ brand font) as a custom font family: the TTFs are downloaded once into the
-- executor workspace and exposed through getcustomasset. Returns nil when that isn't possible.
local FontFolder = "TluentFonts"
local FontSource = "https://cdn.jsdelivr.net/fontsource/fonts/%s@latest/latin-%d-normal.ttf"

local function LoadFontFamily(Name, Package, Weights)
	if not (writefile and readfile and isfile and isfolder and makefolder and getcustomasset) then
		return nil
	end

	local Success, Family = pcall(function()
		if not isfolder(FontFolder) then
			makefolder(FontFolder)
		end

		local Faces = {}
		for _, Weight in ipairs(Weights) do
			local Path = string.format("%s/%s-%d.ttf", FontFolder, Name, Weight)
			if not isfile(Path) then
				local Data = game:HttpGet(string.format(FontSource, Package, Weight))
				assert(#Data > 1024, "font download failed")
				writefile(Path, Data)
			end
			table.insert(Faces, {
				name = tostring(Weight),
				weight = Weight,
				style = "normal",
				assetId = getcustomasset(Path),
			})
		end

		local JsonPath = string.format("%s/%s.json", FontFolder, Name)
		writefile(JsonPath, game:GetService("HttpService"):JSONEncode({ name = Name, faces = Faces }))
		return getcustomasset(JsonPath)
	end)

	return Success and Family or nil
end

-- One monospace family for every text in the library. getgenv().TluentFont picks another
-- before the library loads.
local MonoFonts = {
	["martian-mono"] = { "MartianMono", { 400, 500, 600, 700 } },
	["geist-mono"] = { "GeistMono", { 400, 500, 600, 700 } },
	["jetbrains-mono"] = { "JetBrainsMono", { 400, 500, 600, 700 } },
	["space-mono"] = { "SpaceMono", { 400, 700 } },
}
local MonoPackage = getgenv and getgenv().TluentFont
if not MonoFonts[MonoPackage] then
	MonoPackage = "martian-mono"
end

local MonoFamily = LoadFontFamily(MonoFonts[MonoPackage][1], MonoPackage, MonoFonts[MonoPackage][2])
	or "rbxasset://fonts/families/RobotoMono.json"

Creator.Fonts = {
	Regular = Font.new(MonoFamily, Enum.FontWeight.Regular),
	Medium = Font.new(MonoFamily, Enum.FontWeight.Medium),
	SemiBold = Font.new(MonoFamily, Enum.FontWeight.SemiBold),
	Bold = Font.new(MonoFamily, Enum.FontWeight.Bold),
	Mono = Font.new(MonoFamily, Enum.FontWeight.Medium),
}

-- Text created without an explicit FontFace falls back to the family too
for _, Class in next, { "TextLabel", "TextButton", "TextBox" } do
	Creator.DefaultProperties[Class].Font = nil
	Creator.DefaultProperties[Class].FontFace = Creator.Fonts.Regular
end

function Creator.CreateRipple(Button)
	Creator.AddSignal(Button.MouseButton1Down, function()
		local parentCorner = Button:FindFirstChildOfClass("UICorner")
		local cornerRadius = parentCorner and parentCorner.CornerRadius or UDim.new(0, 8)

		local Overlay = Creator.New("Frame", {
			Name = "ClickIndicator",
			Parent = Button,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.7,
			ZIndex = 100,
		})
		Creator.New("UICorner", { CornerRadius = cornerRadius, Parent = Overlay })
		-- Short-lived, so not registered for theme updates (the registry would keep it forever)
		Overlay.BackgroundColor3 = Creator.GetThemeProperty("Text")

		local Tween = TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		})
		Tween:Play()
		
		Tween.Completed:Connect(function() 
			Overlay:Destroy() 
		end)
	end)
end

local function ApplyCustomProps(Object, Props)
	if Props.ThemeTag then
		Creator.AddThemeObject(Object, Props.ThemeTag)
	end
end

function Creator.AddSignal(Signal, Function)
	table.insert(Creator.Signals, Signal:Connect(Function))
end

function Creator.Disconnect()
	for Idx = #Creator.Signals, 1, -1 do
		local Connection = table.remove(Creator.Signals, Idx)
		Connection:Disconnect()
	end

	for Idx = #Creator.TransparencyMotors, 1, -1 do
		table.remove(Creator.TransparencyMotors, Idx)
	end
end

-- Themes only define the palette (Accent, Background, Surface..3, Line, Line2, Text, Muted, Soft);
-- everything else is derived from it here
local Derived = {}

local function Token(Theme, Property)
	local Value = Theme[Property]
	if Value == nil and Derived[Property] then
		return Derived[Property](Theme)
	end
	return Value
end

function Derived.BrandFrame(Theme)
	return Theme.Muted:Lerp(Theme.Soft, 0.4)
end

function Derived.Danger()
	return Color3.fromHex("#f87171")
end

-- Text on accent fills: dark on light accents, white on dark ones
function Derived.AccentInk(Theme)
	local Accent = Theme.Accent
	local Luminance = 0.299 * Accent.R + 0.587 * Accent.G + 0.114 * Accent.B
	return Luminance > 0.55 and Color3.fromHex("#0b0c0e") or Color3.new(1, 1, 1)
end

function Derived.AccentLine(Theme)
	return Theme.Background:Lerp(Theme.Accent, 0.45)
end

function Derived.ActiveRow(Theme)
	return Theme.Surface2:Lerp(Theme.Accent, 0.06)
end

function Creator.GetThemeProperty(Property)
	local Library = require(Root)
	local Theme = Themes[Library.Theme] or Themes.TWVZ

	-- A per-script accent (Window Accent / Library:SetAccent) wins over the theme's
	if Library.AccentColor then
		Theme = setmetatable({ Accent = Library.AccentColor }, { __index = Theme })
	end

	return Token(Theme, Property)
end

function Creator.UpdateTheme()
	for Instance, Object in next, Creator.Registry do
		for Property, ColorIdx in next, Object.Properties do
			if type(ColorIdx) == "function" then
				ColorIdx(Creator.GetThemeProperty)
			else
				Instance[Property] = Creator.GetThemeProperty(ColorIdx)
			end
		end
	end
end

local function ApplyThemeToObject(Object, Properties)
	for Property, ColorIdx in next, Properties do
		if type(ColorIdx) == "function" then
			ColorIdx(Creator.GetThemeProperty)
		else
			Object[Property] = Creator.GetThemeProperty(ColorIdx)
		end
	end
end

function Creator.AddThemeObject(Object, Properties)
	local Data = {
		Object = Object,
		Properties = Properties,
	}

	Creator.Registry[Object] = Data
	ApplyThemeToObject(Object, Properties)
	return Object
end

function Creator.OverrideTag(Object, Properties)
	Creator.Registry[Object].Properties = Properties
	for Property, ColorIdx in next, Properties do
		if type(ColorIdx) == "function" then
			ColorIdx(Creator.GetThemeProperty)
		else
			Object[Property] = Creator.GetThemeProperty(ColorIdx)
		end
	end
end

function Creator.New(Name, Properties, Children)
	local Object = Instance.new(Name)

	-- Default properties
	for Name, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[Name] = Value
	end

	-- Properties
	for Name, Value in next, Properties or {} do
		if Name ~= "ThemeTag" and Name ~= "Parent" then
			Object[Name] = Value
		end
	end

	-- Children
	for _, Child in next, Children or {} do
		Child.Parent = Object
	end

	ApplyCustomProps(Object, Properties)

	-- Parent last so the object is fully built before entering the live tree
	if Properties and Properties.Parent then
		Object.Parent = Properties.Parent
	end
	return Object
end

function Creator.SpringMotor(Initial, Instance, Prop, IgnoreDialogCheck, ResetOnThemeChange)
	IgnoreDialogCheck = IgnoreDialogCheck or false
	ResetOnThemeChange = ResetOnThemeChange or false
	local Motor = Flipper.SingleMotor.new(Initial)
	Motor:onStep(function(value)
		Instance[Prop] = value
	end)

	if ResetOnThemeChange then
		table.insert(Creator.TransparencyMotors, Motor)
		Instance.Destroying:Connect(function()
			for i = #Creator.TransparencyMotors, 1, -1 do
				if Creator.TransparencyMotors[i] == Motor then
					table.remove(Creator.TransparencyMotors, i)
					break
				end
			end
		end)
	end

	local function SetValue(Value, Ignore, Instant)
		Ignore = Ignore or false
		if not IgnoreDialogCheck then
			if not Ignore then
				if Prop == "BackgroundTransparency" and require(Root).DialogOpen then
					return
				end
			end
		end

		-- Snap without animating: avoids a RenderStepped connection for off-screen objects
		if Instant then
			Motor:stop()
			Motor._state = { complete = true, value = Value }
			Instance[Prop] = Value
			return
		end

		Motor:setGoal(Flipper.Spring.new(Value, { frequency = 8 }))
	end

	return Motor, SetValue
end

return Creator
