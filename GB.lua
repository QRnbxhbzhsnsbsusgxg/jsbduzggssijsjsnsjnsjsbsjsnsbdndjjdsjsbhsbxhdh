-- === 高级杀戮光环（新版ESP版）===
-- 作者：AI助手
-- 版本：高速攻击+转向控制版

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- ==================== 配置区域 ====================
-- 全局默认设置（如果武器没有单独设置，则使用这些值）
local GLOBAL_DEFAULTS = {
    ATTACK_RANGE = 17,
    AIM_RANGE = 17,
    MAX_TARGETS_PER_CYCLE = 6,
    INSTANT_ATTACK_RATE = 0.03,
    HITS_PER_ATTACK = 3,
    BARREL_PRIORITY_RANGE = 17,
    TROLL_MODE_RANGE = 9,
    ATTACK_DELAY_BETWEEN_TARGETS = 0.005,
    ATTACK_DELAY_AFTER_CYCLE = 0.01,
    ATTACK_BURST_LIMIT = 30,
    ATTACK_REST_TIME = 0.1,
    MULTI_HIT_ENABLED = false,
    MULTI_HIT_PARTS = {"Head"},
    MULTI_HIT_DELAY = 0.005,
    SIMULTANEOUS_HITS = false,
    GIB_ATTACK = false,
    AUTO_TURN = true
}

local MAX_DISPLAY_DISTANCE = 1000

-- ==================== 系统控制变量 ====================
local scriptRunning = true -- 控制脚本是否运行
local autoTurn = true -- 是否自动转向

-- ==================== 新增的 getNil 函数 ====================
local function getNil(name, class)
    for _, v in next, getnilinstances() do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
    return nil
end

-- ==================== 武器配置（每个武器单独设置） ====================
local weapons = {
    ["Voivode"] = {
        remotePath = "RemoteEvent", 
        attackType = "Thrust", 
        weaponType = "sword", 
        attackCount = 1,
        attackRange = 17,
        aimRange = 17,
        maxTargetsPerCycle = 6,
        instantAttackRate = 0.03,
        hitsPerAttack = 3,
        barrelPriorityRange = 17,
        attackDelayBetweenTargets = 0.005,
        attackDelayAfterCycle = 0.01,
        attackBurstLimit = 30,
        attackRestTime = 0.1,
        multiHitEnabled = false,
        multiHitDelay = 0.005,
        simultaneousHits = false,
        gibAttack = false,
        multiAttackParts = {"Head"}
    },
    
    ["Axe"] = {
        remotePath = "RemoteEvent", 
        attackType = "Side", 
        weaponType = "axe", 
        attackCount = 1,
        attackRange = 16,
        aimRange = 16,
        maxTargetsPerCycle = 6,
        instantAttackRate = 0.03,
        hitsPerAttack = 3,
        barrelPriorityRange = 16,
        attackDelayBetweenTargets = 0.005,
        attackDelayAfterCycle = 0.01,
        attackBurstLimit = 30,
        attackRestTime = 0.1,
        multiHitEnabled = false,
        multiHitDelay = 0.005,
        simultaneousHits = false,
        gibAttack = false,
        multiAttackParts = {"Head"}
    },
    
    ["Spontoon"] = {
        remotePath = "RemoteEvent", 
        attackType = "Thrust", 
        weaponType = "spear", 
        attackCount = 2,
        attackRange = 18,
        aimRange = 18,
        maxTargetsPerCycle = 6,
        instantAttackRate = 0.03,
        hitsPerAttack = 3,
        barrelPriorityRange = 18,
        attackDelayBetweenTargets = 0.005,
        attackDelayAfterCycle = 0.01,
        attackBurstLimit = 30,
        attackRestTime = 0.1,
        multiHitEnabled = false,
        multiHitDelay = 0.005,
        simultaneousHits = false,
        gibAttack = false,
        multiAttackParts = {"Head"}
    },
    
    ["Boarding Axe"] = {
        remotePath = "RemoteEvent", 
        attackType = "Thrust", 
        weaponType = "axe", 
        attackCount = 1,
        attackRange = 18,
        aimRange = 18,
        maxTargetsPerCycle = 6,
        instantAttackRate = 0.03,
        hitsPerAttack = 3,
        barrelPriorityRange = 15,
        attackDelayBetweenTargets = 0.005,
        attackDelayAfterCycle = 0.01,
        attackBurstLimit = 30,
        attackRestTime = 0.1,
        multiHitEnabled = false,
        multiHitDelay = 0.005,
        simultaneousHits = false,
        gibAttack = false,
        multiAttackParts = {"Head"}
    },

    ["Pickaxe"] = {
        remotePath = "RemoteEvent", 
        attackType = "Side", 
        weaponType = "pickaxe", 
        attackCount = 1,
        attackRange = 16,
        aimRange = 16,
        maxTargetsPerCycle = 6,
        instantAttackRate = 0.03,
        hitsPerAttack = 1,
        barrelPriorityRange = 16,
        attackDelayBetweenTargets = 0.005,
        attackDelayAfterCycle = 0.01,
        attackBurstLimit = 999,
        attackRestTime = 0.1,
        multiHitEnabled = false,
        multiHitDelay = 0.005,
        simultaneousHits = false,
        gibAttack = true,
        gibRemotePath = "Remotes/Gib",
        multiAttackParts = {"Head"}
    },
    
    ["Sabre"] = {
        remotePath = "RemoteEvent", 
        attackType = "Thrust", 
        weaponType = "sword", 
        attackCount = 1,
        attackRange = 17,
        aimRange = 17,
        maxTargetsPerCycle = 6,
        instantAttackRate = 0.03,
        hitsPerAttack = 3,
        barrelPriorityRange = 17,
        attackDelayBetweenTargets = 0.005,
        attackDelayAfterCycle = 0.01,
        attackBurstLimit = 30,
        attackRestTime = 0.1,
        multiHitEnabled = false,
        multiHitDelay = 0.005,
        simultaneousHits = false,
        gibAttack = true,
        gibRemotePath = "Remotes/Gib",
        multiAttackParts = {"Head"}
    },
    
    ["Pike"] = {
        remotePath = "RemoteEvent", 
        attackType = "Thrust", 
        weaponType = "spear", 
        attackCount = 1,
        attackRange = 18,
        aimRange = 18,
        maxTargetsPerCycle = 6,
        instantAttackRate = 0.02,
        hitsPerAttack = 10,
        barrelPriorityRange = 18,
        attackDelayBetweenTargets = 0.003,
        attackDelayAfterCycle = 0.005,
        attackBurstLimit = 40,
        attackRestTime = 0.08,
        multiHitEnabled = false,
        multiHitDelay = 0.003,
        simultaneousHits = false,
        gibAttack = true,
        gibRemotePath = "Remotes/Gib",
        multiAttackParts = {"Head"},
        fastAttack = true
    },
    
    ["Heavy Sabre"] = {
        remotePath = "RemoteEvent", 
        attackType = "Thrust", 
        weaponType = "sword", 
        attackCount = 1,
        attackRange = 17,
        aimRange = 17,
        maxTargetsPerCycle = 6,
        instantAttackRate = 0.02,
        hitsPerAttack = 4,
        barrelPriorityRange = 17,
        attackDelayBetweenTargets = 0.003,
        attackDelayAfterCycle = 0.005,
        attackBurstLimit = 40,
        attackRestTime = 0.08,
        multiHitEnabled = false,
        multiHitDelay = 0.003,
        simultaneousHits = false,
        gibAttack = true,
        gibRemotePath = "Remotes/Gib",
        multiAttackParts = {"Head"},
        fastAttack = true
    }
}

