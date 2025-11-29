-- Super ESP Library (ScreenGui-based)
-- Features: Box, Corner, Tracer, Healthbar, Model/Part ESP
-- Optimized for large counts: pooling, culling, throttled updates, distance checks
-- Usage:
-- local ESP = require(path_to_this_module)
-- ESP:Enable()
-- ESP:Add(targetInstance, {Box = true, Corner = true, Tracer = true, Healthbar = true, Color = Color3.new(1,0,0)})
-- ESP:Remove(targetInstance)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.__index = ESP

-- Config (tune for performance)
local DEFAULTS = {
    Enabled = true,
    MaxDistance = 1000,         -- studs
    UpdateRate = 1/30,         -- seconds (30 fps update for positions)
    CullOutOfView = true,
    TeamCheck = false,         -- ignore same-team
    ScaleWithDistance = true,
    MinSize = 10,              -- px
    MaxSize = 400,             -- px
}

-- GUI templates (created once and pooled)
local templates = {}

local function createScreenGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "SuperESPScreenGui"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    return sg
end

local function makeTemplate(screenGui)
    -- container
    local container = Instance.new("Frame")
    container.Name = "ESP_Container"
    container.Size = UDim2.new(0,0,0,0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Parent = screenGui

    -- Box
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.AnchorPoint = Vector2.new(0.5,0.5)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Size = UDim2.new(0,100,0,100)
    box.Parent = container

    local boxOutline = Instance.new("Frame")
    boxOutline.Name = "BoxOutline"
    boxOutline.Size = UDim2.new(1,2,1,2)
    boxOutline.Position = UDim2.new(0,-1,0,-1)
    boxOutline.BackgroundTransparency = 1
    boxOutline.BorderSizePixel = 0
    boxOutline.Parent = box

    local boxBorder = Instance.new("UICorner")
    boxBorder.Parent = box

    -- Corner (4 lines)
    local corners = Instance.new("Folder")
    corners.Name = "Corners"
    corners.Parent = container
    for i=1,4 do
        local line = Instance.new("Frame")
        line.Name = "CornerLine"..i
        line.Size = UDim2.new(0,20,0,3)
        line.AnchorPoint = Vector2.new(0.5,0.5)
        line.BackgroundTransparency = 0
        line.BorderSizePixel = 0
        line.Parent = corners
    end

    -- Tracer (thin rotated frame)
    local tracer = Instance.new("Frame")
    tracer.Name = "Tracer"
    tracer.AnchorPoint = Vector2.new(0.5,0)
    tracer.Size = UDim2.new(0,2,0,100)
    tracer.BorderSizePixel = 0
    tracer.BackgroundTransparency = 0
    tracer.Parent = container

    -- Healthbar (vertical)
    local health = Instance.new("Frame")
    health.Name = "HealthBar"
    health.AnchorPoint = Vector2.new(0,0.5)
    health.Size = UDim2.new(0,6,0,60)
    health.BorderSizePixel = 0
    health.BackgroundTransparency = 1
    health.Parent = container

    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.AnchorPoint = Vector2.new(0.5,1)
    healthFill.Position = UDim2.new(0.5,0,1,0)
    healthFill.Size = UDim2.new(1,0,1,0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = health

    -- Label (name / distance)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0,200,0,18)
    label.AnchorPoint = Vector2.new(0.5,0)
    label.BackgroundTransparency = 1
    label.Text = ""
    label.TextScaled = false
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 14
    label.Parent = container

    -- Style helper
    local function setColorGui(c)
        -- box
        box.BackgroundColor3 = Color3.new(0,0,0)
        boxOutline.BackgroundColor3 = c
        for _,line in ipairs(corners:GetChildren()) do
            line.BackgroundColor3 = c
        end
        tracer.BackgroundColor3 = c
        healthFill.BackgroundColor3 = c
        label.TextColor3 = c
    end

    templates.container = container
    templates.box = box
    templates.boxOutline = boxOutline
    templates.corners = corners
    templates.tracer = tracer
    templates.health = health
    templates.healthFill = healthFill
    templates.label = label
    templates.setColorGui = setColorGui
end

-- Utility: clone a GUI instance from template (shallow clone)
local function cloneGui(screenGui)
    local root = templates.container:Clone()
    root.Parent = screenGui
    local box = root:FindFirstChild("Box")
    local corners = root:FindFirstChild("Corners")
    local tracer = root:FindFirstChild("Tracer")
    local health = root:FindFirstChild("HealthBar")
    local label = root:FindFirstChild("Label")
    return {
        root = root,
        box = box,
        corners = corners,
        tracer = tracer,
        health = health,
        healthFill = health:FindFirstChild("HealthFill"),
        label = label
    }
end

-- Compute 2D bounding box for a model/part in screen space
local function getScreenBoundsFromParts(parts)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local onScreen = false
    for _,p in ipairs(parts) do
        if p and p:IsA("BasePart") and p.Parent then
            local size = p.Size
            local cf = p.CFrame
            -- Check 8 corners
            local extents = {
                Vector3.new( size.X/2,  size.Y/2,  size.Z/2),
                Vector3.new(-size.X/2,  size.Y/2,  size.Z/2),
                Vector3.new( size.X/2, -size.Y/2,  size.Z/2),
                Vector3.new(-size.X/2, -size.Y/2,  size.Z/2),
                Vector3.new( size.X/2,  size.Y/2, -size.Z/2),
                Vector3.new(-size.X/2,  size.Y/2, -size.Z/2),
                Vector3.new( size.X/2, -size.Y/2, -size.Z/2),
                Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
            }
            for _,offset in ipairs(extents) do
                local worldPos = (cf * CFrame.new(offset)).p
                local pos, on = Camera:WorldToViewportPoint(worldPos)
                if on then onScreen = true end
                minX = math.min(minX, pos.X)
                minY = math.min(minY, pos.Y)
                maxX = math.max(maxX, pos.X)
                maxY = math.max(maxY, pos.Y)
            end
        end
    end
    if minX==math.huge then
        return nil
    end
    return Vector2.new(minX, minY), Vector2.new(maxX, maxY), onScreen
end

-- Pool and tracked
local function new(self)
    local obj = setmetatable({}, ESP)
    obj.screenGui = createScreenGui()
    templates.screenGui = obj.screenGui
    if not templates.container then
        makeTemplate(obj.screenGui)
        templates.container.Parent = obj.screenGui
    end
    obj.pool = {}          -- recycled GUIs
    obj.tracked = {}       -- map instance -> data
    obj._acc = 0
    obj._lastUpdate = 0
    obj.Config = {}
    for k,v in pairs(DEFAULTS) do obj.Config[k]=v end
    obj._connected = false
    return obj
end

-- Create or reuse GUI
local function acquireGui(self)
    if #self.pool > 0 then
        local g = table.remove(self.pool)
        g.root.Visible = true
        return g
    else
        return cloneGui(self.screenGui)
    end
end

local function releaseGui(self, g)
    if not g then return end
    g.root.Visible = false
    g.root.Parent = self.screenGui
    table.insert(self.pool, g)
end

-- Add a target to ESP
function ESP:Add(target, opts)
    if not target or not target.Parent then return end
    if self.tracked[target] then return self.tracked[target] end
    opts = opts or {}
    local data = {
        target = target,
        opts = {
            Box = opts.Box ~= false,
            Corner = opts.Corner == true,
            Tracer = opts.Tracer == true,
            Healthbar = opts.Healthbar == true,
            Color = opts.Color or Color3.new(1,1,1),
            Label = opts.Label ~= false,
            DepthScale = opts.DepthScale or 1,
            Custom = opts.Custom, -- optional function(parts) -> {minV, maxV}
        },
        gui = acquireGui(self),
        alive = true,
    }

    -- style
    templates.setColorGui(data.opts.Color)

    self.tracked[target] = data
    return data
end

function ESP:Remove(target)
    local d = self.tracked[target]
    if not d then return end
    d.alive = false
    releaseGui(self, d.gui)
    self.tracked[target] = nil
end

function ESP:Clear()
    for t,_ in pairs(self.tracked) do
        self:Remove(t)
    end
end

function ESP:SetEnabled(v)
    self.Config.Enabled = v and true or false
    if not self.Config.Enabled then
        for t,d in pairs(self.tracked) do
            if d.gui then d.gui.root.Visible = false end
        end
    end
end

function ESP:Destroy()
    self:Clear()
    if self.screenGui then self.screenGui:Destroy() end
    self._connected = false
end

-- Internal: compute parts for target (model or part)
local function getRelevantParts(target)
    if not target or not target.Parent then return {} end
    if target:IsA("BasePart") then
        return {target}
    elseif target:IsA("Model") then
        local parts = {}
        -- prefer GetDescendants filter for BasePart, avoid heavy calls many times
        for _,v in ipairs(target:GetDescendants()) do
            if v:IsA("BasePart") then
                table.insert(parts, v)
            end
        end
        return parts
    else
        return {}
    end
end

-- update visuals
local function updateOne(self, data)
    local target = data.target
    if not target or not target.Parent then
        self:Remove(target)
        return
    end
    if not self.Config.Enabled then
        data.gui.root.Visible = false
        return
    end

    local parts = getRelevantParts(target)
    if #parts==0 then
        data.gui.root.Visible = false
        return
    end

    -- quick culling by distance to camera using first part
    local origin = parts[1].Position
    local dist = (Camera.CFrame.Position - origin).Magnitude
    if self.Config.MaxDistance and dist > self.Config.MaxDistance then
        data.gui.root.Visible = false
        return
    end

    local minV, maxV, onScreen = getScreenBoundsFromParts(parts)
    if not minV or not maxV then
        data.gui.root.Visible = false
        return
    end
    if self.Config.CullOutOfView and not onScreen then
        data.gui.root.Visible = false
        return
    end

    -- compute center and size
    local size = maxV - minV
    local center = (minV + maxV) * 0.5

    local gui = data.gui
    gui.root.Visible = true

    -- Box
    if data.opts.Box then
        gui.box.Position = UDim2.new(0, center.X, 0, center.Y)
        gui.box.Size = UDim2.new(0, math.clamp(size.X, DEFAULTS.MinSize, DEFAULTS.MaxSize), 0, math.clamp(size.Y, DEFAULTS.MinSize, DEFAULTS.MaxSize))
        gui.box.BackgroundTransparency = 1
        gui.boxOutline.BackgroundTransparency = 0
    else
        gui.boxOutline.BackgroundTransparency = 1
    end

    -- Corners
    gui.corners.Visible = data.opts.Corner and true or false
    if data.opts.Corner then
        local cornerSizeX = math.min(size.X*0.25, 30)
        local cornerSizeY = math.min(size.Y*0.25, 30)
        -- TL
        local TL = gui.corners:FindFirstChild("CornerLine1")
        TL.Position = UDim2.new(0, minV.X, 0, minV.Y)
        TL.Size = UDim2.new(0, cornerSizeX, 0, 2)
        -- TR
        local TR = gui.corners:FindFirstChild("CornerLine2")
        TR.Position = UDim2.new(0, maxV.X, 0, minV.Y)
        TR.Size = UDim2.new(0, cornerSizeX, 0, 2)
        TR.Rotation = 0
        -- BL
        local BL = gui.corners:FindFirstChild("CornerLine3")
        BL.Position = UDim2.new(0, minV.X, 0, maxV.Y)
        BL.Size = UDim2.new(0, cornerSizeX, 0, 2)
        -- BR
        local BR = gui.corners:FindFirstChild("CornerLine4")
        BR.Position = UDim2.new(0, maxV.X, 0, maxV.Y)
        BR.Size = UDim2.new(0, cornerSizeX, 0, 2)
    end

    -- Tracer: draw line from bottom center to center
    gui.tracer.Visible = data.opts.Tracer and true or false
    if data.opts.Tracer then
        local screenBottom = Vector2.new(Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y)
        local dx = center.X - screenBottom.X
        local dy = center.Y - screenBottom.Y
        local length = math.sqrt(dx*dx + dy*dy)
        gui.tracer.Position = UDim2.new(0, screenBottom.X, 0, screenBottom.Y)
        gui.tracer.Size = UDim2.new(0, 2, 0, length)
        gui.tracer.AnchorPoint = Vector2.new(0.5, 0)
        local angle = math.deg(math.atan2(dy, dx)) + 90
        gui.tracer.Rotation = angle
    end

    -- Healthbar
    gui.health.Visible = data.opts.Healthbar and true or false
    if data.opts.Healthbar then
        -- try to find humanoid
        local humanoid
        for _,p in ipairs(parts) do
            humanoid = humanoid or p.Parent:FindFirstChildWhichIsA("Humanoid")
            if humanoid then break end
        end
        if humanoid then
            local h = math.clamp(humanoid.Health/humanoid.MaxHealth, 0, 1)
            gui.health.Position = UDim2.new(0, minV.X - 8, 0, center.Y - (size.Y/2))
            gui.health.Size = UDim2.new(0, 6, 0, size.Y)
            gui.healthFill.Size = UDim2.new(1,0,h,0)
        else
            gui.health.Visible = false
        end
    end

    -- Label
    if data.opts.Label then
        local name = target.Name
        local distance = math.floor(dist)
        gui.label.Text = name .. " (" .. tostring(distance) .. "s)"
        gui.label.Position = UDim2.new(0, center.X, 0, maxV.Y + 4)
        gui.label.Visible = true
    else
        gui.label.Visible = false
    end
end

-- Main loop
function ESP:Enable()
    if self._connected then return end
    self._connected = true
    local acc = 0
    local rate = self.Config.UpdateRate
    self._conn = RunService.RenderStepped:Connect(function(dt)
        if not self._connected then return end
        acc = acc + dt
        -- update at throttle
        if acc < rate then return end
        acc = 0
        -- iterate tracked
        for target,data in pairs(self.tracked) do
            -- protect from invalid
            local ok,err = pcall(updateOne, self, data)
            if not ok then
                -- on error remove to avoid spam
                warn("ESP update error:", err)
                self:Remove(target)
            end
        end
    end)
end

function ESP:Disable()
    if not self._connected then return end
    if self._conn then self._conn:Disconnect() end
    self._connected = false
    for t,d in pairs(self.tracked) do
        if d.gui then d.gui.root.Visible = false end
    end
end

-- Constructor
return setmetatable({new = new}, {__call = function(_,...) return new(...) end})
