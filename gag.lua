--// UI Library
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()

local Window = Library:CreateWindow{
    Title = "gag",
    SubTitle = "V-0.1.1",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
}

local Tabs = {
    Main = Window:CreateTab{
        Title = "Shop",
        Icon = "nil"
    }
}

--// Toggle
local Toggle1 = Tabs.Main:CreateToggle("MyToggle", {Title = "Auto Harvest", Default = false})
local Toggle1Interacted = false

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

--// Helper: find the player's farm
local function GetPlayerFarm(player)
    for _, farm in pairs(workspace.Farm:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        if important and important:FindFirstChild("Data") then
            local owner = important.Data:FindFirstChild("Owner")
            if owner and owner.Value == player.Name then
                return farm
            end
        end
    end
    return nil
end

--// Harvest helper
local function HarvestPlant(Plant)
    if not Plant then return end
    local Prompt = Plant:FindFirstChildWhichIsA("ProximityPrompt", true)
    if Prompt and Prompt.Enabled then
        pcall(function() fireproximityprompt(Prompt) end)
    end
end

--// Collect harvestable plants (recursive)
local function CollectHarvestableFromFolder(folder, outTable)
    if not folder then return end

    for _, descendant in ipairs(folder:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
            table.insert(outTable, descendant.Parent)
        end
    end
end

--// Gather all harvestable plants in your farm
local function GetHarvestablePlantsForPlayer(player)
    local harvestable = {}
    local farm = GetPlayerFarm(player)
    if not farm then return harvestable end

    local important = farm:FindFirstChild("Important")
    if not important then return harvestable end

    local plantsPhysical = important:FindFirstChild("Plants_Physical")
    if plantsPhysical then
        CollectHarvestableFromFolder(plantsPhysical, harvestable)
    end

    return harvestable
end

--// Auto Harvest System
local AutoHarvesting = false

local function StartAutoHarvest()
    if AutoHarvesting then return end
    AutoHarvesting = true

    task.spawn(function()
        while AutoHarvesting do
            local plants = GetHarvestablePlantsForPlayer(LocalPlayer)

            for _, plant in ipairs(plants) do
                if not AutoHarvesting then break end

                if plant.Name:lower():find("Tomato") then
                    HarvestPlant(plant)
                    task.wait(0.1)
                end
            end

            task.wait(1)
        end
    end)
end

local function StopAutoHarvest()
    AutoHarvesting = false
end

--// Toggle connection (keep your interaction guard)
Toggle1:OnChanged(function(state)
    if not Toggle1Interacted then
        Toggle1Interacted = true
        return
    end

    if state then
        StartAutoHarvest()
    else
        StopAutoHarvest()
    end
end)
