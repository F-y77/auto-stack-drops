-- 优化版掉落物堆叠模组
-- 支持自定义配置

-- 确保访问全局变量
GLOBAL = GLOBAL or _G

-- 从配置中获取参数
local STACK_INTERVAL = GetModConfigData("STACK_INTERVAL")
local STACK_RADIUS = GetModConfigData("STACK_RADIUS")
local START_DELAY = GetModConfigData("START_DELAY")
local SORT_METHOD = GetModConfigData("SORT_METHOD")
local ENABLE_STACK_DELAY = GetModConfigData("STACK_DELAY")
local ALLOW_MOB_STACK = GetModConfigData("ALLOW_MOB_STACK")
local STACK_MODE = GetModConfigData("STACK_MODE")

-- 定义基础资源列表
local BASIC_RESOURCES = {
    -- 基础资源
    "log",           -- 木头
    "rocks",         -- 石头
    "cutgrass",      -- 草
    "twigs",         -- 树枝
    "flint",         -- 燧石
    
    -- 可以根据需要添加更多基础资源

    "rock_avocado_fruit", --石果
    "rock_avocado_fruit_ripe", --熟石果

    "nitre",         -- 硝石
    "goldnugget",    -- 金块
    "cutreeds",      -- 芦苇
    "charcoal",      -- 木炭
    "petals",        -- 花瓣
    "foliage",       -- 蕨叶
    "rope",          -- 绳子
    "boards",        -- 木板
    "cutstone",      -- 石砖
    "papyrus",       -- 莎草纸
    "houndstooth",   -- 狗牙
    "stinger",       -- 蜂刺
    "silk",          -- 蜘蛛丝
    "ash",           -- 灰烬
    "pinecone",      -- 松果
    "acorn",         -- 橡果
    "twiggy_nut",    -- 树枝树种
    "seeds",         -- 种子
    "ice",           -- 冰
    "moonrocknugget" -- 月岩
}

-- 定义冬季盛宴物品列表
local WINTER_FEAST_ITEMS = {
    "winter_food1",      -- 姜饼人
    "winter_food2",      -- 糖果手杖
    "winter_food3",      -- 永恒水果蛋糕
    "winter_food4",      -- 巧克力饼干
    "winter_food5",      -- 冬季浆果塔
    "winter_food6",      -- 胡萝卜蛋糕
    "winter_food7",      -- 布丁
    "winter_food8",      -- 甜甜圈
    "winter_food9",      -- 薄荷糖
    "festive_plant",     -- 节日植物
    "festive_tree_item", -- 节日树
    "festive_tree_planter", -- 节日树盆栽
    "winter_ornament_plain1", -- 普通装饰品1
    "winter_ornament_plain2", -- 普通装饰品2
    "winter_ornament_plain3", -- 普通装饰品3
    "winter_ornament_plain4", -- 普通装饰品4
    "winter_ornament_plain5", -- 普通装饰品5
    "winter_ornament_plain6", -- 普通装饰品6
    "winter_ornament_fancy1", -- 精美装饰品1
    "winter_ornament_fancy2", -- 精美装饰品2
    "winter_ornament_fancy3", -- 精美装饰品3
    "winter_ornament_fancy4", -- 精美装饰品4
    "winter_ornament_fancy5", -- 精美装饰品5
    "winter_ornament_fancy6", -- 精美装饰品6
    "winter_ornament_light1", -- 节日灯1
    "winter_ornament_light2", -- 节日灯2
    "winter_ornament_light3", -- 节日灯3
    "winter_ornament_light4", -- 节日灯4
    "winter_ornament_light5", -- 节日灯5
    "winter_ornament_light6", -- 节日灯6
    "winter_ornament_light7", -- 节日灯7
    "winter_ornament_light8", -- 节日灯8
    "gift",              -- 礼物
    "giftwrap",          -- 礼物包装
    "winter_gingerbreadcookie", -- 姜饼饼干
    "winter_ornamentstar",      -- 星星装饰
    "winter_ornamentbutterfly", -- 蝴蝶装饰
    "winter_ornamentdeerhead",  -- 鹿头装饰
    -- 添加所有boss装饰品
    "winter_ornament_boss_bearger",
    "winter_ornament_boss_deerclops",
    "winter_ornament_boss_moose",
    "winter_ornament_boss_dragonfly",
    "winter_ornament_boss_beequeen",
    "winter_ornament_boss_toadstool",
    "winter_ornament_boss_antlion",
    "winter_ornament_boss_klaus",
    "winter_ornament_boss_fuelweaver",
    "winter_ornament_boss_malbatross",
    "winter_ornament_boss_crabking",
    "winter_ornament_boss_eyeofterror",
    "winter_ornament_boss_twinofterror",
    "winter_ornament_boss_wagstaff",
    "winter_ornament_boss_daywalker",
    "winter_ornament_boss_krampus",
    "winter_ornament_boss_minotaur",
    "winter_ornament_boss_pearl",
    "winter_ornament_boss_celestialchampion",
    "winter_ornament_boss_alterguardian",
    "winter_ornament_boss_stalker"
}

-- 将基础资源转换为查找表，以便快速检查
local BASIC_RESOURCES_LOOKUP = {}
for _, prefab in ipairs(BASIC_RESOURCES) do
    BASIC_RESOURCES_LOOKUP[prefab] = true
end

-- 将冬季盛宴物品转换为查找表
local WINTER_FEAST_ITEMS_LOOKUP = {}
for _, prefab in ipairs(WINTER_FEAST_ITEMS) do
    WINTER_FEAST_ITEMS_LOOKUP[prefab] = true
end

-- 在文件开头添加物品生成时间记录
-- 添加到AddPrefabPostInit之前
local function RecordSpawnTime(inst)
    if inst.components and inst.components.stackable then
        inst.spawn_time = GLOBAL.GetTime()
    end
