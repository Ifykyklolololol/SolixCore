if (ESP and ESP.Unload) then
    ESP.Unload();
end

local game = game
local GetService = game.GetService
local Service = function(Name)
    return cloneref(GetService(game, Name))
end

local HttpService = Service("HttpService")
local RunService = Service("RunService")
local Workspace = Service("Workspace")
local Players = Service("Players")

local Instance_new = Instance.new
local Color3_fromRGB = Color3.fromRGB
local Color3_new = Color3.new
local Color3_fromHSV = Color3.fromHSV
local Color3_fromHex = Color3.fromHex
local table_clear = table.clear
local table_insert = table.insert
local table_remove = table.remove
local table_unpack = table.unpack
local table_find = table.find
local table_sort = table.sort
local table_concat = table.concat
local string_find = string.find
local string_match = string.match
local string_format = string.format
local string_gsub = string.gsub
local string_lower = string.lower
local string_upper = string.upper
local string_sub = string.sub
local task_wait = task.wait
local task_spawn = task.spawn
local task_delay = task.delay
local task_defer = task.defer
local coroutine_wrap = coroutine.wrap
local coroutine_close = coroutine.close
local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume
local os_clock = os.clock
local os_date = os.date
local Vector2_new = Vector2.new
local Vector3_new = Vector3.new
local Vector3_one = Vector3.one
local Vector3_zero = Vector3.zero
local UDim2_new = UDim2.new
local UDim2_fromScale = UDim2.fromScale
local UDim2_fromOffset = UDim2.fromOffset
local UDim_new = UDim.new
local CFrame_Angles = CFrame.Angles
local CFrame_new = CFrame.new
local math_clamp = math.clamp
local math_round = math.round
local math_floor = math.floor
local math_huge = math.huge
local math_sin = math.sin
local math_min = math.min
local math_max = math.max
local math_random = math.random
local Drawing_new = Drawing.new
local Rect_new = Rect.new
local Font_new = Font.new
local ColorSequence_new = ColorSequence.new
local ColorSequenceKeypoint_new = ColorSequenceKeypoint.new
local TweenInfo_new = TweenInfo.new
local NumberSequence_new = NumberSequence.new
local NumberSequenceKeypoint_new = NumberSequenceKeypoint.new
local FindFirstChild = game.FindFirstChild
local GetChildren = game.GetChildren
local GetDescendants = game.GetDescendants
local WaitForChild = game.WaitForChild
local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA
local IsA = game.IsA

getgenv().ESP = {
    Settings = {
        Players = {
            Enabled = false,
            LocalPlayer = false,

            Font = "Tahoma",
            FontSize = 12,
            FontType = "lowercase", -- uppercase, lowercase, none

            MaxDistance = 1000,
            RefreshRate = 60,

            BoundingBox = {
                Enabled = false,
                DynamicBox = false, -- may drop fps
                IncludeAccessories = false,
                
                Rotation = 90,
                Color = {Color3_fromRGB(216, 126, 157), Color3_fromRGB(216, 126, 157)},
                Transparency = {0, 0},

                Glow = {
                    Enabled = false,
                    Rotation = 90,
                    Color = {Color3_fromRGB(216, 126, 157), Color3_fromRGB(216, 126, 157)},
                    Transparency = {0.75, 0.75},
                },

                Fill = {
                    Enabled = false,
                    Rotation = 90,
                    Color = {Color3_fromRGB(216, 126, 157), Color3_fromRGB(216, 126, 157)},
                    Transparency = {1, 0.5},
                },
            },

            Bars = {
                HealthBar = {
                    Enabled = false,
                    Position = "Left",
                    Color = {Color3_fromRGB(131, 245, 78), Color3_fromRGB(255, 255, 0), Color3_fromRGB(252, 71, 77)},

                    Type = function(Player, CharacterObjects)
                        if not IsA(Player, "Player") then return end

                        local Humanoid = CharacterObjects.Humanoid
                        if not Humanoid then return end

                        return Humanoid.Health / Humanoid.MaxHealth -- what value the bar follows
                    end,

                    Text = {
                        Enabled = false,
                        FollowBar = false,
                        Ending = "",
                        Position = "Left", -- // will ignore if FollowBar is true
                        Color = Color3_fromRGB(255, 255, 255),
                        Transparency = 0,

                        Type = function(Player, CharacterObjects)
                            if not IsA(Player, "Player") then return end

                            local Humanoid = CharacterObjects.Humanoid
                            if not Humanoid then return end

                            return Humanoid.Health, Humanoid.Health ~= Humanoid.MaxHealth -- Value the text follows, Value the text turns visible if follow bar is on
                        end,
                    },
                },

                ArmorBar = {
                    Enabled = false,
                    Position = "Bottom",
                    Color = {Color3_fromRGB(52, 131, 235), Color3_fromRGB(52, 131, 235), Color3_fromRGB(52, 131, 235)},

                    Type = function(Player, CharacterObjects)
                        if not IsA(Player, "Player") then return end

                        local Humanoid = CharacterObjects.Humanoid
                            if not Humanoid then return end

                        return Humanoid.Health / Humanoid.MaxHealth -- what value the bar follows
                    end,

                    Text = {
                        Enabled = false,
                        FollowBar = false,
                        Ending = "%",
                        Position = "Left", -- // will ignore if FollowBar is true
                        Color = Color3_fromRGB(255, 255, 255),
                        Transparency = 0,

                        Type = function(Player, CharacterObjects)
                            if not IsA(Player, "Player") then return end

                            local Humanoid = CharacterObjects.Humanoid
                            if not Humanoid then return end

                            return Humanoid.Health, Humanoid.Health ~= Humanoid.MaxHealth -- value the text follows, value the text turns visible if follow bar is on
                        end,
                    },
                },
            },

            Chams = {
                Enabled = false,
                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                Fill = {Color3_fromRGB(216, 126, 157), 0.5},
                Outline = {Color3_fromRGB(0, 0, 0), 0.5},
            },

            Name = {
                Enabled = false,
                UseDisplay = false,
                Position = "Top",
                Color = Color3_fromRGB(255, 255, 255),
                Transparency = 0,
            },

            Distance = {
                Enabled = false,
                Ending = "st",
                Position = "Bottom",
                Color = Color3_fromRGB(255, 255, 255),
                Transparency = 0,
            },

            Weapon = {
                Enabled = false,
                Position = "Bottom",
                Color = Color3_fromRGB(255, 255, 255),
                Transparency = 0,
            },

            Flags = {
                Enabled = false,
                Position = "Right",
                Color = Color3_fromRGB(255, 255, 255),
                Transparency = 0,

                Type = function(Player, CharacterObjects)
                    local Flags = {}

                    if not IsA(Player, "Player") then return Flags end

                    local Humanoid = CharacterObjects.Humanoid
                    if not Humanoid then return end

                    if Humanoid.MoveDirection.Magnitude > 0 then
                        table_insert(Flags, "moving")
                    end

                    if Humanoid.Jump then
                        table_insert(Flags, "jumping")
                    end

                    return Flags -- return a table for it to work
                end
            },
        },
    },

    Connections = {},
    Errors = {},
    Objects = {},
    Targets = {},
    Folder = "ESP",
    Font = nil,
    Holder = nil,
}

