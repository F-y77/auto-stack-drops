-- 优化版掉落物堆叠模组
-- 支持自定义配置

-- 确保访问全局变量
GLOBAL = GLOBAL or _G

-- 从配置中获取参数
local STACK_INTERVAL = GetModConfigData("STACK_INTERVAL")
local STACK_RADIUS = GetModConfigData("STACK_RADIUS")
local START_DELAY = GetModConfigData("START_DELAY")
local SORT_METHOD = GetModConfigData("SORT_METHOD")

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
            
            -- 获取附近物品
            local items = GLOBAL.TheSim:FindEntities(x, y, z, STACK_RADIUS, {"_inventoryitem"})
            
            -- 分组
            local grouped = {}
            for _, item in ipairs(items) do
                -- 基本安全检查
                if item and item:IsValid() and item.prefab and 
                   item.components and item.components.stackable and 
                   not item.components.stackable:IsFull() and
                   item.components.inventoryitem and 
                   not item.components.inventoryitem:IsHeld() then
                    
                    if not grouped[item.prefab] then
                        grouped[item.prefab] = {}
                    end
                    table.insert(grouped[item.prefab], item)
                end
            end
            
            -- 对每种物品类型进行堆叠
            for _, group in pairs(grouped) do
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
                        
                        -- 按照与平均值的差距排序（差距小的优先）
                        table.sort(group, function(a, b)
                            return math.abs(a.components.stackable.stacksize - average) < 
                                   math.abs(b.components.stackable.stacksize - average)
                        end)
                    end
                    
                    -- 从第一个物品开始，尝试将其他物品堆叠到它上面
                    local target_index = 1
                    local target = group[target_index]
                    
                    -- 一次性处理所有可堆叠的物品
                    for i = 1, #group do
                        -- 跳过目标自身
                        if i ~= target_index then
                            local item = group[i]
                            
                            if target and target:IsValid() and 
                               item and item:IsValid() then
                                
                                -- 计算可堆叠数量
                                local space = target.components.stackable.maxsize - target.components.stackable.stacksize
                                
                                if space > 0 then
                                    -- 执行堆叠
                                    local amount = math.min(space, item.components.stackable.stacksize)
                                    target.components.stackable:SetStackSize(target.components.stackable.stacksize + amount)
                                    
                                    if amount >= item.components.stackable.stacksize then
                                        -- 如果完全堆叠，移除物品
                                        item:Remove()
                                    else
                                        -- 否则减少物品的堆叠数量
                                        item.components.stackable:SetStackSize(item.components.stackable.stacksize - amount)
                                    end
                                    
                                    -- 如果目标已满，选择下一个有效物品作为新目标
                                    if target.components.stackable:IsFull() then
                                        -- 寻找下一个有效目标
                                        local found_new_target = false
                                        for j = 1, #group do
                                            if j ~= i and group[j] and group[j]:IsValid() and 
                                               not group[j].components.stackable:IsFull() then
                                                target_index = j
                                                target = group[j]
                                                found_new_target = true
                                                break
                                            end
                                        end
                                        
                                        -- 如果没有找到新目标，结束堆叠
                                        if not found_new_target then
                                            break
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
end

-- 延迟启动定时器
AddSimPostInit(function()
    -- 使用配置的延迟时间
    GLOBAL.TheWorld:DoTaskInTime(START_DELAY, function()
        -- 使用配置的间隔时间
        GLOBAL.TheWorld:DoPeriodicTask(STACK_INTERVAL, EnhancedStackItems)
    end)
end) 