-- ==================== 僵尸类型配置 ====================
local zombieTypes = {
    ["Normal"] = {name = "僵尸", color = Color3.fromRGB(0, 255, 0), attack = true, priority = 1},
    ["Barrel"] = {name = "自爆王🤬", color = Color3.fromRGB(255, 255, 0), attack = true, priority = 3},
    ["Fast"] = {name = "红眼😈", color = Color3.fromRGB(255, 0, 0), attack = true, priority = 2},
    ["Igniter"] = {name = "耐烧王😡", color = Color3.fromRGB(255, 165, 0), attack = true, priority = 2},
    ["Sapper"] = {name = "大师兄😡", color = Color3.fromRGB(128, 0, 128), attack = true, priority = 2}
}

local zombieFolders = {"Zombies"}

-- ==================== 系统变量 ====================
local currentWeapon, currentWeaponConfig
local isWeaponActuallyEquipped = false 
local attackCooldown, lastAttackTime = {}, 0

-- 四种模式: "Normal", "Troll", "Disguise", "ExplosiveFast"
local currentMode = "Normal" 
local activeTrollTargets = {}
local trollAttackCooldown = {}
local attackBarrels = true
local isAttacking = false
local attackCounter = 0
local isResting = false
local restStartTime = 0
local multiHitEnabled = false
local multiHitDelay = 0.005
local simultaneousHits = false
local gibAttack = false
local gibRemotePath = nil

local attackBurstLimit, attackRestTime

-- 当前武器的攻击参数
local currentAttackRange, currentAimRange, currentMaxTargetsPerCycle, 
      currentInstantAttackRate, currentHitsPerAttack, currentBarrelPriorityRange,
      currentAttackDelayBetweenTargets, currentAttackDelayAfterCycle

-- ==================== UI 创建 ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KillAuraUI"
screenGui.Parent = game:GetService("CoreGui")

-- 创建一个可拖动的容器
local dragFrame = Instance.new("Frame")
dragFrame.Name = "DragFrame"
dragFrame.Size = UDim2.new(0, 110, 0, 160)
dragFrame.Position = UDim2.new(0, 20, 0, 20)
dragFrame.BackgroundTransparency = 1
dragFrame.Active = true
dragFrame.Selectable = true
dragFrame.Parent = screenGui

-- 模式切换按钮
local modeButton = Instance.new("TextButton")
modeButton.Name = "ModeToggle"
modeButton.Size = UDim2.new(0, 100, 0, 30)
modeButton.Position = UDim2.new(0, 5, 0, 5)
modeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Text = "模式: 普通"
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 12
modeButton.BorderSizePixel = 0

-- 攻击炸药桶开关按钮
local barrelButton = Instance.new("TextButton")
barrelButton.Name = "BarrelToggle"
barrelButton.Size = UDim2.new(0, 100, 0, 30)
barrelButton.Position = UDim2.new(0, 5, 0, 40)
barrelButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
barrelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
barrelButton.Text = "炸桶: 开"
barrelButton.Font = Enum.Font.GothamBold
barrelButton.TextSize = 12
barrelButton.BorderSizePixel = 0

-- 转向开关按钮
local turnButton = Instance.new("TextButton")
turnButton.Name = "TurnToggle"
turnButton.Size = UDim2.new(0, 100, 0, 30)
turnButton.Position = UDim2.new(0, 5, 0, 75)
turnButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
turnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
turnButton.Text = "转向: 开"
turnButton.Font = Enum.Font.GothamBold
turnButton.TextSize = 12
turnButton.BorderSizePixel = 0

-- 退出按钮
local exitButton = Instance.new("TextButton")
exitButton.Name = "ExitToggle"
exitButton.Size = UDim2.new(0, 100, 0, 30)
exitButton.Position = UDim2.new(0, 5, 0, 110)
exitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.Text = "退出光环"
exitButton.Font = Enum.Font.GothamBold
exitButton.TextSize = 12
exitButton.BorderSizePixel = 0

-- 创建圆角效果
local function applyButtonStyles(button)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 1.5
    stroke.Parent = button
    
    return button
end

modeButton = applyButtonStyles(modeButton)
barrelButton = applyButtonStyles(barrelButton)
turnButton = applyButtonStyles(turnButton)
exitButton = applyButtonStyles(exitButton)

modeButton.Parent = dragFrame
barrelButton.Parent = dragFrame
turnButton.Parent = dragFrame
exitButton.Parent = dragFrame

-- ==================== 屏幕提示文字 ====================
local noticeLabel = Instance.new("TextLabel")
noticeLabel.Name = "NoticeLabel"
noticeLabel.Size = UDim2.new(0.6, 0, 0, 50)
noticeLabel.Position = UDim2.new(0.2, 0, 0, 10)
noticeLabel.BackgroundTransparency = 0.8
noticeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
noticeLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
noticeLabel.Text = "仅供测试版 有bug请反馈\n目前支持9种近战武器 只攻击头部"
noticeLabel.Font = Enum.Font.GothamBold
noticeLabel.TextSize = 14
noticeLabel.TextStrokeTransparency = 0.7
noticeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
noticeLabel.TextWrapped = true
noticeLabel.Visible = true
noticeLabel.Parent = screenGui

-- 添加关闭提示的按钮
local closeNoticeButton = Instance.new("TextButton")
closeNoticeButton.Name = "CloseNoticeButton"
closeNoticeButton.Size = UDim2.new(0, 20, 0, 20)
closeNoticeButton.Position = UDim2.new(0.8, 5, 0, 15)
closeNoticeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeNoticeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeNoticeButton.Text = "X"
closeNoticeButton.Font = Enum.Font.GothamBold
closeNoticeButton.TextSize = 14
closeNoticeButton.Parent = noticeLabel

local noticeCorner = Instance.new("UICorner")
noticeCorner.CornerRadius = UDim.new(0, 8)
noticeCorner.Parent = noticeLabel

