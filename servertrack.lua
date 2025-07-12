local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1393633656353980416/81K2p3e5RqPaQkTsgs7ICKOChe0caS2ouMYiZOMRjWs7xminzfMl7NZySoEyGfIiJ8Ao"
local ROLE_ID = "1393627032474222734"
local MAX_PLAYERS = 6
local CHECK_INTERVAL = 3600

-- Player ID tracking
local playerIds = {}
local usedIds = {}

-- Generate random 4-digit alphanumeric ID
local function generateRandomId()
    local chars = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ"
    local id
    repeat
        id = ""
        for i = 1, 4 do
            local rand = math.random(1, #chars)
            id = id .. string.sub(chars, rand, rand)
        end
    until not usedIds[id]
    usedIds[id] = true
    return id
end

-- Get or create player ID
local function getPlayerId(player)
    if not playerIds[player] then
        playerIds[player] = "#"..generateRandomId()
    end
    return playerIds[player]
end

-- Chat system
local chatrem = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
               ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

local function welcomePlayer(player)
    if chatrem then
        chatrem:FireServer(
            string.format("/mAmQxNGCR6 for pings ong | welcome %s [slot %d/%d]", 
            getPlayerId(player), #Players:GetPlayers(), MAX_PLAYERS), 
            "All"
        )
    end
end

-- Discord webhook
local function sendToDiscord(content, isLeave)
    local data = {
        content = isLeave and #Players:GetPlayers() < MAX_PLAYERS and content.." <@&"..ROLE_ID..">" or nil,
        embeds = {{
            title = isLeave and "🚪" or "🎉",
            description = content,
            fields = {
                {name = "Slots", value = string.format("%d/%d", #Players:GetPlayers(), MAX_PLAYERS), inline = true},
                {name = "Server", value = game.JobId, inline = true}
            },
            color = isLeave and 0xff3333 or 0x33ff33,
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    pcall(HttpService.PostAsync, HttpService, WEBHOOK_URL, HttpService:JSONEncode(data))
end

-- Initialize
sendToDiscord("Server active "..#Players:GetPlayers().."/"..MAX_PLAYERS, false)

-- Player handlers
Players.PlayerAdded:Connect(function(player)
    welcomePlayer(player)
    sendToDiscord(getPlayerId(player).." joined", false)
end)

Players.PlayerRemoving:Connect(function(player)
    sendToDiscord(getPlayerId(player).." left", true)
    playerIds[player] = nil
end)

-- Periodic check
while task.wait(CHECK_INTERVAL) do
    if #Players:GetPlayers() < MAX_PLAYERS then
        sendToDiscord("🕒 "..#Players:GetPlayers().."/"..MAX_PLAYERS, false)
    end
end
