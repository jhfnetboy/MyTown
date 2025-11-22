# MyTown 技术架构文档

> **版本**: v0.1  
> **日期**: 2025-11-22  
> **状态**: Draft

---

## 🏗️ 系统架构概览

### 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                      MyTown 系统架构                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     表现层 (Presentation)                    │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │ Godot桌面应用 │  │ Godot Web版  │  │  浏览器插件      │   │
│  │ (GDScript)   │  │ (WASM)       │  │  (JS/HTML)      │   │
│  └──────────────┘  └──────────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     核心层 (Core Engine)                     │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Agent系统 (GDScript)                     │  │
│  │  ├─ AgentManager (角色管理)                          │  │
│  │  ├─ MemorySystem (记忆流)                            │  │
│  │  ├─ BehaviorSystem (行为决策)                        │  │
│  │  └─ RelationshipSystem (关系网络)                    │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              场景系统 (GDScript)                      │  │
│  │  ├─ SceneManager (场景管理)                          │  │
│  │  ├─ TimeSystem (时间系统)                            │  │
│  │  ├─ WeatherSystem (天气系统)                         │  │
│  │  └─ EventSystem (事件系统)                           │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              AI集成层 (GDScript)                      │  │
│  │  ├─ AIManager (AI调度)                               │  │
│  │  ├─ PromptEngine (Prompt生成)                        │  │
│  │  └─ CostTracker (成本追踪)                           │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     服务层 (Services)                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐   │
│  │ 本地AI服务   │  │ 云端AI服务   │  │ 社区AI节点[未来] │   │
│  │ (Ollama)    │  │ (OpenAI等)  │  │ (P2P Network)    │   │
│  └─────────────┘  └─────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     数据层 (Data)                            │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐   │
│  │ 本地存储     │  │ IPFS存储    │  │ 区块链[未来]      │   │
│  │ (SQLite)    │  │ (分布式)    │  │ (NFT/资产)       │   │
│  └─────────────┘  └─────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧩 核心模块设计

### 1. Agent系统

#### 1.1 数据结构

```gdscript
class_name Agent extends Node2D

# 基础属性
var id: String
var name: String
var profession: String
var personality: String
var gender: String

# 状态
var position: Vector2
var current_action: String
var emotion: String
var energy: float

# 记忆系统
var memory_stream: MemoryStream
var relationships: Dictionary  # {agent_id: Relationship}

# 行为系统
var current_plan: Plan
var current_task: Task
```

#### 1.2 记忆流系统 (Stanford架构)

```gdscript
class_name MemoryStream

# 记忆类型
enum MemoryType {
    OBSERVATION,   # 观察
    REFLECTION,    # 反思
    PLAN          # 规划
}

# 记忆条目
class Memory:
    var id: String
    var type: MemoryType
    var content: String
    var timestamp: int
    var importance: float  # 0-10
    var embedding: Array   # 向量表示(可选)

# 核心方法
func add_observation(content: String, importance: float)
func trigger_reflection() -> Array  # 返回反思记忆
func generate_plan() -> Plan
func retrieve_memories(query: String, k: int) -> Array
```

#### 1.3 记忆检索算法

```gdscript
func retrieve_memories(query: String, k: int = 5) -> Array:
    var scored_memories = []
    
    for memory in all_memories:
        var score = 0.0
        
        # 1. 时效性 (Recency)
        var hours_ago = (Time.get_unix_time() - memory.timestamp) / 3600.0
        var recency_score = exp(-0.99 * hours_ago)
        
        # 2. 重要性 (Importance)
        var importance_score = memory.importance / 10.0
        
        # 3. 相关性 (Relevance) - 简化版用关键词匹配
        var relevance_score = calculate_relevance(query, memory.content)
        
        # 综合得分
        score = recency_score + importance_score + relevance_score
        scored_memories.append({"memory": memory, "score": score})
    
    # 排序并返回Top K
    scored_memories.sort_custom(func(a, b): return a.score > b.score)
    return scored_memories.slice(0, k)
```

---

### 2. AI集成层

#### 2.1 AI Manager架构

```gdscript
class_name AIManager extends Node

# AI提供商
enum AIProvider {
    OLLAMA,      # 本地
    OPENAI,      # 云端
    COMMUNITY    # 社区节点(未来)
}

# 配置
var current_provider: AIProvider
var api_config: Dictionary

# 核心方法
func generate_dialogue(agent1: Agent, agent2: Agent, context: Dictionary) -> Dictionary
func generate_reflection(agent: Agent, observations: Array) -> String
func generate_plan(agent: Agent, context: Dictionary) -> Plan
```

