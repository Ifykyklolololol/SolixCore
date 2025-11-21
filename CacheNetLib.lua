--// SolixCore
--// Core runtime utilities for SolixHub
--// - SolixCore.Cache  : enterprise-grade caching (error-safe, epoch-safe)
--// - SolixCore.Tasks  : task + connection lifecycle manager (no overlaps)

local genv = getgenv()
local cloneref = cloneref or newcclosure(function(...) return (...) end)
genv.SolixCore = genv.SolixCore or {}
local Core = genv.SolixCore

-- Prevent double-definition, but allow Tasks to reset on reload
Core.__VERSION = "1.0.1"
---------------------------------------------------------------------
-- SERVICES HELPER
-- SolixCore.Services.ServiceName -> game:GetService("ServiceName")
---------------------------------------------------------------------
Core.Services = Core.Services or setmetatable({}, {
    __index = function(self, key)
        local service = cloneref(game:GetService(key))
        rawset(self, key, service) -- cache for next access
        return service
    end
})
Core.game = Core.Services
---------------------------------------------------------------------
-- TASK / CONNECTION MANAGER
---------------------------------------------------------------------
Core.Tasks = Core.Tasks or {}
local Tasks = Core.Tasks

Tasks._tasks = Tasks._tasks or {}
Tasks._connections = Tasks._connections or {}

function Tasks.cancelAllTasks()
    for _, t in ipairs(Tasks._tasks) do
        task.cancel(t)
    end
    table.clear(Tasks._tasks)
end

function Tasks.disconnectAllConnections()
    for _, c in ipairs(Tasks._connections) do
        if c and c.Disconnect then
            c:Disconnect()
        end
    end
    table.clear(Tasks._connections)
end

function Tasks.reset()
    Tasks.cancelAllTasks()
    Tasks.disconnectAllConnections()
end

function Tasks.addTask(threadHandle)
    table.insert(Tasks._tasks, threadHandle)
    return threadHandle
end

function Tasks.addConnection(conn)
    table.insert(Tasks._connections, conn)
    return conn
end

-- Auto-reset on script reload so you never stack loops/connections
Tasks.reset()

---------------------------------------------------------------------
-- CACHE SERVICE (v6, NAMESPACED)
---------------------------------------------------------------------
Core.Cache = Core.Cache or {}
local Cache = Core.Cache

-- Internal state
Cache._data          = Cache._data          or {}   -- key -> value or sentinel
Cache._timestamps    = Cache._timestamps    or {}   -- key -> last update time (os.clock)
Cache._defaultDelays = Cache._defaultDelays or {}   -- key -> persistent delay
Cache._locks         = Cache._locks         or {}   -- key -> true if computing
Cache._queues        = Cache._queues        or {}   -- key -> { waiting coroutines }
Cache._forced        = Cache._forced        or {}   -- key -> true if force recompute on next get
Cache._epochs        = Cache._epochs        or {}   -- key -> generation counter for invalidation
Cache._sentinel      = Cache._sentinel      or {}   -- sentinel for cached nil

Cache._stats = Cache._stats or {
    hits = 0,
    misses = 0,
    recomputes = 0,
    totalComputeTime = 0,
    lastComputeTime = 0,
    errors = 0
}

local clock = os.clock

local function decode(stored)
    if stored == Cache._sentinel then
        return nil
    end
    return stored
end

-- Wait for current compute on this key to finish (pure coroutine)
local function waitForLock(key)
    local co = coroutine.running()
    local q = Cache._queues[key]
    if not q then
        q = {}
        Cache._queues[key] = q
    end
    table.insert(q, co)
    return coroutine.yield()
end

-- Release lock and resume all waiters, barrier-style
local function releaseLock(key)
    Cache._locks[key] = nil

    local q = Cache._queues[key]
    if not q or #q == 0 then return end

    for i = 1, #q do
        local co = q[i]
        if coroutine.status(co) == "suspended" then
            coroutine.resume(co)
        end
    end

    table.clear(q) -- keep table to avoid churn / race issues
end

