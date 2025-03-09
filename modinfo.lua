name = "自动堆叠掉落物"
description = "自动将附近的同类掉落物堆叠在一起"
author = "Va6gn"
version = "1.0.0"

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

-- mod配置选项
configuration_options = {
    {
        name = "STACK_INTERVAL",
        label = "堆叠间隔",
        hover = "多久执行一次堆叠操作（秒）",
        options = {
            {description = "10秒", data = 10},
            {description = "20秒", data = 20},
            {description = "30秒", data = 30, hover = "推荐"},
            {description = "60秒", data = 60},
            {description = "120秒", data = 120}
        },
        default = 30
    },
    {
        name = "STACK_RADIUS",
        label = "堆叠范围",
        hover = "检查多大范围内的物品进行堆叠（格子）",
        options = {
            {description = "3格", data = 3},
            {description = "5格", data = 5, hover = "推荐"},
            {description = "8格", data = 8},
            {description = "10格", data = 10},
            {description = "15格", data = 15}
        },
        default = 5
    },
    {
        name = "START_DELAY",
        label = "启动延迟",
        hover = "游戏开始后多久开始第一次堆叠（秒）",
        options = {
            {description = "5秒", data = 5},
            {description = "10秒", data = 10, hover = "推荐"},
            {description = "20秒", data = 20},
            {description = "30秒", data = 30},
            {description = "60秒", data = 60}
        },
        default = 10
    },
    {
        name = "SORT_METHOD",
        label = "堆叠顺序",
        hover = "决定如何选择堆叠目标",
        options = {
            {description = "多到少", data = "most_first", hover = "优先堆叠到数量最多的物品"},
            {description = "少到多", data = "least_first", hover = "优先堆叠到数量最少的物品"},
            {description = "平均分配", data = "balanced", hover = "尝试平均分配物品数量"}
        },
        default = "most_first"
    }
} 