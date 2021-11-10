local RunService = Game:GetService("RunService")
local PlayerService = Game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer

local ESPLibrary = {}
local PlayerTable = {}
local NPCTable = {}
local NPCFolder = Workspace.Custom:FindFirstChild("-1") or Workspace.Custom:FindFirstChild("1")

local function CalculateBox(Model)
	local CFrame, Size = Model:GetBoundingBox()
	local Camera = Workspace.CurrentCamera
    
	local CornerTable = {
		Camera:WorldToViewportPoint(Vector3.new(CFrame.X - Size.X / 2, CFrame.Y + Size.Y / 2, CFrame.Z)), -- TopLeft
		Camera:WorldToViewportPoint(Vector3.new(CFrame.X + Size.X / 2, CFrame.Y + Size.Y / 2, CFrame.Z)), -- TopRight
		Camera:WorldToViewportPoint(Vector3.new(CFrame.X - Size.X / 2, CFrame.Y - Size.Y / 2, CFrame.Z)), -- BottomLeft
		Camera:WorldToViewportPoint(Vector3.new(CFrame.X + Size.X / 2, CFrame.Y - Size.Y / 2, CFrame.Z)), -- BottomRight
	}

	local WorldPosition, OnScreen = Camera:WorldToViewportPoint(CFrame.Position)
	local Size = Vector2.new((CornerTable[1] - CornerTable[2]).Magnitude, (CornerTable[1] - CornerTable[3]).Magnitude)
	local Position = Vector2.new(WorldPosition.X - Size.X / 2, WorldPosition.Y - Size.Y / 2)
    
	return Position, Size, OnScreen
end

function ESPLibrary.AddPlayer(Player)
    if not PlayerTable[Player] then
        PlayerTable[Player] = {
            Box = {
                Outline = Drawing.new("Square"),
                Main = Drawing.new("Square"),
            },
            Healthbar = {
                Outline = Drawing.new("Square"),
                Main = Drawing.new("Square"),
            },
            Info = {
                Main = Drawing.new("Text"),
            }
        }
    end
end

function ESPLibrary.AddNPC(NPC)
    if not NPCTable[NPC] then
        NPCTable[NPC] = {
            Box = {
                Outline = Drawing.new("Square"),
                Main = Drawing.new("Square"),
            },
            Healthbar = {
                Outline = Drawing.new("Square"),
                Main = Drawing.new("Square"),
            },
            Info = {
                Main = Drawing.new("Text"),
            }
        }
    end
end

function ESPLibrary.RemovePlayer(Player)
    if PlayerTable[Player] then
        for Index, Table in pairs(PlayerTable[Player]) do
            for Index, Drawing in pairs(Table) do
                if Drawing.Remove then
                    Drawing:Remove()
                end
            end
        end
        PlayerTable[Player] = nil
    end
end

function ESPLibrary.RemoveNPC(NPC)
    if NPCTable[NPC] then
        for Index, Table in pairs(NPCTable[NPC]) do
            for Index, Drawing in pairs(Table) do
                if Drawing.Remove then
                    Drawing:Remove()
                end
            end
        end
        NPCTable[NPC] = nil
    end
end

local function IsCharacterAlive(Character)
    local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
    if Humanoid and Humanoid.Health > 0 then
        return true
    end
    return false
end

local function GetCharacterHealth(Character)
    local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
    if Humanoid then
        return {
            CurrentHealth = Humanoid.Health,
            MaxHealth = Humanoid.MaxHealth
        }
    end
    return false
end

local function GetHumanoidRoot(Character)
    local HumanoidRoot = (Character and Character:FindFirstChild("HumanoidRootPart"))
    if Character and HumanoidRoot then
        return HumanoidRoot
    end
    return false
end

local function GetTeamColor(Player)
    return Player.TeamColor.Color
end

local function IsOnClientTeam(Player)
    if LocalPlayer.Team == Player.Team then
        return true
    end

    return false
