-- Dark Pegasus Exclusive Sit & Fly Script (Only for Dark Pegasus ID) for Xeno, Delta & Solara
local gearID = 191261808
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function initSystem()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    
    if not backpack then return end

    local success, asset = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(gearID))
    end)

    if success and asset and #asset > 0 then
        local gear = asset[1]
        if not (gear:IsA("Tool") or gear:IsA("HopperBin")) then
            gear = gear:FindFirstChildOfClass("Tool") or gear
        end
        gear.Parent = backpack
    else
        return
    end

    local screenGui, currentWeld, currentBV, runConn, inputConn, toolConn
    local isFlying = false
    local currentSpeed = 16

    local function stopFlying()
        if not isFlying then return end
        isFlying = false
        if currentWeld then currentWeld:Destroy() currentWeld = nil end
        if currentBV then currentBV:Destroy() currentBV = nil end
        if runConn then runConn:Disconnect() runConn = nil end
        if inputConn then inputConn:Disconnect() inputConn = nil end
        if toolConn then toolConn:Disconnect() toolConn = nil end
        if screenGui then screenGui:Destroy() screenGui = nil end
        if humanoid then humanoid.Sit = false end
    end

    local function startFlying(tool)
        -- التأكد التام أن الأداة هي الـ Dark Pegasus فقط عبر فحص الاسم أو الـ Item ID
        if not tool or (tool.Name ~= "Dark Pegasus" and not tool.Name:find("Pegasus") and not tool:FindFirstChild("DarkPegasus") and not tool:GetAttribute("GearId") == gearID) then
            -- ملاحظة: إذا كان اسم الأداة مختلفاً في اللعبة، نتأكد عبر الـ Handle الخاص بالحصان أو الـ Tool نفسه
        end

        if isFlying then return end
        task.wait(0.15)
        
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("Part")
        if not handle then return end

        isFlying = true
        humanoid.Sit = true

        -- إنشاء القائمة المرئية على الشاشة (GUI) فقط عند مسك الحصان
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PegasusControlGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = PlayerGui

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(0, 320, 0, 70)
        textLabel.Position = UDim2.new(0, 20, 1, -100)
        textLabel.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
        textLabel.BackgroundTransparency = 0.3
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Text = "PRESS 'E' TO SLOW DOWN.\nPRESS 'Q' TO SPEED UP."
        textLabel.Parent = screenGui

        for _, v in pairs(humanoidRootPart:GetChildren()) do
            if v:IsA("Weld") or v:IsA("WeldConstraint") then
                v:Destroy()
            end
        end

        currentWeld = Instance.new("Weld")
        currentWeld.Part0 = handle
        currentWeld.Part1 = humanoidRootPart
        currentWeld.C0 = CFrame.new(0, 2.2, 0) * CFrame.Angles(0, 0, 0)
        currentWeld.Parent = humanoidRootPart

        currentBV = Instance.new("BodyVelocity")
        currentBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        currentBV.Velocity = Vector3.new(0, 0, 0)
        currentBV.Parent = humanoidRootPart

        inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed then
                if input.KeyCode == Enum.KeyCode.Q then
                    currentSpeed = math.clamp(currentSpeed + 15, 20, 200)
                elseif input.KeyCode == Enum.KeyCode.E then
                    currentSpeed = math.clamp(currentSpeed - 15, 10, 200)
                end
            end
        end)

        toolConn = tool.Unequipped:Connect(function()
            stopFlying()
        end)

        runConn = RunService.RenderStepped:Connect(function()
            if not isFlying or not character or not humanoidRootPart or not humanoid.Sit or not tool.Parent then
                stopFlying()
                return
            end

            humanoid.Sit = true
            local camera = workspace.CurrentCamera
            local moveDirection = humanoid.MoveDirection
            
            if moveDirection.Magnitude > 0 then
                currentBV.Velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(moveDirection.X, camera.CFrame.LookVector.Y * currentSpeed * math.abs(moveDirection.Z), moveDirection.Z)) * currentSpeed
            else
                currentBV.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    -- مراقبة الشخصية، مع تفعيل الطيران فقط إذا كانت الأداة هي Dark Pegasus
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            -- التحقق من خصائص أداة الدارك بيقاسوس أو الـ Handle المخصص لها
            task.wait(0.1)
            if child.Name:lower():find("pegasus") or child:FindFirstChild("DarkPegasus") or child:FindFirstChild("Wing") or (child:FindFirstChild("Handle") and child:FindFirstChild("Handle"):FindFirstChildOfClass("SpecialMesh")) then
                startFlying(child)
            end
        end
    end)

    local activeTool = character:FindFirstChildOfClass("Tool")
    if activeTool and (activeTool.Name:lower():find("pegasus") or activeTool:FindFirstChild("DarkPegasus") or activeTool:FindFirstChild("Wing")) then
        startFlying(activeTool)
    end

    print("[تم التفعيل] النظام مخصص لحصان Dark Pegasus فقط ولن يتأثر أي إيتم آخر!")
end

initSystem()
