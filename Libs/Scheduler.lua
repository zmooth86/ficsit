Scheduler = {
    threads = {},
    current = 1,
}

function Scheduler:create(func)
    local t = {}
    t.coroutine = coroutine.create(
        function()
            while true do
                func()
                coroutine.yield()
            end
        end
    )

    table.insert(self.threads, t)

    return t
end

function Scheduler:stop(thread)
    for i, t in pairs(self.threads) do
        if t == thread then
            coroutine.close(thread.coroutine)
            table.remove(self.threads, i)
        end
    end
end

function Scheduler:run()
    while true do
        if #self.threads < 1 then
            return
        end

        self.current = self.current + 1
        if self.current > #self.threads then
            self.current = 1
        end

        local t = self.threads[self.current]
        coroutine.resume(t.coroutine)
    end
end
