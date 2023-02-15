-- SPDX-FileCopyrightText: 2021 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT
--
--- Calculates the escape level of @p position in @p texture,
--- where @p texture is a texture definition string.
---
--- Escaping is needed for arguments of texture modifiers,
--- like `[combine:x,y,=...` and `[mask:...`.
---
--- The texture string documentation claims that texture definitions
--- can be grouped with parentheses.
--- This is not actually implemented in texture modifiers,
--- therefore this function is guarranteed to break at some time.
--- The consequences will be partially invalid textures on dim light nodes.
function morelights_dim.texture_escape_level(texture, position)
    -- Necessity to escape begins at any `[`.
    -- It ends at a `^` of corresponding escape level.
    --
    -- Examples: (escape level written below)
    -- a.png^b.png
    -- -----0-----
    --
    -- a.png^[mask:b.png^c.png
    -- --0--       --1-- --0--
    --
    -- a.png^[maks:b.png\^c.png
    -- --0--       -----1------
    --
    -- aaaaa.png\^bbbbbb.png
    -- ----0---- --invalid--
    local p = 1;
    local e = string.len(texture) + 1;
    local level = 0;

    while p < position do
        local next_begin = string.find(texture, "[", p, --[[plain]] true) or e;
        local next_end = string.find(texture, "^", p, --[[plain]] true) or e;

        if next_begin < next_end and next_begin < position then
            -- Escape level increases.
            level = level + 1;
            p = next_begin + 1;
        elseif next_end < next_begin and next_end < position then
            -- Escape level decreases down to the escape level of the ^.
            -- Check if the ^ has the current escape level.
            -- If not, reduce `level`, and set `p` to check it again.
            local current_escape = string.rep("\\", level);
            local actual_escape = string.sub(texture, next_end - level,
                                             next_end - 1);
            if current_escape ~= actual_escape then
                level = level - 1;
                p = next_end;
            else
                p = next_end + 1;
            end
        else
            break
        end
    end

    return level;
end

--- Replaces all occurences of @p part in @p texture by
--- `(part^[multiply:multiplier)`, according to minetest texture syntax.
---
--- Respects escape levels.
---
--- @returns the new texture string.
function morelights_dim.texture_multiply_parts(texture, part, multiplier)
    local l = string.len(part);
    local position = string.find(texture, part, 1, --[[plain]] true);

    while position do
        local level = morelights_dim.texture_escape_level(texture, position);
        local e = string.rep("\\", level);
        local replacement = "(" .. part .. e .. "^[multiply" .. e .. ":" ..
                                    multiplier .. ")";
        texture = string.sub(texture, 1, position - 1) .. replacement ..
                          string.sub(texture, position + l);

        -- Advance `position` to the character after the current replacement.
        -- This must be accurate to prevent any replacements
        -- of already replaced sections.
        position = position + string.len(replacement);

        -- Find next occurence of `part` to replace.
        position = string.find(texture, part, position, --[[plain]] true);
    end

    return texture;
end
