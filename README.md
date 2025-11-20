# Cache & Connection System

### A high-performance, reload-safe runtime framework designed for scripting.
### Includes an proficient cache system and a connection/task manager that prevents stacked loops and duplicated events.

## Features

### Cache 
- Error-safe (**pcall** protected)  
- Epoch-safe (**no stale recomputes**)  
- Deadlock-proof  
- Pure coroutine waiting (no mixed yields)  
- Deterministic FIFO wakeup  
- Per-key delays  
- Manual invalidation  
- Forced recompute  
- Nil-safe sentinel  
- Cache statistics  
  - hits  
  - misses  
  - recomputes  
  - last compute time  
  - total compute time  
  - errors  

---

###  Tasks
- Prevents script reload stacking  
- Automatically cancels old loops  
- Automatically disconnects old events  
- Simple API (`addTask`, `addConnection`, `reset`)  

---

###  Reload-Safe Execution
Running your script multiple times **never creates duplicated loops or connections**.

---

# Load

```lua
local SolixCore = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ifykyklololololol/SolixCore/refs/heads/main/CacheNetLib.lua"))()

local Cache = SolixCore.Cache
local Tasks = SolixCore.Tasks
```
