-- 获取当前语言
local function GetLanguage()
    return locale ~= nil and locale or "zh"
end

local is_chinese = GetLanguage():find("zh") ~= nil

-- 双语标题和描述
name = is_chinese and "自动堆叠掉落物" or "Auto Stack Items"
description = is_chinese and "自动将附近的同类掉落物堆叠在一起" or "Automatically stack nearby similar items"
author = "Va6gn"
version = "1.1.0"

-- DST 兼容性
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
hamlet_compatible = true

-- 客户端/服务器设置
client_only_mod = false
all_clients_require_mod = true

-- API 版本
api_version = 10

-- mod图标
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- 双语配置选项
local config_labels = {
    stack_interval = is_chinese and "堆叠间隔" or "Stack Interval",
    stack_interval_hover = is_chinese and "多久执行一次堆叠操作（秒）" or "How often to perform stacking (seconds)",
    stack_radius = is_chinese and "堆叠范围" or "Stack Radius",
    stack_radius_hover = is_chinese and "检查多大范围内的物品进行堆叠（格子）" or "How far to check for items to stack (tiles)",
    start_delay = is_chinese and "启动延迟" or "Start Delay",
    start_delay_hover = is_chinese and "游戏开始后多久开始第一次堆叠（秒）" or "How long to wait before first stack after game starts (seconds)",
    sort_method = is_chinese and "堆叠顺序" or "Stack Order",
    sort_method_hover = is_chinese and "决定如何选择堆叠目标" or "Determines how to choose stacking targets",
    most_first = is_chinese and "多到少" or "Most to Least",
    most_first_hover = is_chinese and "优先堆叠到数量最多的物品" or "Stack to items with the most quantity first",
    least_first = is_chinese and "少到多" or "Least to Most",
    least_first_hover = is_chinese and "优先堆叠到数量最少的物品" or "Stack to items with the least quantity first",
    balanced = is_chinese and "平均分配" or "Balanced",
    balanced_hover = is_chinese and "尝试平均分配物品数量" or "Try to distribute items evenly",
    recommended = is_chinese and "推荐" or "Recommended",
    seconds = function(n) return is_chinese and n.."秒" or n.." seconds" end,
    zero_seconds = is_chinese and "0秒" or "0 seconds",
    instant = is_chinese and "立即" or "Instant",
    tiles = function(n) return is_chinese and n.."格" or n.." tiles" end
}

-- mod配置选项
configuration_options = {
    {
        name = "STACK_INTERVAL",
        label = config_labels.stack_interval,
        hover = config_labels.stack_interval_hover,
        options = {
            {description = config_labels.instant, data = 0},
            {description = config_labels.seconds(1), data = 1},
            {description = config_labels.seconds(2), data = 2},
            {description = config_labels.seconds(5), data = 5},
            {description = config_labels.seconds(10), data = 10, hover = config_labels.recommended},
            {description = config_labels.seconds(20), data = 20},
            {description = config_labels.seconds(30), data = 30},
            {description = config_labels.seconds(60), data = 60},
            {description = config_labels.seconds(120), data = 120}
        },
        default = 10
    },
    {
        name = "STACK_RADIUS",
        label = config_labels.stack_radius,
        hover = config_labels.stack_radius_hover,
        options = {
            {description = config_labels.tiles(3), data = 3},
            {description = config_labels.tiles(5), data = 5},
            {description = config_labels.tiles(8), data = 8, hover = config_labels.recommended},
            {description = config_labels.tiles(10), data = 10},
            {description = config_labels.tiles(15), data = 15},
            {description = config_labels.tiles(20), data = 20},
            {description = config_labels.tiles(30), data = 30}
        },
        default = 8
    },
    {
        name = "START_DELAY",
        label = config_labels.start_delay,
        hover = config_labels.start_delay_hover,
        options = {
            {description = config_labels.seconds(5), data = 5},
            {description = config_labels.seconds(10), data = 10, hover = config_labels.recommended},
            {description = config_labels.seconds(20), data = 20},
            {description = config_labels.seconds(30), data = 30},
            {description = config_labels.seconds(60), data = 60}
        },
        default = 10
    },
    {
        name = "SORT_METHOD",
        label = config_labels.sort_method,
        hover = config_labels.sort_method_hover,
        options = {
            {description = config_labels.most_first, data = "most_first", hover = config_labels.most_first_hover},
            {description = config_labels.least_first, data = "least_first", hover = config_labels.least_first_hover},
            {description = config_labels.balanced, data = "balanced", hover = config_labels.balanced_hover}
        },
        default = "most_first"
    }
} 