#### 2.2 Prompt模板引擎

```gdscript
const DIALOGUE_PROMPT = """
你是{agent1_name},一个{agent1_profession},性格{agent1_personality}。
你正在与{agent2_name}({agent2_profession})对话。

场景: {scene_context}
时间: {time_context}
天气: {weather}

你们的关系: {relationship}
最近的对话:
{recent_conversations}

请生成一句自然的对话,符合你的性格和职业特点。
只返回对话内容,不要其他说明。
"""

func build_dialogue_prompt(agent1: Agent, agent2: Agent, context: Dictionary) -> String:
    return DIALOGUE_PROMPT.format({
        "agent1_name": agent1.name,
        "agent1_profession": agent1.profession,
        # ... 其他变量
    })
```

#### 2.3 成本追踪

```gdscript
class_name CostTracker extends Node

var total_tokens: int = 0
var total_cost: float = 0.0
var cost_limit: float = 10.0  # 美元

signal cost_warning(current_cost: float)
signal cost_limit_reached()

func track_api_call(provider: String, tokens: int):
    total_tokens += tokens
    var cost = calculate_cost(provider, tokens)
    total_cost += cost
    
    if total_cost > cost_limit * 0.8:
        emit_signal("cost_warning", total_cost)
    if total_cost >= cost_limit:
        emit_signal("cost_limit_reached")
```

---

### 3. 数据存储层

#### 3.1 SQLite Schema

```sql
-- Agent表
CREATE TABLE agents (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    profession TEXT,
    personality TEXT,
    gender TEXT,
    created_at INTEGER,
    data JSON  -- 其他属性
);

-- 记忆表
CREATE TABLE memories (
    id TEXT PRIMARY KEY,
    agent_id TEXT,
    type INTEGER,  -- 0=观察, 1=反思, 2=规划
    content TEXT,
    importance REAL,
    timestamp INTEGER,
    embedding BLOB,  -- 可选,向量表示
    FOREIGN KEY (agent_id) REFERENCES agents(id)
);

-- 对话表
CREATE TABLE conversations (
    id TEXT PRIMARY KEY,
    agent1_id TEXT,
    agent2_id TEXT,
    content TEXT,
    timestamp INTEGER,
    FOREIGN KEY (agent1_id) REFERENCES agents(id),
    FOREIGN KEY (agent2_id) REFERENCES agents(id)
);

-- 关系表
CREATE TABLE relationships (
    agent1_id TEXT,
    agent2_id TEXT,
    strength REAL,  -- 0-1
    type TEXT,      -- friend, colleague, stranger
    meet_count INTEGER,
    last_meet INTEGER,
    PRIMARY KEY (agent1_id, agent2_id)
);
```

#### 3.2 数据管理器

```gdscript
class_name DataManager extends Node

var db: SQLite

func save_agent(agent: Agent):
    var query = """
    INSERT OR REPLACE INTO agents (id, name, profession, personality, gender, created_at, data)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    """
    db.query_with_bindings(query, [agent.id, agent.name, ...])

func load_agent(agent_id: String) -> Agent:
    var query = "SELECT * FROM agents WHERE id = ?"
    var result = db.query_with_bindings(query, [agent_id])
    return Agent.from_dict(result[0])

func save_memory(agent_id: String, memory: Memory):
    # 类似实现
    pass
```

---

### 4. IPFS集成

#### 4.1 小镇数据结构

```json
{
  "version": "1.0",
  "metadata": {
    "title": "我的办公室小镇",
    "description": "一个模拟办公室的AI小镇",
    "author": "0x123...",
    "created_at": 1700000000,
    "tags": ["office", "work", "simulation"]
  },
  "scene": {
    "type": "office",
    "time_speed": 1.0,
    "weather": "sunny"
  },
  "agents": [
    {
      "id": "agent_001",
      "name": "Alice",
      "profession": "项目经理",
      "personality": "热情开朗",
      "gender": "female",
      "initial_position": {"x": 100, "y": 200}
    }
  ],
  "memories": [],  // 可选,隐私数据不上传
  "assets": {
    "map": "ipfs://Qm...",
    "sprites": "ipfs://Qm..."
  }
}
```

#### 4.2 IPFS Manager

