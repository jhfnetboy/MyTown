# gdaimcp 插件安装指南

## 关于 gdaimcp

gdaimcp 是一个Godot插件，用于通过MCP (Model Context Protocol) 协议集成AI服务。

官网: https://gdaimcp.com/docs

## 安装步骤

### 方法1: 从官网下载（推荐）

1. 访问 https://gdaimcp.com/docs
2. 找到下载链接并下载插件包
3. 解压插件到项目的 `addons/` 目录
4. 在Godot编辑器中启用插件：
   - 打开 `项目 -> 项目设置 -> 插件`
   - 找到 gdaimcp 并勾选启用

### 方法2: 从Godot Asset Library安装

1. 在Godot编辑器中打开 `AssetLib` 标签
2. 搜索 "gdaimcp"
3. 点击下载并安装
4. 在项目设置中启用插件

## 配置

安装完成后，需要配置AI服务：

1. **Ollama (本地AI)**
   - 确保Ollama已安装并运行
   - 默认地址: `http://localhost:11434`
   - 配置模型: `llama2`, `mistral` 等

2. **OpenAI (云端AI)**
   - 需要API Key
   - 在插件设置中配置密钥
   - 选择模型: `gpt-4`, `gpt-3.5-turbo` 等

## 验证安装

在GDScript中测试：

```gdscript
extends Node

func _ready():
    # 测试MCP连接
    var mcp = get_node("/root/MCP")  # 根据插件实际节点路径调整
    if mcp:
        print("✅ gdaimcp 插件已加载")
    else:
        print("❌ gdaimcp 插件未找到")
```

## 下一步

安装完成后，可以开始集成AI对话系统。参考技术架构文档中的AI Manager设计。

## 故障排除

### 问题1: 插件无法启用
- 检查Godot版本是否兼容（需要4.4+）
- 确认插件文件在正确的 `addons/` 目录下

### 问题2: MCP连接失败
- 检查Ollama是否运行
- 验证API密钥是否正确
- 查看Godot输出日志

## 参考资源

- 官方文档: https://gdaimcp.com/docs
- MCP协议: https://modelcontextprotocol.io/
- Ollama: https://ollama.ai/