closeNoticeButton.MouseButton1Click:Connect(function()
    noticeLabel.Visible = false
end)

-- ==================== UI拖动功能 ====================
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    if not dragging then return end
    
    local delta = input.Position - dragStart
    dragFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

dragFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = dragFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dragFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- ==================== 按钮点击事件 ====================
modeButton.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    
    if currentMode == "Normal" then
        currentMode = "Troll"
        modeButton.Text = "模式: 恶搞"
        modeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    elseif currentMode == "Troll" then
        currentMode = "Disguise"
        modeButton.Text = "模式: 伪装"
        modeButton.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    elseif currentMode == "Disguise" then
        currentMode = "ExplosiveFast"
        modeButton.Text = "模式: 自爆红眼"
        modeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    elseif currentMode == "ExplosiveFast" then
        currentMode = "Normal"
        modeButton.Text = "模式: 普通"
        modeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

barrelButton.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    attackBarrels = not attackBarrels
    if attackBarrels then
        barrelButton.Text = "炸桶: 开"
        barrelButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        barrelButton.Text = "炸桶: 关"
        barrelButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

turnButton.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    autoTurn = not autoTurn
    if autoTurn then
        turnButton.Text = "转向: 开"
        turnButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    else
        turnButton.Text = "转向: 关"
        turnButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

exitButton.MouseButton1Click:Connect(function()
    scriptRunning = false
    
    -- 清理UI
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
    
    -- 重置所有变量
    currentWeapon, currentWeaponConfig = nil, nil
    isWeaponActuallyEquipped = false
    isAttacking = false
    attackCounter = 0
    isResting = false
    
    -- 停止所有攻击
    attackCooldown = {}
    
    print("杀戮光环已完全退出")
end)

-- 按钮悬停效果
local function setupButtonHover(button)
    button.MouseEnter:Connect(function()
        if not scriptRunning then return end
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundTransparency = 0.2})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        if not scriptRunning then return end
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundTransparency = 0})
        tween:Play()
    end)
end

setupButtonHover(modeButton)
setupButtonHover(barrelButton)
setupButtonHover(turnButton)
setupButtonHover(exitButton)

-- ==================== 核心函数 ====================

local function getZombieType(zombieModel)
    local zombieType = zombieModel:GetAttribute("Type")
    if not zombieType then
        local name = zombieModel.Name
        if name:find("Barrel") then return "Barrel"
        elseif name:find("Fast") then return "Fast"
        elseif name:find("Igniter") then return "Igniter"
        elseif name:find("Sapper") then return "Sapper"
        else return "Normal" end
    end
    return zombieType
end

local function getAllZombies()
    if not scriptRunning then return {} end
    local zombies = {}
    for _, folderName in ipairs(zombieFolders) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, zombie in ipairs(folder:GetChildren()) do
                if zombie:IsA("Model") and zombie:FindFirstChildOfClass("Humanoid", true) then
                     table.insert(zombies, zombie)
                end
            end
        end
    end
    return zombies
end

local function getAllPlayers()
    if not scriptRunning then return {} end
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                table.insert(players, {
                    character = character,
                    hrp = hrp,
                    name = player.Name
                })
            end
        end
    end
    return players
end

local function isAttackableZombie(zombieModel)
    local zombieType = getZombieType(zombieModel)
    local typeInfo = zombieTypes[zombieType] or zombieTypes["Normal"]
    
    -- 如果僵尸是炸药桶且攻击炸药桶开关关闭，则不攻击
    if zombieType == "Barrel" and not attackBarrels then
        return false
    end
    
    return typeInfo.attack
end

local function checkWeaponEquipped()
    if not scriptRunning then return false end
    if not char or not char.Parent then 
        isWeaponActuallyEquipped = false
        currentWeapon, currentWeaponConfig = nil, nil
        return false 
    end
    
    -- 首先检查角色身上
    for weaponName, config in pairs(weapons) do
        local weaponFound = char:FindFirstChild(weaponName)
        if weaponFound then
            currentWeapon = weaponFound
            currentWeaponConfig = config
            isWeaponActuallyEquipped = true
            
            -- 设置当前武器的攻击参数
            currentAttackRange = config.attackRange or GLOBAL_DEFAULTS.ATTACK_RANGE
            currentAimRange = config.aimRange or GLOBAL_DEFAULTS.AIM_RANGE
            currentMaxTargetsPerCycle = config.maxTargetsPerCycle or GLOBAL_DEFAULTS.MAX_TARGETS_PER_CYCLE
            currentInstantAttackRate = config.instantAttackRate or GLOBAL_DEFAULTS.INSTANT_ATTACK_RATE
            currentHitsPerAttack = config.hitsPerAttack or GLOBAL_DEFAULTS.HITS_PER_ATTACK
            currentBarrelPriorityRange = config.barrelPriorityRange or GLOBAL_DEFAULTS.BARREL_PRIORITY_RANGE
            currentAttackDelayBetweenTargets = config.attackDelayBetweenTargets or GLOBAL_DEFAULTS.ATTACK_DELAY_BETWEEN_TARGETS
            currentAttackDelayAfterCycle = config.attackDelayAfterCycle or GLOBAL_DEFAULTS.ATTACK_DELAY_AFTER_CYCLE
            attackBurstLimit = config.attackBurstLimit or GLOBAL_DEFAULTS.ATTACK_BURST_LIMIT
            attackRestTime = config.attackRestTime or GLOBAL_DEFAULTS.ATTACK_REST_TIME
            multiHitEnabled = config.multiHitEnabled or GLOBAL_DEFAULTS.MULTI_HIT_ENABLED
            multiHitDelay = config.multiHitDelay or GLOBAL_DEFAULTS.MULTI_HIT_DELAY
            simultaneousHits = config.simultaneousHits or GLOBAL_DEFAULTS.SIMULTANEOUS_HITS
            gibAttack = config.gibAttack or GLOBAL_DEFAULTS.GIB_ATTACK
            gibRemotePath = config.gibRemotePath
            
            return true
        end
    end
    
    isWeaponActuallyEquipped = false
    currentWeapon, currentWeaponConfig = nil, nil
    return false
end

local function getRemote()
    if not currentWeapon or not currentWeaponConfig then return nil end
    
    local remotePath = currentWeaponConfig.remotePath
    local remote = currentWeapon:FindFirstChild(remotePath)
    
    return remote
end

local function getGibRemote()
    if not gibRemotePath then return nil end
    local paths = string.split(gibRemotePath, "/")
    local current = ReplicatedStorage
    for _, path in ipairs(paths) do
        current = current:WaitForChild(path)
    end
    return current
end

local function aimAtTarget(targetPos)
    if not scriptRunning or not root or not autoTurn then return end
    local direction = (targetPos - root.Position).Unit
    root.CFrame = CFrame.lookAt(root.Position, root.Position + Vector3.new(direction.X, 0, direction.Z))
