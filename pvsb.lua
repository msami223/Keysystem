
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local WEBHOOK_URL = "here"

local EventManager = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EventManager")
local EventRegistry = require(ReplicatedStorage.Modules.Registries.EventRegistry)
local ActiveEvents = {}


local function sendWebhook(title, desc, color)
    spawn(function()
        local success, err = pcall(function()
            request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    embeds = {{
                        title = title,
                        description = desc,
                        color = color or 65280,
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                        footer = {
                            text = "Event Notifier | Delta Executor"
                        }
                    }}
                })
            })
        end)
        if not success then
            warn("[Webhook Error]", err)
        end
    end)
end

local function getEventInfo(eventName)
    local info = EventRegistry[eventName]
    if info then
        return info.DisplayName or eventName, info.Description or "No description available", info.Image
    else
        return eventName, "Unknown event.", nil
    end
end


EventManager.EventStarted.OnClientEvent:Connect(function(eventName, duration)
    ActiveEvents[eventName] = duration
    local title, desc = getEventInfo(eventName)
    sendWebhook("🎉 Event Started: " .. title, "**Duration:** " .. tostring(duration) .. "s\n\n" .. desc, 65280)
end)

EventManager.EventEnded.OnClientEvent:Connect(function(eventName)
    ActiveEvents[eventName] = nil
    local title, desc = getEventInfo(eventName)
    sendWebhook("🕓 Event Ended: " .. title, desc, 16711680)
end)

EventManager.SyncronizeEvents.OnClientEvent:Connect(function(events)
    for name, duration in pairs(events) do
        ActiveEvents[name] = duration
    end
    local list = {}
    for n, t in pairs(ActiveEvents) do
        table.insert(list, n .. " (" .. t .. "s)")
    end
    sendWebhook("🔁 Events Sync", (#list > 0 and table.concat(list, ", ") or "No active events"), 2552550)
end)
