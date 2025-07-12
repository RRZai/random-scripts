loadstring(game:HttpGet("https://raw.githubusercontent.com/Chris12089/atlasbss/main/script.lua"))()

wait(5)

loadstring(game:HttpGet("https://raw.githubusercontent.com/RRZai/random-scripts/refs/heads/main/servertrack.lua"))()

wait(1)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")


local MAX_ATTEMPTS = 3
local RETRY_DELAY = 15
local SERVER_LINK = "https://www.roblox.com/share?code=d60c17f7ceb2f14c8d79714dfda381c6&type=Server" 

local localPlayer = Players.LocalPlayer
local lastPlaceId = game.PlaceId
local lastJobId = game.JobId
local reconnectAttempts = 0


local function getAccessCode(link)
    if not link or link == "" then return nil end
    return link:match("privateServerLinkCode=([^&]+)") or link:match("([^/]+)$")
end


local function reconnect()
    if reconnectAttempts >= MAX_ATTEMPTS then
        warn("Max attempts reached")
        return
    end
    
    reconnectAttempts += 1
    warn("Attempting reconnect ("..reconnectAttempts.."/"..MAX_ATTEMPTS..")")
    

    if SERVER_LINK ~= "" then
        local success = pcall(function()
            TeleportService:Teleport(game.PlaceId, nil, SERVER_LINK)
        end)
        if success then return end
    end
    
    pcall(function()
        if string.find(lastJobId, "PrivateServer") then
            local accessCode = getAccessCode(SERVER_LINK) or lastJobId:split("|")[2]
            TeleportService:TeleportToPrivateServer(lastPlaceId, accessCode, {localPlayer})
        else
            TeleportService:Teleport(lastPlaceId)
        end
    end)
    
    task.wait(RETRY_DELAY)
    if not game:IsLoaded() then reconnect() end
end


localPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then reconnect() end
end)

RunService.Heartbeat:Connect(function()
    if not game:IsLoaded() and localPlayer then reconnect() end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 50)
statusLabel.Position = UDim2.new(0.5, -100, 0, 10)
statusLabel.BackgroundTransparency = 0.7
statusLabel.Text = "Auto-Rejoin: ACTIVE"
statusLabel.TextColor3 = Color3.new(0, 1, 0)
statusLabel.Parent = screenGui

warn("Delta Auto-Rejoin loaded | Server:", lastJobId)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToyEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ToyEvent")


local dispensers = {
    ["Free Ant Pass Dispenser"] = 2 * 60 * 60,      
    ["Honey Dispenser"] = 1 * 60 * 60,             
    ["Blueberry Dispenser"] = 4 * 60 * 60,           
    ["Blue Field Booster"] = 45 * 60,            
    ["Red Field Booster"] = 45 * 60,
    ["Strawberry Dispenser"] = 4 * 60 * 60,
    ["Field Booster"] = 45 * 60,
    ["Treat Dispenser"] = 1 * 60 * 60,
    ["Wealth Clock"] = 1 * 60 * 60,
    ["Coconut Dispenser"] = 4 * 60 * 60,
    ["Glue Dispenser"] = 22 * 60 * 60
}

for name, cooldown in pairs(dispensers) do
    task.spawn(function()
        while true do
            local args = {
                [1] = name
            }

            ToyEvent:FireServer(unpack(args))
            print("Used:", name)

            task.wait(cooldown)
        end
    end)
end