end

-- ==================== 目标获取函数（根据模式） ====================

local function getNormalModeTargets()
    local targets = {}
    local barrelTargets = {}
    
    for _, zombie in ipairs(getAllZombies()) do
        if not isAttackableZombie(zombie) then continue end
        
        -- 只攻击头部
        local headPart = zombie:FindFirstChild("Head", true)
        if not headPart or not headPart:IsA("BasePart") then continue end
        
        local hrp = zombie:FindFirstChild("HumanoidRootPart", true)
        if not hrp then continue end 
        
        local headSizeZ = headPart.Size.Z
        local hrpLookVector = hrp.CFrame.LookVector
        
        local attackPosition = headPart.Position - hrpLookVector * (headSizeZ / 2 * 0)
        
        local distance = (root.Position - attackPosition).Magnitude
        
        if distance <= currentAttackRange then
            local zombieType = getZombieType(zombie)
            local typeInfo = zombieTypes[zombieType] or zombieTypes["Normal"]
            
            local targetData = {
                model = zombie,
                part = headPart,
                position = attackPosition, 
                distance = distance,
                isHead = true,
                zombieType = zombieType,
                priority = typeInfo.priority or 1
            }
            
            if zombieType == "Barrel" and distance <= currentBarrelPriorityRange then
                table.insert(barrelTargets, targetData)
            else
                table.insert(targets, targetData)
            end
        end
    end
    
    -- 先按距离排序
    table.sort(barrelTargets, function(a, b) return a.distance < b.distance end)
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    
    -- 然后按优先级调整顺序
    local sortedTargets = {}
    
    -- 先加入炸药桶目标（如果有）
    for _, barrelTarget in ipairs(barrelTargets) do
        table.insert(sortedTargets, barrelTarget)
    end
    
    -- 再加入其他目标
    for _, target in ipairs(targets) do
        table.insert(sortedTargets, target)
    end
    
    return sortedTargets
end

local function getTrollModeTargets()
    local targets = {}
    local barrelTargets = {}
    local allPlayers = getAllPlayers()
    
    for _, zombie in ipairs(getAllZombies()) do
        if not isAttackableZombie(zombie) then continue end
        
        -- 只攻击头部
        local headPart = zombie:FindFirstChild("Head", true)
        if not headPart or not headPart:IsA("BasePart") then continue end
        
        local hrp = zombie:FindFirstChild("HumanoidRootPart", true)
        if not hrp then continue end 
        
        local headSizeZ = headPart.Size.Z
        local hrpLookVector = hrp.CFrame.LookVector
        
        local attackPosition = headPart.Position - hrpLookVector * (headSizeZ / 2 * 0)
        
        local distance = (root.Position - attackPosition).Magnitude
        
        if distance <= currentAttackRange then
            local zombieType = getZombieType(zombie)
            local typeInfo = zombieTypes[zombieType] or zombieTypes["Normal"]
            
            local targetData = {
                model = zombie,
                part = headPart,
                position = attackPosition, 
                distance = distance,
                isHead = true,
                zombieType = zombieType,
                priority = typeInfo.priority or 1
            }
            
            -- 在恶搞模式下，自爆僵尸需要特殊处理
            if zombieType == "Barrel" then
                -- 检查是否有队友在自爆僵尸附近 (7.9米范围内)
                local hasNearbyPlayer = false
                for _, playerData in ipairs(allPlayers) do
                    local playerToZombieDistance = (playerData.hrp.Position - hrp.Position).Magnitude
                    if playerToZombieDistance <= GLOBAL_DEFAULTS.TROLL_MODE_RANGE then
                        hasNearbyPlayer = true
                        break
                    end
                end
                
                -- 只有当有队友靠近时才攻击自爆僵尸
                if hasNearbyPlayer and distance <= currentBarrelPriorityRange then
                    table.insert(barrelTargets, targetData)
                end
            else
                table.insert(targets, targetData)
            end
        end
    end
    
    -- 先按距离排序
    table.sort(barrelTargets, function(a, b) return a.distance < b.distance end)
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    
    -- 然后按优先级调整顺序
    local sortedTargets = {}
    
    for _, barrelTarget in ipairs(barrelTargets) do
        table.insert(sortedTargets, barrelTarget)
    end
    
    for _, target in ipairs(targets) do
        table.insert(sortedTargets, target)
    end
    
    return sortedTargets
end

local function getDisguiseModeTargets()
    local targets = {}
    local allPlayers = getAllPlayers()
    
    for _, zombie in ipairs(getAllZombies()) do
        local zombieType = getZombieType(zombie)
        if zombieType ~= "Barrel" then continue end
        
        local headPart = zombie:FindFirstChild("Head", true)
        if not headPart or not headPart:IsA("BasePart") then continue end
        
        local hrp = zombie:FindFirstChild("HumanoidRootPart", true)
        if not hrp then continue end 
        
        local headSizeZ = headPart.Size.Z
        local hrpLookVector = hrp.CFrame.LookVector
        
        local attackPosition = headPart.Position - hrpLookVector * (headSizeZ / 2 * 0)
        
        local distance = (root.Position - attackPosition).Magnitude
        
        if distance <= currentAttackRange then
            local typeInfo = zombieTypes[zombieType] or zombieTypes["Normal"]
            
            local targetData = {
                model = zombie,
                part = headPart,
                position = attackPosition, 
                distance = distance,
                isHead = true,
                zombieType = zombieType,
                priority = typeInfo.priority or 1
            }
            
            local hasNearbyPlayer = false
            for _, playerData in ipairs(allPlayers) do
                local playerToZombieDistance = (playerData.hrp.Position - hrp.Position).Magnitude
                if playerToZombieDistance <= GLOBAL_DEFAULTS.TROLL_MODE_RANGE then
                    hasNearbyPlayer = true
                    break
                end
            end
            
            if hasNearbyPlayer and distance <= currentBarrelPriorityRange then
                table.insert(targets, targetData)
            end
        end
    end
    
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    
    return targets
end

local function getExplosiveFastModeTargets()
    local targets = {}
    
    for _, zombie in ipairs(getAllZombies()) do
        local zombieType = getZombieType(zombie)
        if zombieType ~= "Barrel" and zombieType ~= "Fast" then continue end
        
        local headPart = zombie:FindFirstChild("Head", true)
        if not headPart or not headPart:IsA("BasePart") then continue end
        
        local hrp = zombie:FindFirstChild("HumanoidRootPart", true)
        if not hrp then continue end 
        
        local headSizeZ = headPart.Size.Z
        local hrpLookVector = hrp.CFrame.LookVector
        
        local attackPosition = headPart.Position - hrpLookVector * (headSizeZ / 2 * 0)
        
        local distance = (root.Position - attackPosition).Magnitude
        
        if distance <= currentAttackRange then
            local typeInfo = zombieTypes[zombieType] or zombieTypes["Normal"]
            
            local targetData = {
                model = zombie,
                part = headPart,
                position = attackPosition, 
                distance = distance,
                isHead = true,
                zombieType = zombieType,
                priority = typeInfo.priority or 1
            }
            
            table.insert(targets, targetData)
        end
    end
    
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    
    return targets
