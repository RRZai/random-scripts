local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1393633656353980416/81K2p3e5RqPaQkTsgs7ICKOChe0caS2ouMYiZOMRjWs7xminzfMl7NZySoEyGfIiJ8Ao"
local ROLE_ID = "1393627032474222734"
local MAX_PLAYERS = 6
local CHECK_INTERVAL = 3600

-- Discord webhook sender
local function sendToDiscord(content, isLeave)
    local currentPlayers = #Players:GetPlayers()
    local data = {
        content = isLeave and currentPlayers < MAX_PLAYERS and content.." <@&"..ROLE_ID..">" or nil,
        embeds = {{
            title = isLeave and "🚪 Player Left" or "🎉 Player Joined",
            description = content,
            fields = {
                {name = "Slots", value = string.format("%d/%d", currentPlayers, MAX_PLAYERS), inline = true},
                {name = "Server ID", value = game.JobId, inline = true}
            },
            color = isLeave and 0xff3333 or 0x33ff33,
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    pcall(HttpService.PostAsync, HttpService, WEBHOOK_URL, HttpService:JSONEncode(data))
end

-- Initialization
sendToDiscord("Server monitoring started | Slots: "..#Players:GetPlayers().."/"..MAX_PLAYERS, false)

-- Player event handlers
Players.PlayerAdded:Connect(function()
    sendToDiscord("A player has joined", false)
end)

Players.PlayerRemoving:Connect(function()
    sendToDiscord("A player has left", true)
end)

-- Periodic check
while task.wait(CHECK_INTERVAL) do
    if #Players:GetPlayers() < MAX_PLAYERS then
        sendToDiscord("Current slots: "..#Players:GetPlayers().."/"..MAX_PLAYERS, false)
    end
end