end

local function GetDistanceFromClient(Position)
    return LocalPlayer:DistanceFromCharacter(Position)
end
--[[
local function AimAt(Position, Smoothing)
    local MouseLocation = UserInputService:GetMouseLocation()
    mousemoverel(((Position.X - MouseLocation.X) / Smoothing), ((Position.Y - MouseLocation.Y) / Smoothing))
end

for Index, Player in pairs(PlayerService:GetPlayers()) do
    if Player == LocalPlayer then continue end
    AddPlayer(Player)
end
PlayerService.PlayerAdded:Connect(function(Player) AddPlayer(Player) end)
PlayerService.PlayerRemoving:Connect(function(Player) RemovePlayer(Player) end)
]]
RunService.RenderStepped:Connect(function()
    for Index, Player in pairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end
        local ESP = PlayerTable[Player]
        if not ESP then continue end
        local OnScreen, PassedTeamCheck = false, true

        local HumanoidRoot = GetHumanoidRoot(Player.Character)
        local PlayerHealth = GetCharacterHealth(Player.Character)
        local PlayerAlive = IsCharacterAlive(Player.Character)

        local PlayerTeam = IsOnClientTeam(Player)
        local PlayerColor = IsOnClientTeam(Player) and Config.AllyColor or Config.EnemyColor

        if Config.UseTeamColor then
            PlayerColor = GetTeamColor(Player)
        end
        if PlayerTeam then
            PassedTeamCheck = false
        end

        if PlayerAlive and PlayerHealth and HumanoidRoot and PlayerColor and PassedTeamCheck then
            local HealthPercent = (PlayerHealth.CurrentHealth / PlayerHealth.MaxHealth)
            local Distance = GetDistanceFromClient(HumanoidRoot.Position)
            Position, Size, OnScreen = CalculateBox(Player.Character)

            ESP.Box.Main.Transparency = 1
            ESP.Box.Main.Color = PlayerColor
            ESP.Box.Main.Thickness = 1
            ESP.Box.Main.Filled = false

            ESP.Box.Main.Size = Size
            ESP.Box.Main.Position = Position

            ESP.Box.Outline.Transparency = 1
            ESP.Box.Outline.Color = Color3.fromRGB(0,0,0)
            ESP.Box.Outline.Thickness = 3
            ESP.Box.Outline.Filled = false

            ESP.Box.Outline.Size = Size
            ESP.Box.Outline.Position = Position

            ESP.Healthbar.Main.Transparency = 1
            ESP.Healthbar.Main.Color = Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(0,255,0), HealthPercent)
            ESP.Healthbar.Main.Thickness = 1
            ESP.Healthbar.Main.Filled = true

            ESP.Healthbar.Main.Size = Vector2.new(2,0):Lerp(Vector2.new(2,-Size.Y + 2), HealthPercent)
            ESP.Healthbar.Main.Position = Vector2.new(Position.X - 6,Position.Y + Size.Y - 1)

            ESP.Healthbar.Outline.Transparency = 1
            ESP.Healthbar.Outline.Color = Color3.fromRGB(0,0,0)
            ESP.Healthbar.Outline.Thickness = 1
            ESP.Healthbar.Outline.Filled = true

            ESP.Healthbar.Outline.Size = Vector2.new(4,-Size.Y)
            ESP.Healthbar.Outline.Position = Vector2.new(Position.X - 7,Position.Y + Size.Y)

            ESP.Info.Main.Transparency = 1
            ESP.Info.Main.Color = Color3.fromRGB(255,255,255)
            ESP.Info.Main.Text = string.format("%s\n%d studs",Player.Name,Distance)
            ESP.Info.Main.Size = 16
            ESP.Info.Main.Center = true
            ESP.Info.Main.Outline = Config.OutlineVisible
            ESP.Info.Main.OutlineColor = Color3.fromRGB(0,0,0)
            ESP.Info.Main.Position = Vector2.new(Position.X + Size.X/2, Position.Y + Size.Y)
        end
        ESP.Box.Main.Visible = (OnScreen and Config.BoxVisible) or false
        ESP.Box.Outline.Visible = ESP.Box.Main.Visible

        ESP.Healthbar.Main.Visible = (OnScreen and Config.HealthbarVisible) or false
        ESP.Healthbar.Outline.Visible = ESP.Healthbar.Main.Visible

        ESP.Info.Main.Visible = (OnScreen and Config.InfoVisible) or false
    end
    if NPCFolder then
        for Index, NPC in pairs(NPCFolder:GetChildren()) do
            local ESP = NPCTable[NPC]
            if not ESP then continue end

            local OnScreen, PassedTeamCheck = false, true

            local HumanoidRoot = GetHumanoidRoot(NPC)
            local NPCHealth = GetCharacterHealth(NPC)
            local NPCAlive = IsCharacterAlive(NPC)

            if NPCAlive and NPCHealth and HumanoidRoot then
                local HealthPercent = (NPCHealth.CurrentHealth / NPCHealth.MaxHealth)
                local Distance = GetDistanceFromClient(HumanoidRoot.Position)
                Position, Size, OnScreen = CalculateBox(NPC)

                ESP.Box.Main.Transparency = 1
                ESP.Box.Main.Color = Config.EnemyColor
                ESP.Box.Main.Thickness = 1
                ESP.Box.Main.Filled = false

                ESP.Box.Main.Size = Size
                ESP.Box.Main.Position = Position

                ESP.Box.Outline.Transparency = 1
                ESP.Box.Outline.Color = Color3.fromRGB(0,0,0)
                ESP.Box.Outline.Thickness = 3
                ESP.Box.Outline.Filled = false

                ESP.Box.Outline.Size = Size
                ESP.Box.Outline.Position = Position

                ESP.Healthbar.Main.Transparency = 1
                ESP.Healthbar.Main.Color = Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(0,255,0), HealthPercent)
                ESP.Healthbar.Main.Thickness = 1
                ESP.Healthbar.Main.Filled = true

                ESP.Healthbar.Main.Size = Vector2.new(2,0):Lerp(Vector2.new(2,-Size.Y + 2), HealthPercent)
                ESP.Healthbar.Main.Position = Vector2.new(Position.X - 6,Position.Y + Size.Y - 1)

                ESP.Healthbar.Outline.Transparency = 1
                ESP.Healthbar.Outline.Color = Color3.fromRGB(0,0,0)
                ESP.Healthbar.Outline.Thickness = 1
                ESP.Healthbar.Outline.Filled = true

                ESP.Healthbar.Outline.Size = Vector2.new(4,-Size.Y)
                ESP.Healthbar.Outline.Position = Vector2.new(Position.X - 7,Position.Y + Size.Y)

                ESP.Info.Main.Transparency = 1
                ESP.Info.Main.Color = Color3.fromRGB(255,255,255)
                ESP.Info.Main.Text = string.format("%s\n%d studs",string.sub(NPC.Name,38),Distance)
                ESP.Info.Main.Size = 16
                ESP.Info.Main.Center = true
                ESP.Info.Main.Outline = Config.OutlineVisible
                ESP.Info.Main.OutlineColor = Color3.fromRGB(0,0,0)
                ESP.Info.Main.Position = Vector2.new(Position.X + Size.X/2, Position.Y + Size.Y)
            end
            ESP.Box.Main.Visible = (OnScreen and Config.BoxVisible) or false
            ESP.Box.Outline.Visible = ESP.Box.Main.Visible

            ESP.Healthbar.Main.Visible = (OnScreen and Config.HealthbarVisible) or false
            ESP.Healthbar.Outline.Visible = ESP.Healthbar.Main.Visible

            ESP.Info.Main.Visible = (OnScreen and Config.InfoVisible) or false
        end
    end
end)

return ESPLibrary