end

local function getTargets()
    if currentMode == "Troll" then
        return getTrollModeTargets()
    elseif currentMode == "Disguise" then
        return getDisguiseModeTargets()
    elseif currentMode == "ExplosiveFast" then
        return getExplosiveFastModeTargets()
    else
        return getNormalModeTargets()
    end
end

-- ==================== 普通武器攻击函数 ====================
local function performSingleHit(remote, targetModel, attackPosition, attackType, isSpontoon, hitPartName)
    if not scriptRunning or not remote or not targetModel then return end
    
    if isSpontoon then
        remote:FireServer("Equip", root)
        remote:FireServer("PrepareSwing")
        remote:FireServer("Swing", "Thrust")
        remote:FireServer("HitZombie", targetModel, attackPosition, true, Vector3.zero, hitPartName, Vector3.new(0,1,0))
        task.wait(0.003)
        remote:FireServer("HitZombie", targetModel, attackPosition, true, Vector3.zero, hitPartName, Vector3.new(0,1,0))
    else
        remote:FireServer("Equip", root)
        remote:FireServer("PrepareSwing")
        remote:FireServer("Swing", attackType or "Side")
        remote:FireServer("HitZombie", targetModel, attackPosition, true, Vector3.zero, hitPartName, Vector3.new(0,1,0))
    end
end

-- ==================== Pickaxe 特殊攻击函数 ====================
local function performPickaxeAttack(target)
    if not scriptRunning or not humanoid or not humanoid.Parent then return end 
    
    local id = target.model:GetDebugId()
    if attackCooldown[id] and tick() - attackCooldown[id] < 0.08 then return end
    
    local remote = getRemote()
    local gibRemote = getGibRemote()
    if not remote then return end
    
    humanoid.Sit = false 
    humanoid:ChangeState(Enum.HumanoidStateType.Running) 
    
    local attackType = currentWeaponConfig and currentWeaponConfig.attackType
    
    local headPart = target.model:FindFirstChild("Head", true)
    if not headPart or not headPart:IsA("BasePart") then return end
    
    if autoTurn then
        aimAtTarget(headPart.Position)
    end
    
    remote:FireServer("Equip", root)
    remote:FireServer("PrepareSwing")
    remote:FireServer("Swing", attackType or "Side")
    
    if gibRemote then
        gibRemote:FireServer(target.model, "Head", headPart.Position, 
            (headPart.Position - root.Position).Unit * 0.5 + Vector3.new(0, 0.3, 0))
    end
    
    remote:FireServer("HitZombie", target.model, headPart.Position, 
        true, Vector3.new(0, 0, 0), "Head",
        (headPart.Position - root.Position).Unit * 0.5 + Vector3.new(0, 0.3, 0))
    
    attackCooldown[id] = tick()
    attackCounter = attackCounter + 1
end

-- ==================== Pike 和 Heavy Sabre 超快速攻击函数 ====================
local function performFastGibAttack(target, weaponName)
    if not scriptRunning or not humanoid or not humanoid.Parent then return end 
    
    local id = target.model:GetDebugId()
    if attackCooldown[id] and tick() - attackCooldown[id] < 0.06 then return end
    
    local remote = getRemote()
    local gibRemote = getGibRemote()
    if not remote then return end
    
    humanoid.Sit = false 
    humanoid:ChangeState(Enum.HumanoidStateType.Running) 
    
    local attackType = currentWeaponConfig and currentWeaponConfig.attackType
    
    local headPart = target.model:FindFirstChild("Head", true)
    if not headPart or not headPart:IsA("BasePart") then return end
    
    if autoTurn then
        aimAtTarget(headPart.Position)
    end
    
    remote:FireServer("Equip", root)
    remote:FireServer("PrepareSwing")
    remote:FireServer("Swing", attackType or "Thrust")
    
    if gibRemote then
        local zombieNil = getNil("Agent", "Model") or target.model
        local direction = (headPart.Position - root.Position).Unit * 0.5 + Vector3.new(0, 0.3, 0)
        
        gibRemote:FireServer(zombieNil, "Head", headPart.Position, direction)
    end
    
    for hit = 1, currentHitsPerAttack do
        remote:FireServer("HitZombie", target.model, headPart.Position, 
            true, Vector3.new(0, 0, 0), "Head",
            (headPart.Position - root.Position).Unit * 0.5 + Vector3.new(0, 0.3, 0))
        if hit < currentHitsPerAttack then
            task.wait(0.002)
        end
    end
    
    attackCooldown[id] = tick()
    attackCounter = attackCounter + 1
end

-- ==================== 通用攻击函数 ====================
local function multiHitTarget(target)
    if not scriptRunning or not humanoid or not humanoid.Parent then return end 
    
    local id = target.model:GetDebugId()
    local coolDownTime = 0.08
    
    if currentWeapon and (currentWeapon.Name == "Pike" or currentWeapon.Name == "Heavy Sabre") then
        coolDownTime = 0.06
    end
    
    if attackCooldown[id] and tick() - attackCooldown[id] < coolDownTime then return end
    
    if currentWeapon and currentWeapon.Name == "Pickaxe" then
        performPickaxeAttack(target)
    elseif currentWeapon and (currentWeapon.Name == "Pike" or currentWeapon.Name == "Heavy Sabre") then
        performFastGibAttack(target, currentWeapon.Name)
    else
        local remote = getRemote()
        if not remote then return end
        
        humanoid.Sit = false 
        humanoid:ChangeState(Enum.HumanoidStateType.Running) 
        
        local isSpontoon = currentWeapon and currentWeapon.Name == "Spontoon"
        local attackType = currentWeaponConfig and currentWeaponConfig.attackType
        
        local headPart = target.model:FindFirstChild("Head", true)
        if not headPart or not headPart:IsA("BasePart") then return end
        
        if autoTurn then
            aimAtTarget(headPart.Position)
        end
        
        for hit = 1, currentHitsPerAttack do
            performSingleHit(remote, target.model, headPart.Position, attackType, isSpontoon, "Head")
            if hit < currentHitsPerAttack then
                task.wait(0.003)
            end
        end
        
        attackCooldown[id] = tick()
        attackCounter = attackCounter + 1
    end
end

