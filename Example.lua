local Fluent = loadstring(game:HttpGet("http://localhost:8642/dist/main.lua"))()
local SaveManager = loadstring(game:HttpGet("http://localhost:8642/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("http://localhost:8642/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Tluent Library",
    SubTitle = "Something",
    SubTitlePosition = "Side", -- "Below" or "Side" (default)
    TabStyle = "Tabs", -- "Tabs" or "Icons"
    TabWidth = 120, -- Default: 120 for Tabs, 36 for Icons
    Size = UDim2.fromOffset(520, 400),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Transparency = false,
    Theme = "Dark", -- You can use presets like Dark, Light, Aqua, etc.
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

-- Tluent provides multi-pack icon support! You can use Lucide, Solar, Craft, Geist, SF Symbols, Gravity, or raw Roblox assets.
-- 1. Standard Namespaced Prefix: Use "pack:icon_name" (e.g., "solar:home-angle-bold", "geist:settings", "gravity:home").
-- 2. Default Pack: If no prefix is specified, it defaults to Lucide (e.g., "box" maps to "lucide:box").
-- 3. Raw Roblox Assets: Use raw paths directly (e.g., "rbxassetid://92867583610071", "rbxasset://textures/...").
-- 4. Dynamic Custom Icons: Register your own custom packs dynamically using Fluent.Icons.AddIcons.

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "globe" }),
    IconTest = Window:AddTab({ 
        Title = "Icon Test", 
        Icon = "gravity:star-fill",
        Badge = { Title = "NEW", Color = Color3.fromHex("#ffe59e") }
    }),
    Settings = Window:AddTab({ Title= "Settings", Icon = "gravity:gear" })
}

local Options = Fluent.Options

