local MaterialColor = {}

-- Utility to convert Color3 to HSL
local function ToHSL(color)
	local r, g, b = color.R, color.G, color.B
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, l
	l = (max + min) / 2

	if max == min then
		h, s = 0, 0
	else
		local d = max - min
		s = l > 0.5 and d / (2 - max - min) or d / (max + min)
		if max == r then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6
	end
	return h, s, l
end

-- Utility to convert HSL to Color3
local function Hue2RGB(p, q, t)
	if t < 0 then t = t + 1 end
	if t > 1 then t = t - 1 end
	if t < 1 / 6 then return p + (q - p) * 6 * t end
	if t < 1 / 2 then return q end
	if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
	return p
end

local function FromHSL(h, s, l)
	local r, g, b
	if s == 0 then
		r, g, b = l, l, l
	else
		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = Hue2RGB(p, q, h + 1 / 3)
		g = Hue2RGB(p, q, h)
		b = Hue2RGB(p, q, h - 1 / 3)
	end
	return Color3.new(r, g, b)
end

-- Tonal Palette Generator
-- Generates a shade based on a 0-100 tone scale (0 is black, 100 is white)
local function GetTone(h, s, tone)
	-- Tone to Lightness mapping (approximation for MD3)
	local l = tone / 100
	return FromHSL(h, s, l)
end