-- ==================== 智能休息检查函数 ====================
local function checkAndRest()
    if attackCounter >= attackBurstLimit then
        isResting = true
        restStartTime = tick()
        
        local restEndTime = restStartTime + attackRestTime
        while scriptRunning and tick() < restEndTime do
            task.wait(0.05)
        end
        
        attackCounter = 0
        isResting = false
        return true
    end
    return false
end

-- ==================== 优化后的攻击循环 ====================
local function smartAttackCycle()
    if not scriptRunning or isAttacking or isResting then return end
    
    checkWeaponEquipped()
    
    if not isWeaponActuallyEquipped then 
        task.wait(0.1)
        return 
    end
    
    isAttacking = true
    
    if checkAndRest() then
        isAttacking = false
        return
    end
    
    local targets = getTargets()
    
    if #targets > 0 then
        local targetsToAttack = {}
        local maxTargets = math.min(#targets, currentMaxTargetsPerCycle)
        
        for i = 1, maxTargets do
            table.insert(targetsToAttack, targets[i])
        end
        
        for index, target in ipairs(targetsToAttack) do
            if not scriptRunning then break end
            
            if target.model and target.model.Parent then
                local hrp = target.model:FindFirstChild("HumanoidRootPart", true)
                if hrp then
                    local currentDistance = (root.Position - hrp.Position).Magnitude
                    if currentDistance <= currentAttackRange then
                        multiHitTarget(target)
                        
                        if attackCounter >= attackBurstLimit then
                            break
                        end
                        
                        if index < #targetsToAttack then
                            task.wait(currentAttackDelayBetweenTargets)
                        end
                    end
                end
            end
            
            if attackCounter >= attackBurstLimit then
                break
            end
        end
        
        task.wait(currentAttackDelayAfterCycle)
    end
    
    isAttacking = false
end

-- ==================== ESP系统（完全按照您提供的新代码，修改为中文名称） ====================

--================ CONFIG ================
local CONFIG = {
    NameHeight = 0,
    TextSize = 9.5,
    HealthBar = {
        Width = 120,
        Height = 6,
        OffsetY = -18,
    },
    Zombies = {
        Normal       = { name = "普通",        color = Color3.fromRGB(0,255,0) },
        Burner       = { name = "烧火棍🥵",        color = Color3.fromRGB(255,255,0) },
        RedEye       = { name = "红眼👿",       color = Color3.fromRGB(255,0,0) },
        Curator      = { name = "馆长🤩",       color = Color3.fromRGB(0,170,255) },
        ArmorKnight  = { name = "骑兵💀",  color = Color3.fromRGB(255,105,180) },
        Master       = { name = "大师兄☠️",        color = Color3.fromRGB(160,0,255) },
        Bomber       = { name = "自爆王😍",        color = Color3.fromRGB(255,140,0) },
    }
}

--================ SAFE ROOT PART =================
local function getRootPart(z)
    return z:FindFirstChild("HumanoidRootPart", true)
        or z:FindFirstChild("Head", true)
        or z:FindFirstChildWhichIsA("BasePart", true)
end

--================ ZOMBIE TYPE =================
local function detectZombieType(z)
    if z:FindFirstChild("FTorso") and z.FTorso:FindFirstChild("Embers") then
        return "Burner"
    end
    if z:FindFirstChild("3") and z["3"]:FindFirstChild("4") then
        return "Bomber"
    end
    if z:FindFirstChild("Armor") and z.Armor:FindFirstChild("Armor") then
        return "ArmorKnight"
    end
    if z:FindFirstChild("E") then
        return "RedEye"
    end

    local hasHat = z:FindFirstChild("Hat") ~= nil
    local hasAxe = z:FindFirstChild("Axe") ~= nil

    if hasHat and hasAxe then
        return "Master"
    end
    if hasAxe and not hasHat then
        return "Curator"
    end

    return "Normal"
end

--================ HIGHLIGHT =================
local function applyHighlight(z, color)
    if z:FindFirstChild("DevHighlight") then return end
    local h = Instance.new("Highlight")
    h.Name = "DevHighlight"
    h.Adornee = z
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.Parent = z
end

--================ BILLBOARD =================
local function createESP(z, part, info)
    if z:GetAttribute("ESP_READY") then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "DevESP"
    gui.Adornee = part
    gui.AlwaysOnTop = true
    gui.Size = UDim2.fromOffset(160, 60)
    gui.StudsOffset = Vector3.new(0, CONFIG.NameHeight, 0)
    gui.Parent = z

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,0,0,18)
    label.Font = Enum.Font.GothamBold
    label.TextSize = CONFIG.TextSize
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextColor3 = info.color
    label.Text = info.name
    label.Parent = gui
    label:SetAttribute("BaseName", info.name)

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromOffset(CONFIG.HealthBar.Width, CONFIG.HealthBar.Height)
    bg.Position = UDim2.new(0.5, -CONFIG.HealthBar.Width/2, 0, CONFIG.HealthBar.OffsetY)
    bg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local fill = Instance.new("Frame")
    fill.Name = "HealthFill"
    fill.Size = UDim2.new(1,0,1,0)
    fill.BackgroundColor3 = info.color
    fill.BorderSizePixel = 0
    fill.Parent = bg

    z:SetAttribute("ESP_READY", true)
    z:SetAttribute("ZombieType", info.name)
end

--================ INIT =================
local function initZombie(z)
    if z:GetAttribute("ESP_READY") then return end

    local part = getRootPart(z)
    if not part then return end

    local zType = detectZombieType(z)
    local info = CONFIG.Zombies[zType]
    if not info then return end

    applyHighlight(z, info.color)
    createESP(z, part, info)
end

--================ MAIN LOOP =================
RS.RenderStepped:Connect(function()
    if not scriptRunning then return end
    
    local char = lp.Character
    local root = char and char:FindFirstChild("Head")
    
    -- 获取相机
    local camera = workspace.CurrentCamera
    if not camera then return end

    for _, z in ipairs(camera:GetChildren()) do
        if z:IsA("Model") and z.Name == "m_Zombie" then
            initZombie(z)

            local gui = z:FindFirstChild("DevESP")
            local part = getRootPart(z)

            if gui and part and root then
                local label = gui:FindFirstChildOfClass("TextLabel")
                local fill = gui:FindFirstChild("Frame"):FindFirstChild("HealthFill")

                local d = math.floor((root.Position - part.Position).Magnitude)
                -- 修改距离显示格式：去除中括号，显示为 "名字 距离m"
                label.Text = label:GetAttribute("BaseName") .. " " .. d .. "m"

                local hum = z:FindFirstChildOfClass("Humanoid")
                if hum and fill then
                    fill.Size = UDim2.new(
                        math.clamp(hum.Health / hum.MaxHealth, 0, 1),
                        0, 1, 0
                    )
                end
            end
        end
    end
end)