local Client = Players.LocalPlayer
local Camera = FindFirstChildWhichIsA(Workspace, "Camera")
local Viewport = Camera.ViewportSize
local ConnectionsTable = ESP.Connections
local ObjectsTable = ESP.Objects
local DrawingsTable = ESP.Drawings
local FolderLocation = ESP.Folder
local ESPErrors = ESP.Errors
local ESPSettings = ESP.Settings
local WorldToViewportPoint = Camera.WorldToViewportPoint
local ExecutorName = getexecutorname()

local Utility = {}
local FontsToDownload = {
    ["Tahoma"] = {Link = "https://github.com/LuckyHub1/LuckyHub/raw/main/zekton_rg.ttf"},
    ["Minecraftia"] = {Link = "https://github.com/LuckyHub1/LuckyHub/raw/refs/heads/main/Minecraftia.ttf"},
    ["Silkscreen"] = {Link = "https://github.com/LuckyHub1/LuckyHub/raw/refs/heads/main/Silkscreen.ttf"},
}

do -- Folders
    if not isfolder(FolderLocation) then
        makefolder(FolderLocation)
    end

    if not isfolder(FolderLocation .. "\\Fonts") then
        makefolder(FolderLocation .. "\\Fonts")
    end
end

do -- Fonts
    for Name, Table in FontsToDownload do
        if not isfile(FolderLocation .. "\\Fonts\\" .. Name .. ".ttf") then
            writefile(FolderLocation .. "\\Fonts\\" .. Name .. ".ttf", game:HttpGet(Table.Link))
        end
        
        if not isfile(FolderLocation .. "\\Fonts\\" .. Name .. ".font") or ExecutorName == "Potassium" then
            local Config = {
                name = Name,
                faces = {{
                    name = "Regular",
                    weight = 9e9,
                    style = "normal",
                    assetId = getcustomasset(FolderLocation .. "\\Fonts\\" .. Name .. ".ttf")
                }}
            }
            
            writefile(FolderLocation .. "\\Fonts\\" .. Name .. ".font", HttpService:JSONEncode(Config))
        end
    end

    if not getgenv().Fonts then
        getgenv().Fonts = {
            Loaded = {}
        }

        for _, FontPath in listfiles(FolderLocation .. "\\Fonts") do
            local Name = string_match(FontPath, FolderLocation .. "\\Fonts\\(.+)%.font")

            if Name then
                Fonts.Loaded[Name] = Font_new(getcustomasset(FontPath), Enum.FontWeight.Regular)
            end
        end
    end
end

