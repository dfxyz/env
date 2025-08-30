-- Translator: 使用Unicode输入字符

local function unicode(input, seg, env)
    if not seg:has_tag("unicode") or input == '' then return end

    if not env.unicode_keyword then
        local pattern = env.engine.schema.config:get_string('recognizer/patterns/unicode')
        env.unicode_keyword = pattern:sub(2,2) -- if pattern is '^U[0-9a-f]+', use 'U' as keyword
    end

    local ucodestr = input:match(env.unicode_keyword .. "(%x+)")
    if ucodestr and #ucodestr > 1 then
        local code = tonumber(ucodestr, 16)
        if code > 0x10FFFF then
            yield(Candidate("unicode", seg.start, seg._end, "数值超限！", ""))
            return
        end
        local text = utf8.char(code)
        yield(Candidate("unicode", seg.start, seg._end, text, string.format("U%x", code)))
        if code < 0x1000 then
            -- 0xFFF之前候选词补一位
            for i = 0, 15 do
                local text = utf8.char(code * 16 + i)
                yield(Candidate("unicode", seg.start, seg._end, text, string.format("U%x%x", code, i)))
            end
        else -- 0xFFF之后候选词的点位加一
            for i = 1, 15 - code % 16 do
                local text = utf8.char(code + i)
                yield(Candidate("unicode", seg.start, seg._end, text, string.format("U%x", code + i)))
            end
        end
    end
end

return unicode