-- ==================== 优化的系统循环 ====================
task.spawn(function()
    while scriptRunning do
        task.wait(0.1)
        local currentTime = tick()
        for id, time in pairs(attackCooldown) do
            if currentTime - time > 0.3 then attackCooldown[id] = nil end
        end
    end
end)

-- ==================== 优化的攻击循环 ====================
RS.Heartbeat:Connect(function(deltaTime)
    if not scriptRunning then return end
    
    checkWeaponEquipped()
    
    if not isWeaponActuallyEquipped or isAttacking or isResting then return end
    
    local currentTime = tick()
    if currentTime - lastAttackTime >= currentInstantAttackRate then
        smartAttackCycle()
        lastAttackTime = currentTime
    end
end)

local function onCharacterAdded(newChar)
    if not scriptRunning then return end
    
    char = newChar
    root = char:WaitForChild("Head")
    humanoid = char:WaitForChild("Humanoid") 
    isWeaponActuallyEquipped = false
    currentWeapon, currentWeaponConfig = nil, nil
    isAttacking = false
    lastAttackTime = 0
    attackCounter = 0
    isResting = false
    
    task.wait(1)
end

if scriptRunning then
    lp.CharacterAdded:Connect(onCharacterAdded)
end
-- 全自动极速玩家名称修改系统修复版
-- 修复：聊天正常工作，无延迟名称修改
-- 功能：完全自动、实时修改玩家名称、设置菜单、聊天消息

-- 服务声明
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- 全局变量
local playerNameMap = {}
local playerIdMap = {}
local nextPlayerId = 1
local activeConnections = {}
local chatContainer = nil
local chatConnections = {}
local nameCache = {}
local initialized = false
local processingQueue = {}

-- 路径常量
local SETTINGS_PATH = {
    "RobloxGui", "SettingsClippingShield", "SettingsShield", 
    "MenuContainer", "Page", "PageViewClipper", "PageView", 
    "PageViewInnerFrame", "Players"
}

local CHAT_PATH = {
    "ExperienceChat", "appLayout", "chatWindow", "scrollingView",
    "bottomLockedScrollView", "RCTScrollView", "RCTScrollContentView"
}

-- 性能统计
local stats = {
    totalReplaced = 0,
    lastReportTime = tick(),
    messagesProcessed = 0
}

-- ========== 核心工具函数 ==========

-- 极速文本替换（单次扫描完成）
local function ultraFastReplace(text)
    if not text or text == "" or not playerIdMap then 
        return text 
    end
    
    local result = text
    
    -- 一次性扫描替换所有玩家名
    for oldName, playerId in pairs(playerIdMap) do
        local newName = "玩家" .. tostring(playerId)
        local startPos = 1
        
        while true do
            local foundPos = result:find(oldName, startPos, true)
            if not foundPos then break end
            
            result = result:sub(1, foundPos-1) .. newName .. result:sub(foundPos + #oldName)
            startPos = foundPos + #newName
            stats.totalReplaced = stats.totalReplaced + 1
        end
    end
    
    return result
end

-- 获取或分配玩家ID（保持已标记名称）
local function getOrAssignPlayerId(playerName)
    if playerIdMap[playerName] then
        return playerIdMap[playerName]
    end
    
    -- 查找可用的最小ID
    local usedIds = {}
    for _, id in pairs(playerIdMap) do
        usedIds[id] = true
    end
    
    local playerId = 1
    while usedIds[playerId] do
        playerId = playerId + 1
    end
    
    playerIdMap[playerName] = playerId
    nextPlayerId = playerId + 1
    
    return playerId
end

-- ========== 玩家名称管理系统 ==========

-- 立即更新玩家显示名称
local function updatePlayerDisplayName(player)
    if not player or not player.Parent then return end
    
    local playerId = getOrAssignPlayerId(player.Name)
    local displayName = "玩家" .. tostring(playerId)
    
    playerNameMap[player.Name] = displayName
    
    -- 立即修改当前角色
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.DisplayName = displayName
            end)
        end
    end
    
    -- 监听未来角色
    local conn = player.CharacterAdded:Connect(function(character)
        task.wait(0.05) -- 极短等待确保角色加载
        local humanoid = character:WaitForChild("Humanoid", 1)
        if humanoid then
            pcall(function()
                humanoid.DisplayName = displayName
            end)
        end
    end)
    
    table.insert(activeConnections, conn)
    
    -- 记录已处理的玩家
    nameCache[player.Name] = {
        id = playerId,
        name = displayName,
        lastSeen = tick(),
        online = true
    }
    
    return displayName
end

-- 批量处理所有玩家
local function processAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayerDisplayName(player)
    end
end

-- ========== 设置菜单实时监控系统 ==========

local settingsMonitorRunning = false

local function startSettingsMenuMonitor()
    if settingsMonitorRunning then return end
    settingsMonitorRunning = true
    
    task.spawn(function()
        local lastUpdate = 0
        local updateInterval = 0.016 -- ~60fps
        
        while settingsMonitorRunning do
            local currentTime = tick()
            
            if currentTime - lastUpdate >= updateInterval then
                lastUpdate = currentTime
                
                -- 直接查找设置菜单容器
                local current = CoreGui
                for _, name in ipairs(SETTINGS_PATH) do
                    current = current:FindFirstChild(name)
                    if not current then break end
                end
                
                if current then
                    -- 极速处理所有玩家标签
                    for _, playerLabel in ipairs(current:GetChildren()) do
                        if playerLabel.Name:find("PlayerLabel") then
                            local originalName = playerLabel.Name:match("PlayerLabel(.+)") or
                                               playerLabel.Name:gsub("PlayerLabel", "")
                            
                            if originalName ~= "" and playerNameMap[originalName] then
                                local newName = playerNameMap[originalName]
                                
                                -- 并行处理多个标签
                                task.spawn(function()
                                    local nameLabel = playerLabel:FindFirstChild("NameLabel")
                                    local displayNameLabel = playerLabel:FindFirstChild("DisplayNameLabel")
                                    
                                    if nameLabel and nameLabel:IsA("TextLabel") then
                                        pcall(function()
                                            nameLabel.Text = newName
                                        end)
                                    end
                                    
                                    if displayNameLabel and displayNameLabel:IsA("TextLabel") then
                                        pcall(function()
                                            displayNameLabel.Text = newName
                                        end)
                                    end
                                end)
                            end
                        end
                    end
                end
            end
            
            RunService.Heartbeat:Wait()
        end
    end)
end

-- ========== 超高速聊天监控系统 ==========

-- 查找聊天容器
local function findChatContainer()
    local current = CoreGui
    for _, name in ipairs(CHAT_PATH) do
        current = current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

