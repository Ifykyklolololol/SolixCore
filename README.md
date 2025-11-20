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

# Example Use
```lua
-- This loop NEVER duplicates on reload.
Tasks.addTask(task.spawn(function()
    while true do
        
        -- Cached for 1 second
        local playerCount = Cache.get("playerCount", function()
            return #game.Players:GetPlayers()
        end, 1)

        print("Players:", playerCount)

        task.wait(0.2)
    end
end))
```

# Reload Safely Example
```lua
Tasks.addConnection(
    game.Players.PlayerAdded:Connect(function(plr)
        print("Player joined:", plr.Name)
    end)
)
```

# Cache Force Recompute
-- Forces the next Cache.get to recompute instantly.
```lua
Cache.force("playerCount")
```

# Manual Invalidation
```lua
Cache.invalidate("playerCount")  -- remove one key
Cache.invalidateAll()            -- wipe the entire cache
```

# Cache Stats 
```lua
print(Cache.stats())
```



❤️ Credits

Developed by RelixEnd
For the Solix Team
