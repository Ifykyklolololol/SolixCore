# Solix ESP LIB

### If Your Seeing This You Should Already Have The ESP SOURCE In The Solix Group Chat!


## Features

*BoundingBox*



```
# Example use for Services
```lua
local S = SolixCore.Services

print(S.Players.LocalPlayer)
print(S.RunService.Heartbeat)
print(S.HttpService:GenerateGUID())
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
