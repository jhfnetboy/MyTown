#!/bin/bash

# MyTown项目 - Godot导入和运行脚本

GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_PATH="/Users/jason/Dev/crypto-projects/MyTown"

echo "🎮 MyTown - Godot 4.5.1 项目管理脚本"
echo "=================================="
echo ""

# 检查Godot是否存在
if [ ! -f "$GODOT_PATH" ]; then
    echo "❌ 错误: 找不到Godot，请确保已安装到 /Applications/Godot.app"
    exit 1
fi

# 显示Godot版本
echo "📦 Godot版本:"
"$GODOT_PATH" --version
echo ""

# 菜单
echo "请选择操作:"
echo "1) 导入/打开项目（编辑器模式）"
echo "2) 运行项目"
echo "3) 导出项目"
echo "4) 清理.godot缓存"
echo ""
read -p "请输入选项 (1-4): " choice

case $choice in
    1)
        echo "🚀 正在打开Godot编辑器..."
        "$GODOT_PATH" --editor --path "$PROJECT_PATH"
        ;;
    2)
        echo "▶️  正在运行项目..."
        "$GODOT_PATH" --path "$PROJECT_PATH"
        ;;
    3)
        echo "📦 导出功能需要在编辑器中配置导出预设"
        echo "请先在编辑器中设置导出选项"
        ;;
    4)
        echo "🧹 清理.godot缓存..."
        rm -rf "$PROJECT_PATH/.godot"
        echo "✅ 缓存已清理"
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac
