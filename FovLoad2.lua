if Visuals and Visuals.Unload then
    Visuals.Unload()
end

if not LPH_OBFUSCATED then
    LPH_NO_VIRTUALIZE = function(Func) return Func end
end

local game = game
local GetService = game.GetService
local Service = function(Name)
    return cloneref(GetService(game, Name))
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Locals
local Client = Players.LocalPlayer
local Camera = Workspace:FindFirstChildWhichIsA("Camera")
local WorldToViewportPoint = Camera.WorldToViewportPoint

-- Utility shortcuts
local Color3_fromRGB = Color3.fromRGB
local Vector2_new = Vector2.new
local Vector3_new = Vector3.new
local UDim2_new = UDim2.new
local UDim_new = UDim.new
local os_clock = os.clock
local table_insert = table.insert
local table_unpack = table.unpack
local math_pi = math.pi
local math_cos = math.cos
local math_sin = math.sin
local math_deg = math.deg

-- Visuals table
local Visuals = {}

Visuals.Settings = {
    Font = "Tahoma",
    FontSize = 12,
    RefreshRate = 60,

    Crosshair = {
        Enabled = true,
        Dot = true,
        Color = Color3_fromRGB(216, 126, 157),

        Lines = {
            Enabled = true,
            Rotate = {true, 5},
            Amount = 4,
            Length = 15,
            Thickness = 2,
            Gap = 12,
        },

        Watermark = {
            Enabled = true,
            Color = Color3_fromRGB(255, 255, 255),
            Text = `swag<font color="rgb(216, 126, 157)">hub</font>`,
        },

        Follow = function()
            local MousePosition = UserInputService:GetMouseLocation()
            return MousePosition
        end
    },

    FoVs = {
        SilentAim = {
            Enabled = true,
            Size = 150,
            Thickness = 2,
            Color = Color3_fromRGB(216, 126, 157),
            ZIndex = 1,

            Fill = {
                Enabled = true,
                Color = Color3_fromRGB(216, 126, 157),
                Transparency = 0.65,
            },

            Follow = function()
                local MousePosition = UserInputService:GetMouseLocation()
                return MousePosition
            end
        },
    },
}

-- Internal tables
Visuals.Connections = {}
Visuals.Errors = {}
Visuals.Objects = {}
Visuals.FoVsObjects = {}
Visuals.Folder = "Visuals"
Visuals.Crosshair = nil
Visuals.Font = nil
Visuals.Holder = nil

-- Utility functions
local Utility = {}

function Utility.AddConnection(Signal, Function)
    local Connection = Signal:Connect(function(...)
        local Args = {...}
        local Success, Message = pcall(function() coroutine.wrap(Function)(table_unpack(Args)) end)
        if not Success and not Visuals.Errors[Message] then
            Visuals.Errors[Message] = Message
            if Visuals.Connections[Connection] then
                Visuals.Connections[Connection] = nil
            end
            Connection:Disconnect()
        end
    end)
    if Connection then table_insert(Visuals.Connections, Connection) end
    return Connection
end

function Utility.CreateObject(Type, Properties)
    local Object = Instance.new(Type)
    for Index, Value in pairs(Properties) do
        Object[Index] = Value
    end
    table_insert(Visuals.Objects, Object)
    return Object
end

function Utility.CalculateCrosshair(Lines, Center, TimeAngle, Length, Thickness, Gap)
    local Results = {}
    local Step = (math_pi * 2) / Lines
    local Radius = Gap + Length / 2
    for i = 1, Lines do
        local BaseAngle = Step * (i - 1)
        local Angle = BaseAngle + TimeAngle
        local OffsetX = math_cos(Angle) * Radius
        local OffsetY = math_sin(Angle) * Radius
        Results[i] = {
            Size = UDim2_new(0, Length, 0, Thickness),
            Position = Center + UDim2_new(0, OffsetX, 0, OffsetY),
            Rotation = math_deg(Angle)
        }
    end
    return Results
end

-- Crosshair
function Visuals.CreateCrosshair()
    local CrosshairObject = {
        Connection = nil,
        SpinAngle = 0,
        Objects = {},
        LastTick = os_clock(),
        LastSpinTime = os_clock(),
    }

    local Settings = Visuals.Settings.Crosshair
    local LineSettings = Settings.Lines
    local WatermarkSettings = Settings.Watermark
    local Objects = CrosshairObject.Objects
    local LastTick = CrosshairObject.LastTick
    local Holder = Visuals.Holder
    local LinesAmount = LineSettings.Amount
    local FollowFunction = Settings.Follow

    function CrosshairObject.Init()
        Objects["CrosshairDot"] = Utility.CreateObject("Frame", {
            Parent = Holder,
            ZIndex = 1000,
            AnchorPoint = Vector2_new(0.5, 0.5),
            Visible = false,
            BackgroundTransparency = 0,
            Position = UDim2_new(0,0,0,0),
            Size = UDim2_new(0,2,0,2),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3_fromRGB(255,255,255)
        })

        Objects["CrosshairWatermark"] = Utility.CreateObject("TextLabel", {
            Parent = Holder,
            Font = Enum.Font.SourceSans,
            TextSize = Visuals.Settings.FontSize,
            TextColor3 = Color3_fromRGB(255,255,255),
            RichText = true,
            Text = WatermarkSettings.Text,
            AnchorPoint = Vector2_new(0.5,0.5),
            Visible = false,
            BackgroundTransparency = 1,
            ZIndex = 1001,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2_new(1,0,0,0)
        })

        for i = 1, LinesAmount do
            Objects["Line_"..i] = Utility.CreateObject("Frame", {
                Parent = Holder,
                ZIndex = 1000,
                AnchorPoint = Vector2_new(0.5,0.5),
                Visible = false,
                BackgroundTransparency = 0,
                Position = UDim2_new(0,0,0,0),
                Size = UDim2_new(0,2,0,2),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3_fromRGB(255,255,255)
            })
        end
    end

    function CrosshairObject.Update(Delta)
        if (os_clock() - LastTick) < (1/Visuals.Settings.RefreshRate) then return end
        LastTick = os_clock()

        local Pos = FollowFunction()
        local Center = UDim2_new(0, Pos.X, 0, Pos.Y)
        local Data = Utility.CalculateCrosshair(LinesAmount, Center, CrosshairObject.SpinAngle, LineSettings.Length, LineSettings.Thickness, LineSettings.Gap)

        -- Dot
        Objects["CrosshairDot"].Visible = Settings.Enabled and Settings.Dot
        Objects["CrosshairDot"].BackgroundColor3 = Settings.Color
        Objects["CrosshairDot"].Position = Center

        -- Watermark
        Objects["CrosshairWatermark"].Visible = Settings.Enabled and WatermarkSettings.Enabled
        Objects["CrosshairWatermark"].Text = WatermarkSettings.Text
        Objects["CrosshairWatermark"].Position = Center + UDim2_new(0,0,0,LineSettings.Gap + LineSettings.Length + 14)

        -- Lines
        for i, Info in pairs(Data) do
            local Line = Objects["Line_"..i]
            if Settings.Enabled and LineSettings.Enabled then
                if LineSettings.Rotate[1] then
                    local Now = os_clock()
                    CrosshairObject.SpinAngle += (Now - CrosshairObject.LastSpinTime) * LineSettings.Rotate[2]
                    CrosshairObject.LastSpinTime = Now
                end
                Line.Visible = true
                Line.BackgroundColor3 = Settings.Color
                Line.Size = Info.Size
                Line.Position = Info.Position
                Line.Rotation = Info.Rotation
            else
                Line.Visible = false
            end
        end
    end

    function CrosshairObject.Remove()
        for _, Obj in pairs(Objects) do
            Obj:Destroy()
        end
        Visuals.Crosshair = nil
    end

    CrosshairObject.Init()
    Visuals.Crosshair = CrosshairObject
