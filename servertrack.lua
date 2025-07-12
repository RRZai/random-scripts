local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1393633656353980416/81K2p3e5RqPaQkTsgs7ICKOChe0caS2ouMYiZOMRjWs7xminzfMl7NZySoEyGfIiJ8Ao"
local ROLE_ID = "1393627032474222734"
local MAX_PLAYERS = 6
local CHECK_INTERVAL = 3600

local chatrem = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

local function getPlayerId(player)
    return string.format("#%04d", player.UserId % 10000)
end

local function welcomePlayer(player)
    if chatrem then
        chatrem:FireServer(string.format("/mAmQxNGCR6 for pings ong | welcome %s [slot %d/%d]", getPlayerId(player), #Players:GetPlayers(), MAX_PLAYERS), "All")
    end
end

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

sendToDiscord("Server active "..#Players:GetPlayers().."/"..MAX_PLAYERS, false)

Players.PlayerAdded:Connect(welcomePlayer)
Players.PlayerAdded:Connect(function(p)
    sendToDiscord(getPlayerId(p).." joined", false)
end)

Players.PlayerRemoving:Connect(function(p)
    sendToDiscord(getPlayerId(p).." left", true)
end)

while task.wait(CHECK_INTERVAL) do
    if #Players:GetPlayers() < MAX_PLAYERS then
        sendToDiscord("🕒 "..#Players:GetPlayers().."/"..MAX_PLAYERS, false)
    end
end
