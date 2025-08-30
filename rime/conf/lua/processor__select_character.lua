-- Processor: 以词定字

local select = {}

function select.init(env)
    local config = env.engine.schema.config
    env.select_first_char_key = config:get_string('key_binder/select_character/first')
    env.select_last_char_key = config:get_string('key_binder/select_character/last')
end

function select.func(key, env)
    local engine = env.engine
    local context = env.engine.context

    if not key:release()
        and (context:is_composing() or context:has_menu())
        and (env.select_first_char_key or env.select_last_char_key)
    then
        local text = context.input
        if context:get_selected_candidate() then
            text = context:get_selected_candidate().text
        end
        if utf8.len(text) > 1 then
            if (key:repr() == env.select_first_char_key) then
                engine:commit_text(text:sub(1, utf8.offset(text, 2) - 1))
                context:clear()
                return 1
            elseif (key:repr() == env.select_last_char_key) then
                engine:commit_text(text:sub(utf8.offset(text, -1)))
                context:clear()
                return 1
            end
        else
            if key:repr() == env.select_first_char_key or key:repr() == env.select_last_char_key then
                engine:commit_text(text)
                context:clear()
                return 1
            end
        end
    end
    return 2
end

return select