-- Decide if we should recompute
local function shouldUpdate(key, delayOverride, hasCache)
    -- Forced recompute wins once
    if Cache._forced[key] then
        Cache._forced[key] = nil
        return true
    end

    if not hasCache then
        return true
    end

    local d = delayOverride
    if d == nil then
        d = Cache._defaultDelays[key] or 0
    end

    if d <= 0 then
        -- 0-delay: always recompute when asked
        return true
    end

    local last = Cache._timestamps[key]
    if not last then
        return true
    end

    return (clock() - last) >= d
end

-- Force next get(key, fn) to recompute once
function Cache.force(key)
    Cache._forced[key] = true
end

-- Main API
-- key: any table key
-- computeFn: function(prevValue) or nil
-- delay: optional per-call delay override (seconds)
function Cache.get(key, computeFn, delay)
    local stored = Cache._data[key]
    local hasCache = (stored ~= nil)

    -- Read-only access (no compute)
    if not computeFn then
        if hasCache then
            Cache._stats.hits += 1
            return decode(stored)
        else
            Cache._stats.misses += 1
            return nil
        end
    end

    -- Another compute in progress for this key: wait for it
    if Cache._locks[key] then
        waitForLock(key)
        stored = Cache._data[key]
        hasCache = (stored ~= nil)

        if hasCache then
            Cache._stats.hits += 1
            return decode(stored)
        else
            Cache._stats.misses += 1
            return nil
        end
    end

    -- Decide if we actually need to recompute
    if hasCache and not shouldUpdate(key, delay, hasCache) then
        Cache._stats.hits += 1
        return decode(stored)
    end

    -- Compute path
    Cache._locks[key] = true

    local previous = decode(stored)
    local epochSnapshot = Cache._epochs[key] or 0
    local start = clock()
    local ok, resultOrErr = pcall(computeFn, previous)
    local dur = clock() - start

    Cache._stats.lastComputeTime = dur
    Cache._stats.totalComputeTime += dur

    if not ok then
        Cache._stats.errors += 1
        releaseLock(key)
        error(resultOrErr, 0)
    end

    -- Stats: cold vs warm
    if hasCache then
        Cache._stats.recomputes += 1
    else
        Cache._stats.misses += 1
    end

    if delay ~= nil then
        Cache._defaultDelays[key] = delay
    end

    -- Only store result if key has NOT been invalidated during this compute
    if epochSnapshot == (Cache._epochs[key] or 0) then
        if resultOrErr == nil then
            Cache._data[key] = Cache._sentinel
        else
            Cache._data[key] = resultOrErr
        end
        Cache._timestamps[key] = clock()
    end

    releaseLock(key)

    return resultOrErr
end

-- Manual set
function Cache.set(key, value, delay)
    Cache._data[key] = (value == nil) and Cache._sentinel or value
    Cache._timestamps[key] = clock()
    if delay ~= nil then
        Cache._defaultDelays[key] = delay
    end
end

-- Invalidate one key: clear current value and bump epoch
function Cache.invalidate(key)
    Cache._data[key] = nil
    Cache._timestamps[key] = nil
    Cache._defaultDelays[key] = nil
    Cache._forced[key] = nil
    Cache._epochs[key] = (Cache._epochs[key] or 0) + 1
end

-- Invalidate everything and reset stats
function Cache.invalidateAll()
    table.clear(Cache._data)
    table.clear(Cache._timestamps)
    table.clear(Cache._defaultDelays)
    table.clear(Cache._forced)

    for k in pairs(Cache._epochs) do
        Cache._epochs[k] = Cache._epochs[k] + 1
    end

    Cache._stats.hits = 0
    Cache._stats.misses = 0
    Cache._stats.recomputes = 0
    Cache._stats.totalComputeTime = 0
    Cache._stats.lastComputeTime = 0
    Cache._stats.errors = 0
end

function Cache.has(key)
    return Cache._data[key] ~= nil
end

function Cache.peekRaw(key)
    return Cache._data[key]  -- may be sentinel or nil
end

function Cache.stats()
    return {
        hits = Cache._stats.hits,
        misses = Cache._stats.misses,
        recomputes = Cache._stats.recomputes,
        totalComputeTime = Cache._stats.totalComputeTime,
        lastComputeTime = Cache._stats.lastComputeTime,
        errors = Cache._stats.errors
    }
end