do -- Utility
    function Utility.AddConnection(Signal, Function)
        local Connection = Signal:Connect(function(...)
            local Args = {...}
            
            local Success, Message = pcall(function() coroutine_wrap(Function)(table_unpack(Args)) end)
            
            if not Success and not ESPErrors[Message] then
                local ErrorMessage = string_format("[ERROR] | An error has occured:\n%s", Message)

                warn(ErrorMessage)
                
                ESPErrors[Message] = Message
                
                if ConnectionsTable[Connection] then
                    ConnectionsTable[Connection] = nil
                end
                
                return Connection and Connection:Disconnect()
            end
        end)
        
        if Connection and ConnectionsTable then
            table_insert(ConnectionsTable, Connection)
        end
        
        return Connection
    end

    function Utility.CreateObject(Type, Properties, Hidden)
        local Hidden = Hidden or false
        local Object = Instance_new(Type)

        for Index, Value in Properties do
            Object[Index] = Value
        end

        table_insert(ObjectsTable, Object)

        return Object
    end

    function Utility.CalculateBox(ESPSettings, Target, RootPart, Parts)
        local MinX, MinY, MaxX, MaxY = 9000, 9000, -9000, -9000
        local BoxWidth, BoxHeight = 0, 0
        local Position, OnScreen = WorldToViewportPoint(Camera, RootPart.Position)

        if ESPSettings.BoundingBox.DynamicBox then
            for _, Part in Parts do
                if IsA(Part, "BasePart") and Part.Name ~= "HumanoidRootPart" and Part.Transparency ~= 1 then
                    local PartCFrame = Part.CFrame
                    local PartSize = Part.Size
                    local Corners = {
                        PartCFrame * Vector3_new(PartSize.X / 2, PartSize.Y / 2, PartSize.Z / 2),
                        PartCFrame * Vector3_new(-PartSize.X / 2, PartSize.Y / 2, PartSize.Z / 2),
                        PartCFrame * Vector3_new(PartSize.X / 2, -PartSize.Y / 2, PartSize.Z / 2),
                        PartCFrame * Vector3_new(-PartSize.X / 2, -PartSize.Y / 2, PartSize.Z / 2),
                        PartCFrame * Vector3_new(PartSize.X / 2, PartSize.Y / 2, -PartSize.Z / 2),
                        PartCFrame * Vector3_new(-PartSize.X / 2, PartSize.Y / 2, -PartSize.Z / 2),
                        PartCFrame * Vector3_new(PartSize.X / 2, -PartSize.Y / 2, -PartSize.Z / 2),
                        PartCFrame * Vector3_new(-PartSize.X / 2, -PartSize.Y / 2, -PartSize.Z / 2),
                    }

                    for _, Corner in Corners do
                        local ScreenPosition, OnScreen = WorldToViewportPoint(Camera, Corner)

                        MinX = math_min(MinX, ScreenPosition.X)
                        MinY = math_min(MinY, ScreenPosition.Y)
                        MaxX = math_max(MaxX, ScreenPosition.X)
                        MaxY = math_max(MaxY, ScreenPosition.Y)
                    end
                end
            end
            
            BoxWidth, BoxHeight = MaxX - MinX, MaxY - MinY
        else
            local Scale = (RootPart.Size.Y * Camera.ViewportSize.Y) / (Position.Z * 2)

            BoxWidth, BoxHeight = 3 * Scale, 4.5 * Scale
            MinX, MinY = Position.X - (BoxWidth / 2), Position.Y - (BoxHeight / 2)
        end

        return BoxWidth, BoxHeight, MinX, MinY, OnScreen
    end

    function Utility.GetFontType(ESPSettings, Text)
        local FontType = string_lower(ESPSettings.FontType)

        if FontType == "uppercase" then
            return string_upper(Text)
        elseif FontType == "lowercase" then
            return string_lower(Text)
        else
            return Text
        end
    end
end