function MaterialColor.Generate(seedColor, isDark)
	local p_h, p_s, p_l = ToHSL(seedColor)
	
	-- Secondary is less saturated
	local s_h, s_s = p_h, math.clamp(p_s * 0.3, 0, 0.5)
	
	-- Tertiary is hue shifted
	local t_h, t_s = (p_h + 0.15) % 1.0, p_s
	
	-- Neutral (Surface/Background) is very desaturated
	local n_h, n_s = p_h, math.clamp(p_s * 0.1, 0, 0.15)
	
	-- Error color (Reddish)
	local e_h, e_s = 0.0, 0.8 -- Roughly Red

	local theme = {}
	
	if isDark then
		-- Dark Mode Tones
		theme.Primary = GetTone(p_h, p_s, 80)
		theme.OnPrimary = GetTone(p_h, p_s, 20)
		theme.PrimaryContainer = GetTone(p_h, p_s, 30)
		theme.OnPrimaryContainer = GetTone(p_h, p_s, 90)

		theme.Secondary = GetTone(s_h, s_s, 80)
		theme.OnSecondary = GetTone(s_h, s_s, 20)
		theme.SecondaryContainer = GetTone(s_h, s_s, 30)
		theme.OnSecondaryContainer = GetTone(s_h, s_s, 90)

		theme.Tertiary = GetTone(t_h, t_s, 80)
		theme.OnTertiary = GetTone(t_h, t_s, 20)
		theme.TertiaryContainer = GetTone(t_h, t_s, 30)
		theme.OnTertiaryContainer = GetTone(t_h, t_s, 90)

		theme.Error = GetTone(e_h, e_s, 80)
		theme.OnError = GetTone(e_h, e_s, 20)
		theme.ErrorContainer = GetTone(e_h, e_s, 30)
		theme.OnErrorContainer = GetTone(e_h, e_s, 90)

		theme.Background = GetTone(n_h, n_s, 6)
		theme.OnBackground = GetTone(n_h, n_s, 90)

		theme.Surface = GetTone(n_h, n_s, 6)
		theme.OnSurface = GetTone(n_h, n_s, 90)
		theme.SurfaceVariant = GetTone(n_h, n_s, 30)
		theme.OnSurfaceVariant = GetTone(n_h, n_s, 80)

		theme.Outline = GetTone(n_h, n_s, 60)
		theme.OutlineVariant = GetTone(n_h, n_s, 30)

		theme.SurfaceContainerLowest = GetTone(n_h, n_s, 4)
		theme.SurfaceContainerLow = GetTone(n_h, n_s, 10)
		theme.SurfaceContainer = GetTone(n_h, n_s, 12)
		theme.SurfaceContainerHigh = GetTone(n_h, n_s, 17)
		theme.SurfaceContainerHighest = GetTone(n_h, n_s, 22)
		
		theme.InverseSurface = GetTone(n_h, n_s, 90)
		theme.InverseOnSurface = GetTone(n_h, n_s, 20)
		theme.InversePrimary = GetTone(p_h, p_s, 40)
	else
		-- Light Mode Tones
		theme.Primary = GetTone(p_h, p_s, 40)
		theme.OnPrimary = GetTone(p_h, p_s, 100)
		theme.PrimaryContainer = GetTone(p_h, p_s, 90)
		theme.OnPrimaryContainer = GetTone(p_h, p_s, 10)

		theme.Secondary = GetTone(s_h, s_s, 40)
		theme.OnSecondary = GetTone(s_h, s_s, 100)
		theme.SecondaryContainer = GetTone(s_h, s_s, 90)
		theme.OnSecondaryContainer = GetTone(s_h, s_s, 10)

		theme.Tertiary = GetTone(t_h, t_s, 40)
		theme.OnTertiary = GetTone(t_h, t_s, 100)
		theme.TertiaryContainer = GetTone(t_h, t_s, 90)
		theme.OnTertiaryContainer = GetTone(t_h, t_s, 10)

		theme.Error = GetTone(e_h, e_s, 40)
		theme.OnError = GetTone(e_h, e_s, 100)
		theme.ErrorContainer = GetTone(e_h, e_s, 90)
		theme.OnErrorContainer = GetTone(e_h, e_s, 10)

		theme.Background = GetTone(n_h, n_s, 98)
		theme.OnBackground = GetTone(n_h, n_s, 10)

		theme.Surface = GetTone(n_h, n_s, 98)
		theme.OnSurface = GetTone(n_h, n_s, 10)
		theme.SurfaceVariant = GetTone(n_h, n_s, 90)
		theme.OnSurfaceVariant = GetTone(n_h, n_s, 30)

		theme.Outline = GetTone(n_h, n_s, 50)
		theme.OutlineVariant = GetTone(n_h, n_s, 80)

		theme.SurfaceContainerLowest = GetTone(n_h, n_s, 100)
		theme.SurfaceContainerLow = GetTone(n_h, n_s, 96)
		theme.SurfaceContainer = GetTone(n_h, n_s, 94)
		theme.SurfaceContainerHigh = GetTone(n_h, n_s, 92)
		theme.SurfaceContainerHighest = GetTone(n_h, n_s, 90)
		
		theme.InverseSurface = GetTone(n_h, n_s, 20)
		theme.InverseOnSurface = GetTone(n_h, n_s, 95)
		theme.InversePrimary = GetTone(p_h, p_s, 80)
	end
	
	-- Semantic names matching old Fluent for backwards compatibility during migration, 
	-- but we should transition fully to MD3 names.
	theme.Text = theme.OnSurface
	theme.SubText = theme.OnSurfaceVariant
	theme.Accent = theme.Primary
	theme.Dialog = theme.SurfaceContainerHigh
	theme.DialogHolder = theme.SurfaceContainerLowest
	theme.Element = theme.SurfaceContainerLow
	theme.ElementBorder = theme.OutlineVariant
	theme.InElementBorder = theme.OutlineVariant
	theme.Tab = theme.OnSurfaceVariant
	theme.ToggleSlider = theme.Outline
	theme.ToggleToggled = theme.Primary
	theme.SliderRail = theme.SurfaceVariant
	theme.DropdownFrame = theme.SurfaceContainer
	theme.DropdownHolder = theme.SurfaceContainerHighest
	theme.DropdownBorder = theme.OutlineVariant
	theme.DropdownOption = theme.OnSurface
	theme.Input = theme.OnSurface
	theme.InputFocused = theme.SurfaceContainerHighest
	theme.InputIndicator = theme.Primary
	theme.TitleBarLine = theme.OutlineVariant
	theme.Keybind = theme.SurfaceContainerHighest
	theme.DialogInput = theme.SurfaceContainerHighest
	theme.DialogInputLine = theme.Outline
	theme.DialogButtonBorder = theme.OutlineVariant
	theme.DialogBorder = theme.OutlineVariant
	theme.DialogButton = theme.SurfaceContainerHighest
	theme.DialogHolderLine = theme.OutlineVariant
	theme.Hover = theme.OnSurface
	
	theme.AcrylicMain = theme.SurfaceContainer
	theme.AcrylicBorder = theme.OutlineVariant
	theme.AcrylicGradient = ColorSequence.new(theme.SurfaceContainer, theme.SurfaceContainerHighest)
	theme.AcrylicNoise = 0.9
	
	theme.ElementTransparency = 0
	
	theme.HoverChange = 0.05

	return theme
end

return MaterialColor