end

AddPrefabPostInit("", RecordSpawnTime)

-- 执行堆叠的优化函数
local function EnhancedStackItems()
    -- 获取世界实例
    local world = GLOBAL.TheWorld
    if not world then return end
    
    -- 获取所有玩家
    local players = GLOBAL.AllPlayers
    if not players or #players == 0 then return end
    
    -- 对每个玩家周围的物品进行堆叠
    for _, player in ipairs(players) do
        if player and player:IsValid() then
            -- 获取玩家位置
            local x, y, z = player.Transform:GetWorldPosition()
            
            -- 修改查找条件，明确只查找掉落物
            local items = GLOBAL.TheSim:FindEntities(x, y, z, STACK_RADIUS, 
                {"_inventoryitem"}, -- 必须是物品
                {"INLIMBO", "NOCLICK", "catchable", "fire"} -- 排除这些标签
            )
            
            -- 分组
            local grouped = {}
            for _, item in ipairs(items) do
                -- 增加更多安全检查
                if item and item:IsValid() and item.prefab and 
                   item.components and item.components.stackable and 
                   not item.components.stackable:IsFull() and
                   item.components.inventoryitem and 
                   not item.components.inventoryitem:IsHeld() and
                   not item:HasTag("INLIMBO") and
                   -- 根据配置决定是否检查生物相关的条件
                   (ALLOW_MOB_STACK or (
                       not item:HasTag("mob") and
                       not item:HasTag("firefly") and
                       not item.components.health and
                       not item.components.locomotor
                   )) and
                   -- 根据堆叠模式决定是否堆叠该物品
                   (STACK_MODE == "all" or 
                    (STACK_MODE == "basic" and BASIC_RESOURCES_LOOKUP[item.prefab]) or
                    (STACK_MODE == "basic_winter" and (BASIC_RESOURCES_LOOKUP[item.prefab] or WINTER_FEAST_ITEMS_LOOKUP[item.prefab]))) then
                    
                    if not grouped[item.prefab] then
                        grouped[item.prefab] = {}
                    end
                    table.insert(grouped[item.prefab], item)
                end
            end
            
            -- 对每种物品类型进行堆叠
            for prefab, group in pairs(grouped) do
                if #group > 1 then
                    -- 根据配置的排序方法进行排序
                    if SORT_METHOD == "most_first" then
                        -- 从多到少排序
                        table.sort(group, function(a, b)
                            return a.components.stackable.stacksize > b.components.stackable.stacksize
                        end)
                    elseif SORT_METHOD == "least_first" then
                        -- 从少到多排序
                        table.sort(group, function(a, b)
                            return a.components.stackable.stacksize < b.components.stackable.stacksize
                        end)
                    elseif SORT_METHOD == "balanced" then
                        -- 平均分配，先计算平均值
                        local total = 0
                        for _, item in ipairs(group) do
                            total = total + item.components.stackable.stacksize
                        end
                        local average = total / #group
                        
                        -- 按照与平均值的差距排序
                        table.sort(group, function(a, b)
                            return math.abs(a.components.stackable.stacksize - average) < 
                                   math.abs(b.components.stackable.stacksize - average)
                        end)
                    elseif SORT_METHOD == "old_to_new" then
                        -- 从老到新排序，使用实体的创建时间
                        table.sort(group, function(a, b)
                            -- 获取物品的存在时间（如果没有则使用当前时间）
                            local a_time = a.spawn_time or 0
                            local b_time = b.spawn_time or 0
                            -- 防止比较nil值导致崩溃
                            if a_time == b_time then
                                return false -- 相等时保持原顺序
                            end
                            -- 较新的物品（时间值大）放在前面作为目标
                            return b_time < a_time
                        end)
                    elseif SORT_METHOD == "new_to_old" then
                        -- 从新到老排序，使用实体的创建时间
                        table.sort(group, function(a, b)
                            local a_time = a.spawn_time or 0
                            local b_time = b.spawn_time or 0
                            -- 防止比较nil值导致崩溃
                            if a_time == b_time then
                                return false -- 相等时保持原顺序
                            end
                            return a_time < b_time
                        end)
                    end
                    
                    -- 从第一个物品开始，尝试将其他物品堆叠到它上面
                    local target = group[1]
                    for i = 2, #group do
                        local item = group[i]
                        -- 增加额外的安全检查
                        if target and target:IsValid() and item and item:IsValid() then
                            -- 确保目标和物品都有必要的组件
                            if target.components and target.components.stackable and 
                               item.components and item.components.stackable then
                                
                                if ENABLE_STACK_DELAY then
                                    -- 启用延迟堆叠
                                    player:DoTaskInTime(0.1 * (i-2), function()
                                        -- 再次检查物品是否有效
                                        if target and target:IsValid() and item and item:IsValid() then
                                            if target.components.stackable and 
                                               not target.components.stackable:IsFull() then
                                                target.components.stackable:Put(item)
                                            end
                                        end
                                    end)
                                else
                                    -- 直接堆叠
                                    if not target.components.stackable:IsFull() then
                                        target.components.stackable:Put(item)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 延迟启动定时器
AddSimPostInit(function()
    -- 使用配置的延迟时间
    GLOBAL.TheWorld:DoTaskInTime(START_DELAY, function()
        -- 处理0秒间隔的特殊情况
        if STACK_INTERVAL <= 0 then
            -- 每帧执行一次堆叠
            GLOBAL.TheWorld:DoPeriodicTask(0, EnhancedStackItems)
        else
            -- 使用配置的间隔时间
            GLOBAL.TheWorld:DoPeriodicTask(STACK_INTERVAL, EnhancedStackItems)
        end
    end)
end) 