```gdscript
class_name IPFSManager extends Node

var ipfs_gateway: String = "https://ipfs.io/ipfs/"

func upload_town(town_data: Dictionary) -> String:
    # 序列化为JSON
    var json = JSON.stringify(town_data)
    
    # 上传到IPFS (通过HTTP API)
    var response = await upload_to_ipfs_api(json)
    var ipfs_hash = response["Hash"]
    
    return ipfs_hash

func load_town(ipfs_hash: String) -> Dictionary:
    var url = ipfs_gateway + ipfs_hash
    var response = await HTTPRequest.get(url)
    return JSON.parse(response.body)
```

---

## 🔧 技术选型

### 核心技术栈

| 层级 | 技术 | 理由 |
|------|------|------|
| **游戏引擎** | Godot 4.4+ | 开源、跨平台、轻量 |
| **编程语言** | GDScript | Godot原生,易学 |
| **本地数据库** | SQLite | 轻量、无服务器 |
| **本地AI** | Ollama | 开源、隐私、免费 |
| **云端AI** | OpenAI/Claude | 性能好、API稳定 |
| **分布式存储** | IPFS | 去中心化、内容寻址 |
| **永久存储** | Arweave | 一次付费、永久存储 |
| **区块链** | Ethereum/Polygon | 成熟生态、NFT支持 |

### 依赖库

```
# Godot插件
- godot-sqlite (SQLite集成)
- gdaimcp (MCP协议,AI集成)

# Python工具(可选)
- ollama (本地AI)
- openai (云端AI)
- ipfshttpclient (IPFS上传)
```

---

## 🚀 性能优化策略

### 1. AI调用优化

```gdscript
# 对话缓存
var dialogue_cache: Dictionary = {}

func generate_dialogue_cached(agent1: Agent, agent2: Agent, context: Dictionary):
    var cache_key = generate_cache_key(agent1, agent2, context)
    
    if dialogue_cache.has(cache_key):
        return dialogue_cache[cache_key]
    
    var result = await ai_manager.generate_dialogue(agent1, agent2, context)
    dialogue_cache[cache_key] = result
    return result
```

### 2. 批处理

```gdscript
# 批量处理Agent更新
func update_agents_batch(delta: float):
    var batch_size = 5
    var agents_to_update = get_active_agents()
    
    for i in range(0, agents_to_update.size(), batch_size):
        var batch = agents_to_update.slice(i, i + batch_size)
        await process_agent_batch(batch, delta)
```

### 3. 降级策略

```gdscript
# AI服务降级
func get_ai_response(prompt: String):
    # 优先本地
    if ollama_available:
        return await ollama.generate(prompt)
    # 降级到云端
    elif openai_available and cost_ok:
        return await openai.generate(prompt)
    # 最终降级到模板
    else:
        return get_template_response(prompt)
```

---

## 🔐 安全和隐私

### 1. 数据加密

```gdscript
# 用户数据加密
func encrypt_user_data(data: Dictionary, user_key: String) -> PackedByteArray:
    var json = JSON.stringify(data)
    return AESEncryption.encrypt(json.to_utf8_buffer(), user_key)

func decrypt_user_data(encrypted: PackedByteArray, user_key: String) -> Dictionary:
    var decrypted = AESEncryption.decrypt(encrypted, user_key)
    return JSON.parse(decrypted.get_string_from_utf8())
```

### 2. API密钥管理

```gdscript
# 密钥存储在本地加密文件
var config_path = "user://config.encrypted"

func save_api_key(key: String):
    var encrypted = encrypt_with_device_key(key)
    var file = FileAccess.open(config_path, FileAccess.WRITE)
    file.store_buffer(encrypted)
    file.close()
```

---

## 📊 监控和日志

```gdscript
class_name Logger extends Node

enum LogLevel { DEBUG, INFO, WARNING, ERROR }

func log(level: LogLevel, message: String, context: Dictionary = {}):
    var timestamp = Time.get_datetime_string_from_system()
    var log_entry = {
        "timestamp": timestamp,
        "level": LogLevel.keys()[level],
        "message": message,
        "context": context
    }
    
    # 写入日志文件
    write_to_log_file(log_entry)
    
    # 发送到监控(可选)
    if level >= LogLevel.ERROR:
        send_to_monitoring(log_entry)
```

---

## 🎯 总结

MyTown的技术架构遵循**模块化、可扩展、隐私优先**的原则:

1. ✅ **清晰的分层架构** - 表现层、核心层、服务层、数据层
2. ✅ **Stanford Agent算法** - 记忆流+反思+规划
3. ✅ **混合AI策略** - 本地优先,云端备选
4. ✅ **去中心化存储** - IPFS+Arweave
5. ✅ **性能优化** - 缓存、批处理、降级

**下一步**: 开始Phase 1开发!
