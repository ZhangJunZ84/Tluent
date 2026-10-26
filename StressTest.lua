-- Stress test: builds a large UI, generates a big config and measures build/load time and frame hitches.
-- Run with `npm run live-build` serving the repo. To compare against the pre-optimization build,
-- set getgenv().TluentStressVersion = "old" before executing (needs dist/old/ built).

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local VERSION = (getgenv and getgenv().TluentStressVersion) or "new"
local BASE = "http://localhost:8642/"

local Settings = {
	Tabs = 8,
	SectionsPerTab = 5,
	TogglesPerSection = 3,
	SlidersPerSection = 2,
	DropdownValues = 40, -- per regular dropdown (one single + one multi per section)
	BigDropdowns = 4, -- extra dropdowns with BigDropdownValues each
	BigDropdownValues = 500,
	CallbackCost = 0.0002, -- seconds of busy work per callback call (simulates script logic)
	YieldingToggles = 5, -- toggles whose callback yields when enabled (simulates InvokeServer)
	YieldTime = 0.3,
	Seed = 42,
}

if getgenv and getgenv().Fluent then
	pcall(function() getgenv().Fluent:Destroy() end)
end

local function log(fmt, ...)
	warn(("[Stress:%s] " .. fmt):format(VERSION, ...))
end

local function busy()
	local stop = os.clock() + Settings.CallbackCost
	while os.clock() < stop do end
end

-- Runs fn and samples Heartbeat until two frames after it returns, so a blocking call shows up as one huge frame
local function measure(fn)
	local frames, maxDt, slow = 0, 0, 0
	local conn = RunService.Heartbeat:Connect(function(dt)
		frames += 1
		if dt > maxDt then maxDt = dt end
		if dt > 0.05 then slow += 1 end
	end)

	local start = os.clock()
	fn()
	local elapsed = os.clock() - start
	task.wait()
	task.wait()
	conn:Disconnect()

	return { elapsed = elapsed, frames = frames, maxDt = maxDt, slow = slow }
end

local function fmt(m)
	return ("%.3fs | frames: %d | pior frame: %.0fms | frames >50ms: %d"):format(m.elapsed, m.frames, m.maxDt * 1000, m.slow)
end

-- 1. Library
local Fluent, SaveManager
local libStart = os.clock()
if VERSION == "old" then
	Fluent = loadstring(game:HttpGet(BASE .. "dist/old/main.lua"))()
	SaveManager = loadstring(game:HttpGet(BASE .. "dist/old/SaveManager.lua"))()
else
	Fluent = loadstring(game:HttpGet(BASE .. "dist/main.lua"))()
	SaveManager = loadstring(game:HttpGet(BASE .. "Addons/SaveManager.lua"))()
end
local libTime = os.clock() - libStart

local rng = Random.new(Settings.Seed)
local Options = Fluent.Options
local Specs = {} -- idx -> generator for its saved entry
local Counters = { Toggle = 0, Slider = 0, Dropdown = 0, Colorpicker = 0, Input = 0, Keybind = 0 }
local Keys = { "Q", "R", "F", "G", "X", "Z", "V", "B" }

local function makeValues(n)
	local values = {}
	for i = 1, n do
		values[i] = "Item " .. i
	end
	return values
end

local function addDropdown(section, idx, n, multi, search)
	local values = makeValues(n)
	section:AddDropdown(idx, {
		Title = idx,
		Values = values,
		Multi = multi,
		Default = multi and {} or 1,
		Search = search,
		Callback = busy,
	})
	Counters.Dropdown += 1
	Specs[idx] = function()
		if multi then
			local picked = {}
			for _ = 1, rng:NextInteger(1, math.min(10, n)) do
				picked[values[rng:NextInteger(1, n)]] = true
			end
			return { type = "Dropdown", idx = idx, value = picked, multi = true }
		end
		return { type = "Dropdown", idx = idx, value = values[rng:NextInteger(2, n)], multi = false }
	end
end