do
    local VersionTag = Window:Tag({
        Title = Fluent.Version,
        Icon = "info", -- Optional
        Color = Color3.fromHex("#a1ff9e"), -- Optional, if not set, the color will be the same as the theme
        Radius = 6, -- Optional, Default: 6
    })

    -- You can change the color of the tag with the `SetColor` method
    -- And you can pass a ColorSequence too!
    task.spawn(function()
        while task.wait() do
            if Fluent.Unloaded then break end
            local Shift = os.clock() % 8 / 8
            local Keypoints = {}
            
            for i = 0, 3 do
                local RelativePos = i / 3
                local Hue = (RelativePos - Shift) % 1
                table.insert(Keypoints, ColorSequenceKeypoint.new(RelativePos, Color3.fromHSV(Hue, 0.6, 1)))
            end
            
            VersionTag:SetColor({
                Color = ColorSequence.new(Keypoints),
                Rotation = 0
            })
        end
    end)

    Window:Tag({
        Title = "Created by TWVZ",
        Icon = "flag",
    })

    Tabs.Main:AddSection({ Title = "Default Section" })
    Tabs.Main:AddParagraph({
        Title = "Paragraph",
        Content = "This is a default paragraph.\nSecond line!"
    })

    Tabs.Main:AddSection({ Title = "Centered Section", Justify = "Center" })
    Tabs.Main:AddParagraph({
        Title = "Paragraph",
        Content = "This is a centered paragraph.\nSecond line!",
        Justify = "Center"
    })

    Tabs.Main:AddSection({ Title = "Right Section", Justify = "Right" })
    Tabs.Main:AddParagraph({
        Title = "Paragraph",
        Content = "This is a right paragraph.\nSecond line!",
        Justify = "Right"
    })
    
    -- Dividers are a way to separate sections, you can set the width to make it shorter than the window
    -- In pixels Width = 100, as a scale Width = 0.5 or as a UDim2.new(0.5, 20)
    Tabs.Main:AddDivider({ Width = 10000 }) 

    Tabs.Main:AddButton({
        Title = "Notify",
        Callback = function()
            Fluent:Notify({
                Title = "Notification",
                Content = "This is a notification",
                SubContent = "SubContent", -- Optional
                Duration = 3 -- Set to nil to make the notification not disappear
            })
        end
    })

    Tabs.Main:AddButton({
        Title = "Button",
        Description = "Very important button",
        Callback = function()
            Window:Dialog({
                Title = "Title",
                Content = "This is a dialog",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            print("Confirmed the dialog.")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })



    local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "Toggle", Default = false })

    Toggle:OnChanged(function()
        print("Toggle changed:", Options.MyToggle.Value)
    end)

    Options.MyToggle:SetValue(false)


    
    local Slider = Tabs.Main:AddSlider("Slider", {
        Title = "Slider",
        Description = "This is a slider",
        Default = 2,
        Min = 0,
        Max = 5,
        Rounding = 1,
        Callback = function(Value)
            print("Slider was changed:", Value)
        end
    })

    Slider:OnChanged(function(Value)
        print("Slider changed:", Value)
    end)

    Slider:SetValue(3)



    local Dropdown = Tabs.Main:AddDropdown("Dropdown", {
        Title = "Dropdown",
        Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = false,
        Default = 1,
    })

    Dropdown:SetValue("four")

    Dropdown:OnChanged(function(Value)
        print("Dropdown changed:", Value)
    end)


    
    local MultiDropdown = Tabs.Main:AddDropdown("MultiDropdown", {
        Title = "Dropdown",
        Description = "You can select multiple values.",
        Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = true,
        Default = {"seven", "twelve"},
    })

    MultiDropdown:SetValue({
        three = true,
        five = true,
        seven = false
    })

    MultiDropdown:OnChanged(function(Value)
        local Values = {}
        for Value, State in next, Value do
            table.insert(Values, Value)
        end
        print("Mutlidropdown changed:", table.concat(Values, ", "))
    end)



    local Colorpicker = Tabs.Main:AddColorpicker("Colorpicker", {
        Title = "Colorpicker",
        Default = Color3.fromRGB(96, 205, 255)
    })

    Colorpicker:OnChanged(function()
        print("Colorpicker changed:", Colorpicker.Value)
    end)
    
    Colorpicker:SetValueRGB(Color3.fromRGB(0, 255, 140))



    local TColorpicker = Tabs.Main:AddColorpicker("TransparencyColorpicker", {
        Title = "Colorpicker",
        Description = "but you can change the transparency.",
        Transparency = 0,
        Default = Color3.fromRGB(96, 205, 255)
    })

    TColorpicker:OnChanged(function()
        print(
            "TColorpicker changed:", TColorpicker.Value,
            "Transparency:", TColorpicker.Transparency
        )
    end)



    local Keybind = Tabs.Main:AddKeybind("Keybind", {
        Title = "KeyBind",
        Mode = "Toggle", -- Always, Toggle, Hold
        Default = "LeftControl", -- String as the name of the keybind (MB1, MB2 for mouse buttons)

        -- Occurs when the keybind is clicked, Value is `true`/`false`
        Callback = function(Value)
            print("Keybind clicked!", Value)
        end,

        -- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
        ChangedCallback = function(New)
            print("Keybind changed!", New)
        end
    })

    -- OnClick is only fired when you press the keybind and the mode is Toggle
    -- Otherwise, you will have to use Keybind:GetState()
    Keybind:OnClick(function()
        print("Keybind clicked:", Keybind:GetState())
    end)

    Keybind:OnChanged(function()
        print("Keybind changed:", Keybind.Value)
    end)

    task.spawn(function()
        while true do
            wait(1)

            -- example for checking if a keybind is being pressed
            local state = Keybind:GetState()
            if state then
                print("Keybind is being held down")
            end

            if Fluent.Unloaded then break end
        end
    end)

    Keybind:SetValue("MB2", "Toggle") -- Sets keybind to MB2, mode to Hold


    local Input = Tabs.Main:AddInput("Input", {
        Title = "Input",
        Default = "Default",
        Placeholder = "Placeholder",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            print("Input changed:", Value)
        end
    })

    Input:OnChanged(function()
        print("Input updated:", Input.Value)
    end)
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

-- AutoLoad() will first try to load the autoload config (if set),
-- then fall back to restoring the last autosaved session.
SaveManager:AutoLoad()