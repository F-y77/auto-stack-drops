-- 获取当前语言
local function GetLanguage()
    return locale ~= nil and locale or "zh"
end

local is_chinese = GetLanguage():find("zh") ~= nil

-- 双语标题和描述
name = is_chinese and "自动堆叠掉落物" or "Auto Stack Items"
description = is_chinese and "自动将附近的同类掉落物堆叠在一起" or "Automatically stack nearby similar items"
author = "Va6gn"
version = "1.6.0"

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

server_filter_tags = {
    "自动堆叠",
    "Auto Stack",
    "Va6gn",
}

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
    tiles = function(n) return is_chinese and n.."格" or n.." tiles" end,
    stack_delay = is_chinese and "延迟堆叠" or "Stack Delay",
    stack_delay_hover = is_chinese and "开启后物品会逐个堆叠，确保特殊效果能正确触发" or "Items will stack one by one to ensure special effects trigger correctly",
    stack_delay_on = is_chinese and "开启" or "Enable",
    stack_delay_off = is_chinese and "关闭" or "Disable",
    stack_delay_on_hover = is_chinese and "物品会逐个堆叠" or "Items will stack one by one",
    stack_delay_off_hover = is_chinese and "物品会立即堆叠" or "Items will stack instantly",
    allow_mob_stack = is_chinese and "允许生物堆叠" or "Allow Mob Stacking",
    allow_mob_stack_hover = is_chinese and "是否允许生物（如萤火虫等）进行堆叠" or "Whether to allow stacking of creatures (like fireflies)",
    allow_mob_stack_on = is_chinese and "允许" or "Allow",
    allow_mob_stack_off = is_chinese and "禁止" or "Disallow",
    allow_mob_stack_on_hover = is_chinese and "生物可以堆叠" or "Creatures can be stacked",
    allow_mob_stack_off_hover = is_chinese and "生物不会堆叠" or "Creatures will not be stacked",
    old_to_new = is_chinese and "老到新" or "Old to New",
    old_to_new_hover = is_chinese and "优先将旧物品堆叠到新物品上" or "Stack older items onto newer items",
    new_to_old = is_chinese and "新到老" or "New to Old",
    new_to_old_hover = is_chinese and "优先将新物品堆叠到旧物品上" or "Stack newer items onto older items",
    stack_mode = is_chinese and "堆叠模式" or "Stack Mode",
    stack_mode_hover = is_chinese and "选择哪些物品可以堆叠" or "Choose which items can be stacked",
    stack_all = is_chinese and "堆叠所有物品" or "Stack All Items",
    stack_all_hover = is_chinese and "堆叠所有可堆叠的物品" or "Stack all stackable items",
    stack_basic = is_chinese and "仅堆叠基础资源" or "Stack Basic Resources Only",
    stack_basic_hover = is_chinese and "只堆叠木头、石头、草、树枝和石果等基础资源" or "Only stack logs, rocks, grass, twigs, and flint etc.",
    stack_basic_winter = is_chinese and "基础资源+冬季盛宴物品" or "Basic Resources + Winter Feast Items",
    stack_basic_winter_hover = is_chinese and "堆叠基础资源和冬季盛宴的物品" or "Stack basic resources and Winter Feast items"
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
            {description = config_labels.balanced, data = "balanced", hover = config_labels.balanced_hover},
            {description = config_labels.old_to_new, data = "old_to_new", hover = config_labels.old_to_new_hover},
            {description = config_labels.new_to_old, data = "new_to_old", hover = config_labels.new_to_old_hover}   
        },
        default = "most_first"
    },
    {
        name = "STACK_DELAY",
        label = config_labels.stack_delay,
        hover = config_labels.stack_delay_hover,
        options = {
            {description = config_labels.stack_delay_on, data = true, hover = config_labels.stack_delay_on_hover},
            {description = config_labels.stack_delay_off, data = false, hover = config_labels.stack_delay_off_hover},
        },
        default = true,
    },
    {
        name = "ALLOW_MOB_STACK",
        label = config_labels.allow_mob_stack,
        hover = config_labels.allow_mob_stack_hover,
        options = {
            {description = config_labels.allow_mob_stack_on, data = true, hover = config_labels.allow_mob_stack_on_hover},
            {description = config_labels.allow_mob_stack_off, data = false, hover = config_labels.allow_mob_stack_off_hover},
        },
        default = false,
    },
    {
        name = "STACK_MODE",
        label = config_labels.stack_mode,
        hover = config_labels.stack_mode_hover,
        options = {
            {description = config_labels.stack_all, data = "all", hover = config_labels.stack_all_hover},
            {description = config_labels.stack_basic, data = "basic", hover = config_labels.stack_basic_hover},
            {description = config_labels.stack_basic_winter, data = "basic_winter", hover = config_labels.stack_basic_winter_hover},
        },
        default = "all",
    },
} 