-- 2. Build UI
local totalElements = 0
local tabTimes = {}
local firstTabTime = 0
local memBefore = collectgarbage("count")
local buildMetrics = measure(function()
	local Window = Fluent:CreateWindow({
		Title = "Tluent Stress",
		SubTitle = VERSION,
		TabWidth = 140,
		Size = UDim2.fromOffset(580, 460),
		Acrylic = false,
		Theme = "TWVZ",
		Brand = "TWVZ",
	})

	local yieldingLeft = Settings.YieldingToggles

	for t = 1, Settings.Tabs do
		local tabStart = os.clock()
		local Tab = Window:AddTab({ Title = "Tab " .. t, Icon = "box" })
		if t == 1 then
			firstTabTime = os.clock() - tabStart -- includes fetching the icon pack
		end

		for s = 1, Settings.SectionsPerTab do
			local Section = Tab:AddSection("Section " .. t .. "." .. s)
			local prefix = ("T%dS%d_"):format(t, s)

			for i = 1, Settings.TogglesPerSection do
				local idx = prefix .. "Toggle" .. i
				local yields = yieldingLeft > 0
				if yields then yieldingLeft -= 1 end

				Section:AddToggle(idx, {
					Title = idx .. (yields and " (yield)" or ""),
					Default = false,
					Callback = function(v)
						busy()
						if yields and v then
							task.wait(Settings.YieldTime)
						end
					end,
				})
				Counters.Toggle += 1
				Specs[idx] = function()
					return { type = "Toggle", idx = idx, value = true }
				end
			end

			for i = 1, Settings.SlidersPerSection do
				local idx = prefix .. "Slider" .. i
				Section:AddSlider(idx, { Title = idx, Default = 0, Min = 0, Max = 100, Rounding = 1, Callback = busy })
				Counters.Slider += 1
				Specs[idx] = function()
					return { type = "Slider", idx = idx, value = tostring(rng:NextInteger(1, 100)) }
				end
			end

			addDropdown(Section, prefix .. "Dropdown", Settings.DropdownValues, false, false)
			addDropdown(Section, prefix .. "Multi", Settings.DropdownValues, true, false)

			local colorIdx = prefix .. "Color"
			Section:AddColorpicker(colorIdx, { Title = colorIdx, Default = Color3.new(1, 1, 1), Callback = busy })
			Counters.Colorpicker += 1
			Specs[colorIdx] = function()
				local c = Color3.fromRGB(rng:NextInteger(0, 255), rng:NextInteger(0, 255), rng:NextInteger(0, 255))
				return { type = "Colorpicker", idx = colorIdx, value = c:ToHex(), transparency = 0 }
			end

			local inputIdx = prefix .. "Input"
			Section:AddInput(inputIdx, { Title = inputIdx, Default = "", Callback = busy })
			Counters.Input += 1
			Specs[inputIdx] = function()
				return { type = "Input", idx = inputIdx, text = "text " .. rng:NextInteger(1, 1e6) }
			end

			local keyIdx = prefix .. "Keybind"
			Section:AddKeybind(keyIdx, { Title = keyIdx, Default = "E", Mode = "Toggle", Callback = busy })
			Counters.Keybind += 1
			Specs[keyIdx] = function()
				return { type = "Keybind", idx = keyIdx, key = Keys[rng:NextInteger(1, #Keys)], mode = "Hold" }
			end
		end

		tabTimes[t] = os.clock() - tabStart
		log("[%d/%d] aba construída (%.3fs)", t, Settings.Tabs, tabTimes[t])
	end

	local bigStart = os.clock()
	local BigTab = Window:AddTab({ Title = "Big", Icon = "list" })
	local BigSection = BigTab:AddSection("Big dropdowns")
	for i = 1, Settings.BigDropdowns do
		addDropdown(BigSection, "BigDropdown" .. i, Settings.BigDropdownValues, i % 2 == 0, true)
	end
	tabTimes[#tabTimes + 1] = os.clock() - bigStart

	Window:SelectTab(1)
end)

for _, n in next, Counters do
	totalElements += n
end
local memAfterBuild = collectgarbage("count")
local instanceCount = #Fluent.GUI:GetDescendants()
log("UI: %d elementos construídos", totalElements)

-- 3. Generate config (every value differs from the defaults so Load does real work)
SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("TluentStress")

local data = { objects = {} }
for idx, gen in next, Specs do
	table.insert(data.objects, gen())
end
writefile("TluentStress/settings/stress.json", HttpService:JSONEncode(data))
log("config gerada: %d opções", #data.objects)

-- 4. Loads
local loadFresh = measure(function()
	assert(SaveManager:Load("stress"))
end)
local loadAgain = measure(function()
	assert(SaveManager:Load("stress"))
end)

-- 5. Dropdown open cost (with the lazy list, the first open pays for building the buttons)
local function openCost(idx)
	local dropdown = Options[idx]
	local first = measure(function()
		dropdown:Open()
		dropdown:Close()
	end)
	local second = measure(function()
		dropdown:Open()
		dropdown:Close()
	end)
	return ("%s: 1ª %.0fms (pior frame %.0fms) | 2ª %.0fms"):format(
		idx, first.elapsed * 1000, first.maxDt * 1000, second.elapsed * 1000
	)
end
local openSmall = openCost("T1S1_Dropdown")
local openBig = openCost("BigDropdown1")
local openBigMulti = openCost("BigDropdown2")
local instancesAfterOpen = #Fluent.GUI:GetDescendants()

local tabLines = {}
for i, t in ipairs(tabTimes) do
	tabLines[i] = ("%.3f"):format(t)
end

local executor = identifyexecutor and table.concat({ identifyexecutor() }, " ") or "?"

local report = table.concat({
	("Tluent stress test - versão %s - executor %s"):format(VERSION, executor),
	("Settings: %s"):format(HttpService:JSONEncode(Settings)),
	("Elementos: %d (toggles %d, sliders %d, dropdowns %d, colorpickers %d, inputs %d, keybinds %d)"):format(
		totalElements, Counters.Toggle, Counters.Slider, Counters.Dropdown, Counters.Colorpicker, Counters.Input, Counters.Keybind
	),
	("Carregar lib (HttpGet+loadstring): %.3fs"):format(libTime),
	"Construir UI:            " .. fmt(buildMetrics),
	("  1ª aba (inclui ícones): %.3fs"):format(firstTabTime),
	("  por aba (s): %s"):format(table.concat(tabLines, ", ")),
	("  instâncias na GUI: %d (após abrir dropdowns: %d)"):format(instanceCount, instancesAfterOpen),
	("  memória Lua: %.1fMB -> %.1fMB"):format(memBefore / 1024, memAfterBuild / 1024),
	"Load config (mudanças):  " .. fmt(loadFresh),
	"Load config (idêntica):  " .. fmt(loadAgain),
	"Abrir dropdown:",
	"  " .. openSmall,
	"  " .. openBig,
	"  " .. openBigMulti,
}, "\n")

warn("\n" .. report)
pcall(writefile, ("TluentStress/results-%s.txt"):format(VERSION), report)
if setclipboard then
	pcall(setclipboard, report)
end

Fluent:Notify({
	Title = "Stress test",
	Content = VERSION,
	SubContent = ("UI %.2fs | load %.2fs / %.2fs"):format(buildMetrics.elapsed, loadFresh.elapsed, loadAgain.elapsed),
	Duration = 15,
})