-- 预替换函数：在消息显示前就修改
local function preReplaceMessage(messageObj)
    if not messageObj or not messageObj:IsDescendantOf(game) then return end
    
    -- 深度扫描所有文本元素
    for _, descendant in ipairs(messageObj:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            local text = descendant.Text
            if text and text ~= "" then
                -- 使用缓存检查
                local cacheKey = descendant:GetDebugId() .. "_" .. text
                local cached = processingQueue[cacheKey]
                
                if not cached then
                    processingQueue[cacheKey] = true
                    
                    task.spawn(function()
                        local modifiedText = ultraFastReplace(text)
                        
                        if modifiedText ~= text then
                            pcall(function()
                                descendant.Text = modifiedText
                            end)
                        end
                        
                        -- 短时间后清理缓存
                        task.delay(0.5, function()
                            processingQueue[cacheKey] = nil
                        end)
                    end)
                end
            end
        end
    end
end

-- 初始化聊天监控（只使用UI监控，不修改TextChatService）
local function initChatMonitor()
    print("启动UI聊天监控系统...")
    
    -- 方法：直接监控ExperienceChat UI（最快速且不会破坏聊天功能）
    task.spawn(function()
        local lastContainerCheck = 0
        
        while true do
            local currentTime = tick()
            
            -- 每0.1秒检查一次容器
            if currentTime - lastContainerCheck >= 0.01 then
                lastContainerCheck = currentTime
                
                -- 查找聊天容器
                local newChatContainer = findChatContainer()
                
                if newChatContainer and newChatContainer ~= chatContainer then
                    chatContainer = newChatContainer
                    
                    -- 清理旧的连接
                    for _, conn in pairs(chatConnections) do
                        pcall(function() conn:Disconnect() end)
                    end
                    chatConnections = {}
                    
                    -- 立即处理现有消息
                    for _, child in ipairs(chatContainer:GetChildren()) do
                        preReplaceMessage(child)
                    end
                    
                    -- 监听新消息
                    local conn1 = chatContainer.ChildAdded:Connect(function(child)
                        preReplaceMessage(child)
                    end)
                    
                    -- 监听后代添加（深度监控）
                    local conn2 = chatContainer.DescendantAdded:Connect(function(descendant)
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                            task.spawn(function()
                                local text = descendant.Text
                                if text and text ~= "" then
                                    local modifiedText = ultraFastReplace(text)
                                    if modifiedText ~= text then
                                        pcall(function()
                                            descendant.Text = modifiedText
                                        end)
                                    end
                                end
                            end)
                        end
                    end)
                    
                    table.insert(chatConnections, conn1)
                    table.insert(chatConnections, conn2)
                    
                    print("聊天监控已连接到最新容器")
                end
            end
            
            -- 高频处理消息队列（如果容器存在）
            if chatContainer then
                for _, child in ipairs(chatContainer:GetChildren()) do
                    preReplaceMessage(child)
                end
            end
            
            RunService.RenderStepped:Wait() -- 使用最高优先级
        end
    end)
end

-- ========== 全自动管理系统 ==========

local function startAutoManagement()
    print("开始初始化玩家名称修改系统...")
    
    -- 1. 处理现有玩家
    processAllPlayers()
    print("已处理现有玩家")
    
    -- 2. 监听新玩家
    Players.PlayerAdded:Connect(function(player)
        local displayName = updatePlayerDisplayName(player)
        print("新玩家加入: " .. player.Name .. " -> " .. displayName)
    end)
    
    -- 3. 监听玩家离开（保持已标记名称）
    Players.PlayerRemoving:Connect(function(player)
        -- 不删除映射，保持ID不变
        if nameCache[player.Name] then
            nameCache[player.Name].lastSeen = tick()
            nameCache[player.Name].online = false
            print("玩家离开: " .. nameCache[player.Name].name)
        end
    end)
    
    -- 4. 启动设置菜单监控
    task.delay(0, function()
        startSettingsMenuMonitor()
        print("设置菜单监控已启动")
    end)
    
    -- 5. 启动聊天监控
    task.delay(0, function()
        initChatMonitor()
        print("超高速聊天监控已启动")
    end)
    
    -- 6. 性能优化循环
    task.spawn(function()
        local lastCleanup = tick()
        
        while true do
            local currentTime = tick()
            
            -- 每10秒清理一次处理队列
            if currentTime - lastCleanup >= 10 then
                lastCleanup = currentTime
                
                -- 清理旧的处理记录（超过30秒）
                local newQueue = {}
                for key, time in pairs(processingQueue) do
                    if type(time) == "number" then
                        if currentTime - time < 30 then
                            newQueue[key] = time
                        end
                    else
                        newQueue[key] = currentTime
                    end
                end
                processingQueue = newQueue
                
                -- 显示系统状态
                local activePlayers = #Players:GetPlayers()
                local mappedPlayers = 0
                for _ in pairs(playerIdMap) do mappedPlayers = mappedPlayers + 1 end
                
                print(string.format("系统状态: 在线玩家%d人, 已映射%d人, 总替换%d次",
                    activePlayers, mappedPlayers, stats.totalReplaced))
            end
            
            task.wait(0.1)
        end
    end)
    
    initialized = true
    print("全自动玩家名称修改系统已完全启动")
    print("模式：保持已标记名称、超高速响应、全自动管理")
    
    -- 显示初始映射
    print("初始玩家映射:")
    for name, displayName in pairs(playerNameMap) do
        print("  " .. name .. " → " .. displayName)
    end
end

-- ========== 启动系统 ==========

-- 等待游戏完全加载
task.wait(0)

-- 安全启动
local success, err = pcall(startAutoManagement)
if not success then
    print("系统启动失败: " .. tostring(err))
    print("尝试基本模式...")
    
    -- 基本模式：只修改玩家显示名称
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                local playerId = getOrAssignPlayerId(player.Name)
                pcall(function()
                    humanoid.DisplayName = "玩家" .. tostring(playerId)
                end)
            end
        end
    end
    print("基本模式启动完成")
end

-- ========== 状态监控 ==========

task.spawn(function()
    task.wait(995)
    
    if initialized then
        local activePlayers = #Players:GetPlayers()
        local mappedPlayers = 0
        for _ in pairs(playerIdMap) do mappedPlayers = mappedPlayers + 1 end
        
        print("========== 系统运行状态 ==========")
        print("在线玩家: " .. activePlayers .. "人")
        print("已映射玩家: " .. mappedPlayers .. "人")
        print("总替换次数: " .. stats.totalReplaced)
        print("聊天容器状态: " .. (chatContainer and "已连接" or "未连接"))
        print("==================================")
    end
end)

-- 返回系统信息（可选）
return {
    GetPlayerCount = function() return #Players:GetPlayers() end,
    GetMappedCount = function() 
        local count = 0
        for _ in pairs(playerIdMap) do count = count + 1 end
        return count
    end,
    IsRunning = function() return initialized end,
    GetStats = function() return stats end,
    GetPlayerMapping = function() return playerNameMap end
}