do -- Functions
    ESP.Holder = Utility.CreateObject("ScreenGui", {
		Name = "\n",
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		ResetOnSpawn = false,
		DisplayOrder = 10000,
		IgnoreGuiInset = true,
		Parent = gethui()
	})

    function ESP.AddTarget(Target, Type)
        if Target == nil then return end
        if not ESP.Targets[Type] then ESP.Targets[Type] = {} end
        if ESP.Targets[Type][Target] then return end

        local TargetInfo = {
            Objects = {},
            CharacterObjects = {},
            CharacterConnection = nil,
            ToolConnection = {Added = nil, Removed = nil},
            CurrentTool = "none",
            LastTick = os_clock()
        }

        local Objects = TargetInfo.Objects
        local LastTick = TargetInfo.LastTick
        local ToolConnection = TargetInfo.ToolConnection
        local CharacterObjects = TargetInfo.CharacterObjects
        local ESPSettings = ESPSettings[Type]
        local ESPFont = Fonts.Loaded[ESPSettings.Font]
        local ESPFontSize = ESPSettings.FontSize
        local ESPHolder = ESP.Holder
        local TextAlignments = {
            ["Left"] = "Right",
            ["Right"] = "Left",
            ["Top"] = "Center",
            ["Bottom"] = "Center",
        }

        CharacterObjects.Character = if IsA(Target, "Player") then (Target.Character or Target.CharacterAdded:Wait()) else Target
        CharacterObjects.Children = GetChildren(CharacterObjects.Character)
        CharacterObjects.Descendants = GetDescendants(CharacterObjects.Character)

        if IsA(Target, "Player") then
            CharacterObjects.HumanoidRootPart = FindFirstChild(CharacterObjects.Character, "HumanoidRootPart")
            CharacterObjects.Humanoid = FindFirstChildWhichIsA(CharacterObjects.Character, "Humanoid")
        end

        do -- Functions
            function TargetInfo.Init()
                if #Objects > 0 then return end

                if IsA(Target, "Player") then
                    TargetInfo.CharacterConnection = Utility.AddConnection(Target.CharacterAdded, function(Character)
                        CharacterObjects.Character = Character
                        CharacterObjects.HumanoidRootPart = WaitForChild(Character, "HumanoidRootPart", 10)
                        CharacterObjects.Humanoid = WaitForChild(Character, "Humanoid", 10)
                        CharacterObjects.Children = GetChildren(Character)
                        CharacterObjects.Descendants = GetDescendants(Character)
                    end)

                    if CharacterObjects.Character then
                        ToolConnection.Added = Utility.AddConnection(CharacterObjects.Character.ChildAdded, function(Child)
                            if IsA(Child, "Tool") then 
                                TargetInfo.CurrentTool = Child.Name
                            end 
                        end)
                        
                        ToolConnection.Removed = Utility.AddConnection(CharacterObjects.Character.ChildRemoved, function(Child)
                            if IsA(Child, "Tool") then 
                                TargetInfo.CurrentTool = "none"
                            end 
                        end)
                    end
                end

                Objects["Highlight"] = Utility.CreateObject("Highlight", {Parent = CharacterObjects.Character, Adornee = CharacterObjects.Character})
                Objects["TargetHolder"] = Utility.CreateObject("Frame", {Parent = ESPHolder, Visible = true, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                Objects["TopHolder"] = Utility.CreateObject("Frame", {Parent = Objects["TargetHolder"], AutomaticSize = Enum.AutomaticSize.Y, Visible = true, BackgroundTransparency = 1, AnchorPoint = Vector2_new(0, 1), Position = UDim2_new(0, -2, 0, -5), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(1, 4, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                Objects["BottomHolder"] = Utility.CreateObject("Frame", {Parent = Objects["TargetHolder"], AutomaticSize = Enum.AutomaticSize.Y, Visible = true, BackgroundTransparency = 1, Position = UDim2_new(0, -2, 1, 3), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(1, 4, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                Objects["LeftHolder"] = Utility.CreateObject("Frame", {Parent = Objects["TargetHolder"], AutomaticSize = Enum.AutomaticSize.X, Visible = true, BackgroundTransparency = 1, AnchorPoint = Vector2_new(1, 0), Position = UDim2_new(0, -4, 0, -2), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 1, 4), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                Objects["RightHolder"] = Utility.CreateObject("Frame", {Parent = Objects["TargetHolder"], AutomaticSize = Enum.AutomaticSize.X, Visible = true, BackgroundTransparency = 1, Position = UDim2_new(1, 8, 0, -2), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 1, 4), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                
                do -- Text Holders
                    Objects["TopTextHolder"] = Utility.CreateObject("Frame", {Parent = Objects["TopHolder"], AutomaticSize = Enum.AutomaticSize.Y, Visible = true, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(1, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["TopTextHolder"], VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim_new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIPadding", {Parent = Objects["TopTextHolder"], PaddingBottom = UDim_new(0, 2)})

                    Objects["BottomTextHolder"] = Utility.CreateObject("Frame", {Parent = Objects["BottomHolder"], LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.Y, Visible = true, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(1, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["BottomTextHolder"], HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim_new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIPadding", {Parent = Objects["BottomTextHolder"], PaddingTop = UDim_new(0, 2)})

                    Objects["LeftTextHolder"] = Utility.CreateObject("Frame", {Parent = Objects["LeftHolder"], AutomaticSize = Enum.AutomaticSize.XY, Visible = true, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(1, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["LeftTextHolder"], HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim_new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIPadding", {Parent = Objects["LeftTextHolder"], PaddingTop = UDim_new(0, -3)})

                    Objects["RightTextHolder"] = Utility.CreateObject("Frame", {Parent = Objects["RightHolder"], LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.XY, Visible = true, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["RightTextHolder"], HorizontalAlignment = Enum.HorizontalAlignment.Left, Padding = UDim_new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIPadding", {Parent = Objects["RightTextHolder"], PaddingTop = UDim_new(0, -3)})
                end

                do -- Bar Holders
                    Objects["TopBarHolder"] = Utility.CreateObject("Frame", {Visible = false, Parent = Objects["TopHolder"], AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(1, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["TopBarHolder"], HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim_new(0, 1), VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder})

                    Objects["BottomBarHolder"] = Utility.CreateObject("Frame", {Visible = false, Parent = Objects["BottomHolder"], AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(1, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["BottomBarHolder"], HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim_new(0, 1), VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIPadding", {Parent = Objects["BottomBarHolder"], PaddingTop = UDim_new(0, 2)})

                    Objects["LeftBarHolder"] = Utility.CreateObject("Frame", {Visible = false, Parent = Objects["LeftHolder"], AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["LeftBarHolder"], FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim_new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIPadding", {Parent = Objects["LeftBarHolder"], PaddingRight = UDim_new(0, 1)})

                    Objects["RightBarHolder"] = Utility.CreateObject("Frame", {Visible = false, Parent = Objects["RightHolder"], AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 1, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["LeftBarHolder"], FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim_new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIPadding", {Parent = Objects["RightBarHolder"], PaddingLeft = UDim_new(0, -3)})
                end
                
                do -- List Layouts
                    Utility.CreateObject("UIListLayout", {Parent = Objects["TopHolder"], VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim_new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["BottomHolder"], Padding = UDim_new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIPadding", {Parent = Objects["LeftHolder"], PaddingRight = UDim_new(0, 1)})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["LeftHolder"], FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Left, Padding = UDim_new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
                    Utility.CreateObject("UIListLayout", {Parent = Objects["RightHolder"], FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Left, Padding = UDim_new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})
                end

                do -- Box
                    Objects["BoxGlow"] = Utility.CreateObject("ImageLabel", {Parent = Objects["TargetHolder"], Image = "rbxassetid://110204605000367", ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect_new(Vector2_new(21, 21), Vector2_new(79, 79)), AutomaticSize = Enum.AutomaticSize.XY, ImageTransparency = 0.65, ResampleMode = Enum.ResamplerMode.Pixelated, Visible = true, BackgroundTransparency = 1, Position = UDim2_new(0, -21, 0, -21), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Objects["BoxGlowGradient"] = Utility.CreateObject("UIGradient", {Parent = Objects["BoxGlow"], Rotation = 90, Color = ColorSequence_new{ColorSequenceKeypoint_new(0, Color3_fromRGB(0, 0, 0)), ColorSequenceKeypoint_new(1, Color3_fromRGB(0, 0, 0))}, Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, 0), NumberSequenceKeypoint_new(1, 0)}})
                    Utility.CreateObject("UIPadding", {Parent = Objects["BoxGlow"], PaddingTop = UDim_new(0, 21), PaddingBottom = UDim_new(0, 20), PaddingLeft = UDim_new(0, 21), PaddingRight = UDim_new(0, 20)})

                    Objects["BoxOutlineHolder"] = Utility.CreateObject("Frame", {Parent = Objects["BoxGlow"], Visible = false, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Objects["BoxOutline"] = Utility.CreateObject("UIStroke", {Parent = Objects["BoxOutlineHolder"], Thickness = 3, LineJoinMode = Enum.LineJoinMode.Miter})
                    Objects["BoxOutlineGradient"] = Utility.CreateObject("UIGradient", {Parent = Objects["BoxOutline"], Rotation = 90, Color = ColorSequence_new{ColorSequenceKeypoint_new(0, Color3_fromRGB(0, 0, 0)), ColorSequenceKeypoint_new(1, Color3_fromRGB(0, 0, 0))}, Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, 0), NumberSequenceKeypoint_new(1, 0)}})

                    Objects["BoxInlineHolder"] = Utility.CreateObject("Frame", {Parent = Objects["BoxGlow"], Visible = false, BackgroundTransparency = 1, Position = UDim2_new(0, -1, 0, -1), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Objects["BoxInline"] = Utility.CreateObject("UIStroke", {Parent = Objects["BoxInlineHolder"], Color = Color3_fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter})
                    Objects["BoxInlineGradient"] = Utility.CreateObject("UIGradient", {Parent = Objects["BoxInline"], Rotation = 90, Color = ColorSequence_new{ColorSequenceKeypoint_new(0, Color3_fromRGB(0, 0, 0)), ColorSequenceKeypoint_new(1, Color3_fromRGB(255, 255, 255))}, Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, 0), NumberSequenceKeypoint_new(1, 0)}})

                    Objects["BoxFill"] = Utility.CreateObject("Frame", {Parent = Objects["BoxGlow"], Visible = false, BackgroundTransparency = 0, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Objects["BoxFillGradient"] = Utility.CreateObject("UIGradient", {Parent = Objects["BoxFill"], Rotation = 90, Color = ColorSequence_new{ColorSequenceKeypoint_new(0, Color3_fromRGB(0, 0, 0)), ColorSequenceKeypoint_new(1, Color3_fromRGB(255, 255, 255))}, Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, 1), NumberSequenceKeypoint_new(1, 1)}})
                end

                do -- Bars
                    for BarName, Bar in ESPSettings.Bars do
                        Objects[BarName .. "Outline"] = Utility.CreateObject("Frame", {Parent = Objects[Bar.Position .. "BarHolder"], ZIndex = 5, LayoutOrder = 0, Visible = true, BackgroundTransparency = 0, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(0, 0, 0)})
                        Utility.CreateObject("UIStroke", {Parent = Objects[BarName .. "Outline"], Thickness = 1, LineJoinMode = Enum.LineJoinMode.Miter})

                        Objects[BarName] = Utility.CreateObject("Frame", {Parent = Objects[BarName .. "Outline"], ZIndex = 6, LayoutOrder = 0, Visible = true, BackgroundTransparency = 0, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                        Objects[BarName .. "Gradient"] = Utility.CreateObject("UIGradient", {Parent = Objects[BarName], Rotation = 90, Color = ColorSequence_new{ColorSequenceKeypoint_new(0, Color3_fromRGB(0, 0, 0)), ColorSequenceKeypoint_new(0, Color3_fromRGB(0, 0, 0)), ColorSequenceKeypoint_new(1, Color3_fromRGB(255, 255, 255))}, Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, 0), NumberSequenceKeypoint_new(1, 0)}})
                    
                        Objects[BarName .. "Text"] = Utility.CreateObject("TextLabel", {
                            Parent = Objects[Bar.Position .. "TextHolder"],
                            FontFace = ESPFont,
                            TextSize = ESPFontSize,
                            LayoutOrder = 2,
                            TextColor3 = Color3_fromRGB(255, 255, 255),
                            Text = "",
                            AnchorPoint = Vector2_new(0, 1),
                            BorderSizePixel = 0,
                            Visible = false,
                            BackgroundTransparency = 1,
                            ZIndex = 5,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            Size = UDim2_new(1, 0, 0, 0)
                        }); Utility.CreateObject("UIStroke", {Parent = Objects[BarName .. "Text"], Color = Color3_fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter})
                    end
                end

                do -- Texts
                    Objects["TargetName"] = Utility.CreateObject("TextLabel", {
                        Parent = Objects["TopTextHolder"],
                        FontFace = ESPFont,
                        TextSize = ESPFontSize,
                        LayoutOrder = 2,
                        TextColor3 = Color3_fromRGB(255, 255, 255),
                        Text = "",
                        AnchorPoint = Vector2_new(0, 1),
                        BorderSizePixel = 0,
                        Visible = false,
                        BackgroundTransparency = 1,
                        ZIndex = 5,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2_new(1, 0, 0, 0)
                    }); Utility.CreateObject("UIStroke", {Parent = Objects["TargetName"], Color = Color3_fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter})

                    Objects["Distance"] = Utility.CreateObject("TextLabel", {
                        Parent = Objects["BottomTextHolder"],
                        FontFace = ESPFont,
                        TextSize = ESPFontSize,
                        LayoutOrder = 2,
                        TextColor3 = Color3_fromRGB(255, 255, 255),
                        Text = "",
                        AnchorPoint = Vector2_new(0, 1),
                        BorderSizePixel = 0,
                        Visible = false,
                        BackgroundTransparency = 1,
                        ZIndex = 5,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2_new(1, 0, 0, 0)
                    }); Utility.CreateObject("UIStroke", {Parent = Objects["Distance"], Color = Color3_fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter})

                    Objects["Flags"] = Utility.CreateObject("TextLabel", {
                        Parent = Objects["RightTextHolder"],
                        FontFace = ESPFont,
                        TextSize = ESPFontSize,
                        LayoutOrder = 2,
                        TextColor3 = Color3_fromRGB(255, 255, 255),
                        Text = "",
                        AnchorPoint = Vector2_new(0, 1),
                        BorderSizePixel = 0,
                        Visible = false,
                        BackgroundTransparency = 1,
                        ZIndex = 5,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2_new(1, 0, 0, 0)
                    }); Utility.CreateObject("UIStroke", {Parent = Objects["Flags"], Color = Color3_fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter})

                    Objects["Weapon"] = Utility.CreateObject("TextLabel", {
                        Parent = Objects["BottomTextHolder"],
                        FontFace = ESPFont,
                        TextSize = ESPFontSize,
                        LayoutOrder = 2,
                        TextColor3 = Color3_fromRGB(255, 255, 255),
                        Text = "none",
                        AnchorPoint = Vector2_new(0, 1),
                        BorderSizePixel = 0,
                        Visible = false,
                        BackgroundTransparency = 1,
                        ZIndex = 5,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2_new(1, 0, 0, 0)
                    }); Utility.CreateObject("UIStroke", {Parent = Objects["Weapon"], Color = Color3_fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter})
                end

                ESP.Targets[Type][Target] = TargetInfo
            end

            function TargetInfo.Update()
                if (os_clock() - LastTick) < (1 / ESPSettings.RefreshRate) then return end
                if not CharacterObjects.Children then return end
                if not CharacterObjects.Descendants then return end

                if #CharacterObjects.Children ~= #GetChildren(CharacterObjects.Character) then
                    CharacterObjects.Children = GetChildren(CharacterObjects.Character)

                    return
                end

                if #CharacterObjects.Descendants ~= #GetDescendants(CharacterObjects.Character) then
                    CharacterObjects.Descendants = GetDescendants(CharacterObjects.Character)

                    return
                end

                LastTick = os_clock()
                Objects["TargetHolder"].Visible = false
                Objects["Highlight"].Enabled = false

                if (not ESPSettings.LocalPlayer) and Target == Client then return end
                if not CharacterObjects.Character then return end
                if IsA(Target, "Player") then
                    if not CharacterObjects.HumanoidRootPart then
                        CharacterObjects.HumanoidRootPart = FindFirstChild(CharacterObjects.Character, "HumanoidRootPart")

                        return
                    end
                    
                    if not CharacterObjects.Humanoid then
                        CharacterObjects.Humanoid = FindFirstChildWhichIsA(CharacterObjects.Character, "Humanoid")

                        return
                    end
                else
                    if not CharacterObjects.HumanoidRootPart then
                        CharacterObjects.HumanoidRootPart = IsA(Target, "BasePart") and Target or CharacterObjects.Character.PrimaryPart

                        return
                    end
                end

                local Distance = (Camera.CFrame.Position - CharacterObjects.HumanoidRootPart.Position).Magnitude
                if Distance > ESPSettings.MaxDistance then return end

                local BodyParts = if ESPSettings.BoundingBox.IncludeAccessories then CharacterObjects.Descendants else CharacterObjects.Children
                local BoxWidth, BoxHeight, BoxPositionX, BoxPositionY, OnScreen = Utility.CalculateBox(ESPSettings, Target, CharacterObjects.HumanoidRootPart, (if IsA(Target, "BasePart") then {Target} else BodyParts))
                if not OnScreen then return end

                local BoxSize, BoxPosition = UDim2_fromOffset(math_floor(BoxWidth), math_floor(BoxHeight)), UDim2_fromOffset(math_floor(BoxPositionX), math_floor(BoxPositionY))
                local TargetHolder = Objects["TargetHolder"]; do
                    TargetHolder.Visible = true
                    if TargetHolder.Position ~= BoxPosition then TargetHolder.Position = BoxPosition end
                    if TargetHolder.Size ~= BoxSize then TargetHolder.Size = BoxSize end
                end

                local BoxOutline, BoxInline, BoxFill, BoxGlow = Objects["BoxOutline"], Objects["BoxInline"], Objects["BoxFill"], Objects["BoxGlow"]; do
                    local BoxEnabled, BoxColor, BoxTransparency, BoxRotation = ESPSettings.BoundingBox.Enabled, ESPSettings.BoundingBox.Color, ESPSettings.BoundingBox.Transparency, ESPSettings.BoundingBox.Rotation

                    if BoxEnabled then
                        BoxOutline.Parent.Visible = true
                        BoxOutline.Parent.Size = UDim2_fromOffset(BoxWidth, BoxHeight)
                        BoxInline.Parent.Visible = true
                        BoxInline.Parent.Size = UDim2_fromOffset(BoxWidth + 2, BoxHeight + 2)

                        local BoxInlineGradient, BoxOutlineGradient = Objects["BoxInlineGradient"], Objects["BoxOutlineGradient"]; do
                            BoxInlineGradient.Color = ColorSequence_new{ColorSequenceKeypoint_new(0, BoxColor[1]), ColorSequenceKeypoint_new(1, BoxColor[2])}
                            BoxInlineGradient.Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, BoxTransparency[1]), NumberSequenceKeypoint_new(1, BoxTransparency[2])}
                            BoxInlineGradient.Rotation = BoxRotation

                            BoxOutlineGradient.Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, BoxTransparency[1]), NumberSequenceKeypoint_new(1, BoxTransparency[2])}
                            BoxOutlineGradient.Rotation = BoxRotation
                        end

                        local BoxGlowGradient = Objects["BoxGlowGradient"]; do
                            local BoxGlowEnabled, BoxGlowColor, BoxGlowTransparency, BoxGlowRotation = ESPSettings.BoundingBox.Glow.Enabled, ESPSettings.BoundingBox.Glow.Color, ESPSettings.BoundingBox.Glow.Transparency, ESPSettings.BoundingBox.Glow.Rotation

                            if BoxGlowEnabled then
                                BoxGlow.ImageTransparency = 0
                                BoxGlowGradient.Rotation = BoxGlowRotation
                                BoxGlowGradient.Color = ColorSequence_new{ColorSequenceKeypoint_new(0, BoxGlowColor[1]), ColorSequenceKeypoint_new(1, BoxGlowColor[2])}
                                BoxGlowGradient.Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, BoxGlowTransparency[1]), NumberSequenceKeypoint_new(1, BoxGlowTransparency[2])}
                            else
                                BoxGlow.ImageTransparency = 1
                            end
                        end

                        local BoxFillGradient = Objects["BoxFillGradient"]; do
                            local BoxFillColor, BoxFillTransparency, BoxFillRotation = ESPSettings.BoundingBox.Fill.Color, ESPSettings.BoundingBox.Fill.Transparency, ESPSettings.BoundingBox.Fill.Rotation

                            BoxFill.Visible = ESPSettings.BoundingBox.Fill.Enabled
                            BoxFill.Size = UDim2_fromOffset(BoxWidth, BoxHeight)
                            BoxFillGradient.Rotation = BoxFillRotation
                            BoxFillGradient.Color = ColorSequence_new{ColorSequenceKeypoint_new(0, BoxFillColor[1]), ColorSequenceKeypoint_new(1, BoxFillColor[2])}
                            BoxFillGradient.Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, BoxFillTransparency[1]), NumberSequenceKeypoint_new(1, BoxFillTransparency[2])}
                        end
                    else
                        BoxGlow.ImageTransparency = 1
                        BoxOutline.Parent.Visible = false
                        BoxInline.Parent.Visible = false
                        BoxFill.Visible = false
                    end
                end

                for BarName, BarInfo in ESPSettings.Bars do
                    local Bar, BarOutline, BarGradient = Objects[BarName], Objects[BarName .. "Outline"], Objects[BarName .. "Gradient"]; do
                        local BarEnabled, BarColor, BarTransparency = BarInfo.Enabled, BarInfo.Color, BarInfo.Transparency
                        local NewParent = Objects[`{BarInfo.Position}BarHolder`]

                        if BarEnabled and IsA(Target, "Player") then
                            local BarValue = BarInfo.Type(Target, CharacterObjects)
                            local BarSizes = {
                                ["Top"] = UDim2_new(BarValue, 0, 0, 1),
                                ["Bottom"] = UDim2_new(BarValue, 0, 0, 1),
                                ["Left"] = UDim2_new(0, 1, BarValue, 0),
                                ["Right"] = UDim2_new(0, 1, BarValue, 0),
                            }

                            local OutlineSizes = {
                                ["Top"] = UDim2_new(1, 0, 0, 1),
                                ["Bottom"] = UDim2_new(1, 0, 0, 1),
                                ["Left"] = UDim2_new(0, 1, 1, 0),
                                ["Right"] = UDim2_new(0, 1, 1, 0),
                            }

                            local GradientRotations = {
                                ["Top"] = {-180, Vector2_new(1 - BarValue, 0)},
                                ["Bottom"] = {-180, Vector2_new(1 - BarValue, 0)},
                                ["Left"] = {90, Vector2_new(0, BarValue - 1)},
                                ["Right"] = {90, Vector2_new(0, BarValue - 1)},
                            }

                            local BarPositions = {
                                ["Top"] = {Vector2_new(0, 0), UDim2_new(0, 0, 0, 0)},
                                ["Bottom"] = {Vector2_new(0, 0), UDim2_new(0, 0, 0, 0)},
                                ["Left"] = {Vector2_new(0, 1), UDim2_new(0, 0, 1, 0)},
                                ["Right"] = {Vector2_new(0, 1), UDim2_new(0, 0, 1, 0)},
                            }

                            NewParent.Visible = true

                            Bar.AnchorPoint = BarPositions[BarInfo.Position][1]
                            Bar.Position = BarPositions[BarInfo.Position][2]
                            Bar.Size = BarSizes[BarInfo.Position]

                            BarOutline.Parent = NewParent
                            BarOutline.Size = OutlineSizes[BarInfo.Position]

                            BarGradient.Rotation = GradientRotations[BarInfo.Position][1]
                            BarGradient.Offset = GradientRotations[BarInfo.Position][2]
                            BarGradient.Color = ColorSequence_new{ColorSequenceKeypoint_new(0, BarColor[1]), ColorSequenceKeypoint_new(0, BarColor[2]), ColorSequenceKeypoint_new(1, BarColor[3])}
                        else
                            NewParent.Visible = false
                        end
                    end

                    local BarText = Objects[BarName .. "Text"]; do
                        local BarTextEnabled, BarTextColor, BarTextTransparency = BarInfo.Text.Enabled, BarInfo.Text.Color, BarInfo.Text.Transparency
                        local AnchorPoints = {
                            ["Top"] = Vector2_new(0, 0.5),
                            ["Bottom"] = Vector2_new(0, 0.5),
                            ["Left"] = Vector2_new(0.5, 0),
                            ["Right"] = Vector2_new(0.5, 0),
                        }

                        local Alignments = {
                            ["Top"] = Enum.TextXAlignment.Right,
                            ["Bottom"] = Enum.TextXAlignment.Right,
                            ["Left"] = Enum.TextXAlignment.Center,
                            ["Right"] = Enum.TextXAlignment.Center,
                        }

                        if BarTextEnabled and IsA(Target, "Player") then
                            local TextValue, TextVisible = BarInfo.Text.Type(Target, CharacterObjects)

                            BarText.Text = `{tostring(math_floor(TextValue))}{BarInfo.Text.Ending}`
                            BarText.TextColor3 = BarTextColor
                            BarText.TextTransparency = BarTextTransparency
                            BarText.UIStroke.Transparency = BarTextTransparency

                            if BarInfo.Text.FollowBar then
                                BarText.Visible = TextVisible
                                BarText.Parent = Bar
                                BarText.ZIndex = 10
                                BarText.TextXAlignment = Alignments[BarInfo.Position]
                                BarText.AnchorPoint = AnchorPoints[BarInfo.Position]
                            else
                                BarText.Visible = true
                                BarText.Parent = Objects[`{BarInfo.Text.Position}TextHolder`]
                                BarText.TextXAlignment = TextAlignments[BarInfo.Text.Position]
                                BarText.AnchorPoint = Vector2_new(0, 0)
                            end
                        else
                            BarText.Visible = false
                        end
                    end
                end

                local Chams = Objects["Highlight"]; do
                    local ChamsEnabled, ChamsFill, ChamsOutline = ESPSettings.Chams.Enabled, ESPSettings.Chams.Fill, ESPSettings.Chams.Outline
                    
                    if ChamsEnabled then
                        Chams.Enabled = true
                        Chams.DepthMode = ESPSettings.Chams.DepthMode
                        Chams.FillColor = ChamsFill[1]
                        Chams.FillTransparency = ChamsFill[2]
                        Chams.OutlineColor = ChamsOutline[1]
                        Chams.OutlineTransparency = ChamsOutline[2]
                    else
                        Chams.Enabled = false
                    end
                end

                local NameText = Objects["TargetName"]; do
                    local NameEnabled, NameColor, NameTransparency = ESPSettings.Name.Enabled, ESPSettings.Name.Color, ESPSettings.Name.Transparency
                    
                    if NameEnabled then
                        local TargetName = if ESPSettings.Name.UseDisplay then (IsA(Target, "Player") and Target.DisplayName or Target.Name) else Target.Name

                        NameText.Visible = true
                        NameText.Text = Utility.GetFontType(ESPSettings, TargetName)
                        NameText.TextXAlignment = TextAlignments[ESPSettings.Name.Position]
                        NameText.Parent = Objects[`{ESPSettings.Name.Position}TextHolder`]
                        NameText.TextColor3 = NameColor
                        NameText.TextTransparency = NameTransparency
                        NameText.UIStroke.Transparency = NameTransparency
                    else
                        NameText.Visible = false
                    end
                end

                local DistanceText = Objects["Distance"]; do
                    local DistanceEnabled, DistanceColor, DistanceTransparency = ESPSettings.Distance.Enabled, ESPSettings.Distance.Color, ESPSettings.Distance.Transparency
                    
                    if DistanceEnabled then
                        DistanceText.Visible = true
                        DistanceText.TextXAlignment = TextAlignments[ESPSettings.Distance.Position]
                        DistanceText.Parent = Objects[`{ESPSettings.Distance.Position}TextHolder`]
                        DistanceText.TextColor3 = DistanceColor
                        DistanceText.TextTransparency = DistanceTransparency
                        DistanceText.UIStroke.Transparency = DistanceTransparency
                        DistanceText.Text = Utility.GetFontType(ESPSettings, `{tostring(math_floor(Distance))}{ESPSettings.Distance.Ending}`)
                    else
                        DistanceText.Visible = false
                    end
                end

                local WeaponText = Objects["Weapon"]; do
                    local WeaponEnabled, WeaponColor, WeaponTransparency = ESPSettings.Weapon.Enabled, ESPSettings.Weapon.Color, ESPSettings.Weapon.Transparency
                    
                    if IsA(Target, "Player") and WeaponEnabled then
                        WeaponText.Visible = true
                        WeaponText.TextXAlignment = TextAlignments[ESPSettings.Weapon.Position]
                        WeaponText.Parent = Objects[`{ESPSettings.Weapon.Position}TextHolder`]
                        WeaponText.TextColor3 = WeaponColor
                        WeaponText.TextTransparency = WeaponTransparency
                        WeaponText.UIStroke.Transparency = WeaponTransparency
                        WeaponText.Text = Utility.GetFontType(ESPSettings, TargetInfo.CurrentTool)
                    else
                        WeaponText.Visible = false
                    end
                end

                local FlagsText = Objects["Flags"]; do
                    local FlagsEnabled, FlagsColor, FlagsTransparency = ESPSettings.Flags.Enabled, ESPSettings.Flags.Color, ESPSettings.Flags.Transparency
                    
                    if FlagsEnabled then
                        local Flags = ESPSettings.Flags.Type(Target, CharacterObjects)

                        FlagsText.Visible = true
                        FlagsText.TextXAlignment = TextAlignments[ESPSettings.Flags.Position]
                        FlagsText.Parent = Objects[`{ESPSettings.Flags.Position}TextHolder`]
                        FlagsText.TextColor3 = FlagsColor
                        FlagsText.TextTransparency = FlagsTransparency
                        FlagsText.UIStroke.Transparency = FlagsTransparency
                        FlagsText.Text = table_concat(Flags, "\n")
                    else
                        FlagsText.Visible = false
                    end
                end
            end

            function TargetInfo.Remove()
                for _, Object in Objects do
                    Object:Destroy()
                end

                if TargetInfo.CharacterConnection then
                    TargetInfo.CharacterConnection:Disconnect()
                    TargetInfo.CharacterConnection = nil
                end

                if ToolConnection.Added then
                    ToolConnection.Added:Disconnect()
                    ToolConnection.Added = nil
                end

                if ToolConnection.Removed then
                    ToolConnection.Removed:Disconnect()
                    ToolConnection.Removed = nil
                end

                ESP.Targets[Type][Target] = nil
            end
        end

        TargetInfo.Init()
    end
    
    function ESP.RemoveTarget(NewTarget, Type)
        for Type, _ in ESP.Settings do
            for Target, TargetInfo in ESP.Targets[Type] do
                if Target == NewTarget then
                    TargetInfo.Remove()
                end
            end
        end
    end

    function ESP.Init(RenderCallback)
        for Type, _ in ESPSettings do
            if not ESP.Targets[Type] then ESP.Targets[Type] = {} end
        end

        for _, Player in Players:GetPlayers() do
            ESP.AddTarget(Player, "Players")
        end

        Utility.AddConnection(Players.PlayerAdded, function(Player)
            ESP.AddTarget(Player, "Players")
        end)

        Utility.AddConnection(Players.PlayerRemoving, function(Player)
            ESP.RemoveTarget(Player, "Players")
        end)

        Utility.AddConnection(RunService.PreRender, RenderCallback or function()
            for Type, _ in ESP.Settings do
                for _, Target in ESP.Targets[Type] do
                    Target.Update()
                end
            end
        end)
    end

    function ESP.Unload()
        for _, Connection in ESP.Connections do
            Connection:Disconnect()
        end

        for _, Object in ESP.Objects do
            Object:Destroy()
        end

        getgenv().Fonts = nil
    end
end

return ESP;
