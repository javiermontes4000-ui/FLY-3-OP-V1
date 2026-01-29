--[[
AbilitiesMenu.lua
Script de habilidades para Roblox
Incluye: vuelo, velocidad, salto
Compatible con PC y móvil
Menú en pantalla para ajustar valores
Colócalo como LocalScript en StarterPlayer -> StarterPlayerScripts
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variables del personaje
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configuración inicial
local walkSpeed = 16
local jumpPower = 50
local flySpeed = 50
local flying = false
local flyDirection = Vector3.new(0,0,0)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AbilitiesMenu"
ScreenGui.Parent = playerGui

-- Fondo del menú
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 300, 0, 250)
MenuFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.Parent = ScreenGui
MenuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MenuFrame.BackgroundTransparency = 0.1
MenuFrame.ClipsDescendants = true

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Menú de Habilidades"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MenuFrame

-- Cerrar botón
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0,30,0,30)
CloseButton.Position = UDim2.new(1,-35,0,5)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
CloseButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = MenuFrame

CloseButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = false
end)

-- Función para crear sliders con input box
local function createSlider(labelText, min, max, default, callback, yOffset)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,-20,0,40)
    Frame.Position = UDim2.new(0,10,0,yOffset)
    Frame.BackgroundTransparency = 1
    Frame.Parent = MenuFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4,0,1,0)
    Label.Position = UDim2.new(0,0,0,0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Slider = Instance.new("TextBox")
    Slider.Size = UDim2.new(0.55,0,0.6,0)
    Slider.Position = UDim2.new(0.45,0,0.2,0)
    Slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Slider.TextColor3 = Color3.fromRGB(255,255,255)
    Slider.Text = tostring(default)
    Slider.Font = Enum.Font.Gotham
    Slider.TextSize = 16
    Slider.ClearTextOnFocus = false
    Slider.Parent = Frame

    Slider.FocusLost:Connect(function()
        local val = tonumber(Slider.Text)
        if val then
            if val < min then val = min end
            if val > max then val = max end
            Slider.Text = tostring(val)
            callback(val)
        else
            Slider.Text = tostring(default)
        end
    end)
end

-- Crear sliders para velocidad, salto y vuelo
createSlider("Velocidad:", 16, 200, walkSpeed, function(val)
    walkSpeed = val
    humanoid.WalkSpeed = walkSpeed
end, 50)

createSlider("Salto:", 50, 300, jumpPower, function(val)
    jumpPower = val
    humanoid.JumpPower = jumpPower
end, 100)

createSlider("Velocidad de Vuelo:", 10, 200, flySpeed, function(val)
    flySpeed = val
end, 150)

-- Botón para abrir menú
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0,150,0,40)
openButton.Position = UDim2.new(0,10,0,10)
openButton.BackgroundColor3 = Color3.fromRGB(30,144,255)
openButton.TextColor3 = Color3.fromRGB(255,255,255)
openButton.Text = "Abrir Menú"
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 18
openButton.Parent = ScreenGui

openButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = not MenuFrame.Visible
end)

-- Vuelo
local bodyVelocity
local inputStates = {W=false,A=false,S=false,D=false,Space=false,Shift=false}

local function startFlying()
    if flying then return end
    flying = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000,400000,400000)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = rootPart
end

local function stopFlying()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    flying = false
end

-- Detectar inputs
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.W then inputStates.W = true end
        if input.KeyCode == Enum.KeyCode.A then inputStates.A = true end
        if input.KeyCode == Enum.KeyCode.S then inputStates.S = true end
        if input.KeyCode == Enum.KeyCode.D then inputStates.D = true end
        if input.KeyCode == Enum.KeyCode.Space then inputStates.Space = true end
        if input.KeyCode == Enum.KeyCode.LeftShift then inputStates.Shift = true end
        if input.KeyCode == Enum.KeyCode.F then
            if flying then stopFlying() else startFlying() end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.W then inputStates.W = false end
        if input.KeyCode == Enum.KeyCode.A then inputStates.A = false end
        if input.KeyCode == Enum.KeyCode.S then inputStates.S = false end
        if input.KeyCode == Enum.KeyCode.D then inputStates.D = false end
        if input.KeyCode == Enum.KeyCode.Space then inputStates.Space = false end
        if input.KeyCode == Enum.KeyCode.LeftShift then inputStates.Shift = false end
    end
end)

-- Movimiento de vuelo
RunService.RenderStepped:Connect(function()
    if flying and bodyVelocity then
        local dir = Vector3.new(0,0,0)
        if inputStates.W then dir = dir + workspace.CurrentCamera.CFrame.LookVector end
        if inputStates.S then dir = dir - workspace.CurrentCamera.CFrame.LookVector end
        if inputStates.A then dir = dir - workspace.CurrentCamera.CFrame.RightVector end
        if inputStates.D then dir = dir + workspace.CurrentCamera.CFrame.RightVector end
        if inputStates.Space then dir = dir + Vector3.new(0,1,0) end
        if inputStates.Shift then dir = dir - Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then
            bodyVelocity.Velocity = dir.Unit * flySpeed
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- Inicializar stats
humanoid.WalkSpeed = walkSpeed
humanoid.JumpPower = jumpPower