end

-- FoVs
function Visuals.RegisterFoV(Name, Settings)
    if Visuals.FoVsObjects[Name] then return end

    local FoVObject = {
        Objects = {},
        LastTick = os_clock(),
        Settings = Settings
    }

    function FoVObject.Init()
        local Holder = Visuals.Holder
        FoVObject.Objects["FoVMain"] = Utility.CreateObject("Frame", {Parent=Holder, ZIndex=Settings.ZIndex, Visible=false, BackgroundTransparency=1})
        FoVObject.Objects["FoVOutline"] = Utility.CreateObject("Frame", {Parent=Holder, ZIndex=Settings.ZIndex, Visible=false, BackgroundTransparency=1})
        FoVObject.Objects["FoVFill"] = Utility.CreateObject("Frame", {Parent=Holder, ZIndex=Settings.ZIndex, Visible=false, BackgroundTransparency=1})
    end

    function FoVObject.Update()
        if (os_clock() - FoVObject.LastTick) < (1/Visuals.Settings.RefreshRate) then return end
        FoVObject.LastTick = os_clock()

        local Pos = Settings.Follow()
        local Main = FoVObject.Objects["FoVMain"]
        local Outline = FoVObject.Objects["FoVOutline"]
        local Fill = FoVObject.Objects["FoVFill"]

        if Settings.Enabled then
            Main.Visible = true
            Main.Position = UDim2_new(0, Pos.X, 0, Pos.Y)
            Main.Size = UDim2_new(0, Settings.Size, 0, Settings.Size)
            Main.BackgroundColor3 = Settings.Color

            Outline.Visible = true
            Outline.Position = UDim2_new(0, Pos.X, 0, Pos.Y)
            Outline.Size = UDim2_new(0, Settings.Size-2,0,Settings.Size-2)
            Outline.BackgroundColor3 = Settings.Color

            if Settings.Fill.Enabled then
                Fill.Visible = true
                Fill.Position = UDim2_new(0, Pos.X, 0, Pos.Y)
                Fill.Size = UDim2_new(0, Settings.Size, 0, Settings.Size)
                Fill.BackgroundColor3 = Settings.Fill.Color
                Fill.BackgroundTransparency = Settings.Fill.Transparency
            else
                Fill.Visible = false
            end
        else
            Main.Visible = false
            Outline.Visible = false
            Fill.Visible = false
        end
    end

    function FoVObject.Remove()
        for _, Obj in pairs(FoVObject.Objects) do Obj:Destroy() end
        Visuals.FoVsObjects[Name] = nil
    end

    FoVObject.Init()
    Visuals.FoVsObjects[Name] = FoVObject
end

-- Initialize GUI and all connections
function Visuals.Init()
    Visuals.Holder = Instance.new("ScreenGui")
    Visuals.Holder.Name = "VisualsHolder"
    Visuals.Holder.ResetOnSpawn = false
    Visuals.Holder.Parent = game:GetService("CoreGui")

    Visuals.CreateCrosshair()

    -- Original-style connection using LPH_NO_VIRTUALIZE and PostSimulation
    Utility.AddConnection(RunService.PostSimulation, LPH_NO_VIRTUALIZE(function(Delta)
        if Visuals.Crosshair then
            Visuals.Crosshair.Update(Delta)
        end
        for _, FoV in pairs(Visuals.FoVsObjects) do
            FoV.Update()
        end
    end))
end

-- Unload function
function Visuals.Unload()
    for _, Conn in pairs(Visuals.Connections) do
        Conn:Disconnect()
    end
    for _, Obj in pairs(Visuals.Objects) do
        Obj:Destroy()
    end
    Visuals.Crosshair = nil
    Visuals.FoVsObjects = {}
    if Visuals.Holder then
        Visuals.Holder:Destroy()
        Visuals.Holder = nil
    end
end

-- Initialize everything
Visuals.Init()

-- Return table for external modifications
return Visuals
