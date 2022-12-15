Scheduler = {
    threads = {},
    current = 1
}

function Scheduler.create(func)
    local t = {}
    t.coroutine = coroutine.create(func)

    function t:stop()
        for i, th in pairs(Scheduler.threads) do
            if th == t then
                coroutine.yield(t.coroutine)
                coroutine.close(t.coroutine)
                table.remove(Scheduler.threads, i)
            end
        end
    end

    table.insert(Scheduler.threads, t)
    return t
end

function Scheduler.run()
    while true do
        if #Scheduler.threads < 1 then
            return
        end
        local t = Scheduler.threads[Scheduler.current]
        if coroutine.status(t.coroutine) == 'running' then
            coroutine.yield(t.coroutine)
        end
        if Scheduler.current > #Scheduler.threads then
            Scheduler.current = 1
        end
        t = Scheduler.threads[Scheduler.current].coroutine
        coroutine.resume(t.coroutine)
        Scheduler.current = Scheduler.current + 1
    end
end
