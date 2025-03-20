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

-- 在文件开头添加物品生成时间记录
-- 添加到AddPrefabPostInit之前
local function RecordSpawnTime(inst)
    if inst.components.stackable then
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
                   )) then
                    
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
                            local a_time = a.spawn_time or GLOBAL.GetTime()
                            local b_time = b.spawn_time or GLOBAL.GetTime()
                            -- 较新的物品（时间值大）放在前面作为目标
                            return b_time < a_time
                        end)
                    elseif SORT_METHOD == "new_to_old" then
                        -- 从新到老排序，使用实体的创建时间
                        table.sort(group, function(a, b)
                            return a.spawn_time < b.spawn_time
                        end)
                    end
                    
                    -- 从第一个物品开始，尝试将其他物品堆叠到它上面
                    local target = group[1]
                    for i = 2, #group do
                        local item = group[i]
                        if target and target:IsValid() and item and item:IsValid() then
                            if ENABLE_STACK_DELAY then
                                -- 启用延迟堆叠
                                player:DoTaskInTime(0.1 * (i-2), function()
                                    if target and target:IsValid() and item and item:IsValid() then
                                        if target.components.stackable and 
                                           not target.components.stackable:IsFull() then
                                            target.components.stackable:Put(item)
                                        end
                                    end
                                end)
                            else
                                -- 直接堆叠
                                if target.components.stackable and 
                                   not target.components.stackable:IsFull() then
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