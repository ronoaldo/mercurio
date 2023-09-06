local lunamark = dofile(md2f.mp .. "/lunamark.lua")

--Load markdown to hypertext read-writer
local writer = dofile(md2f.mp .. "/markdown2formspec/formspec_writer.lua").new(nil)

local formspec_parse = lunamark.reader.markdown.new(writer, { smart = false, fenced_code_blocks=true } )

--Create function to escape all non-printable characters
local util = dofile(md2f.mp .. "/lunamark/util.lua")
local escape = util.escaper {
    [string.char(0)] = "",
    [string.char(1)] = "",
    [string.char(2)] = "",
    [string.char(3)] = "",
    [string.char(4)] = "",
    [string.char(5)] = "",
    [string.char(6)] = "",
    [string.char(7)] = "",
    [string.char(8)] = "",
    [string.char(9)] = "    ", -- tab
    [string.char(11)] = "",
    [string.char(12)] = "",
    [string.char(13)] = "",
    [string.char(14)] = "",
    [string.char(15)] = "",
    [string.char(16)] = "",
    [string.char(17)] = "",
    [string.char(18)] = "",
    [string.char(19)] = "",
    [string.char(20)] = "",
    [string.char(21)] = "",
    [string.char(22)] = "",
    [string.char(23)] = "",
    [string.char(24)] = "",
    [string.char(25)] = "",
    [string.char(26)] = "",
    [string.char(27)] = "",
    [string.char(28)] = "",
    [string.char(29)] = "",
    [string.char(30)] = "",
    [string.char(31)] = "",
}


-- Relatively Short, very smart function, that adds necessary tabs to tabbed stuff
-- accomplished via gsub, i.e. a callback everytime the special 
-- two characters 0x03, and 0x04 are found. One is indent more, and the other
-- is indent less. 
local function handleNesting(text)
    local indent = 0
    local tab = string.rep(string.format("%s","\160"),md2f.settings.tab_size)
    text = string.gsub(text, "\n([\003\004])", "%1")
    return string.gsub(text, "([\003\004])([^\003\004]*)", 
        function(indent_variable, text_needing_tabbed)
            if indent_variable == "\003" then
                indent = indent + 1
            else
                indent = math.max((indent - 1),0)
            end
            return string.gsub(text_needing_tabbed, "\n", "\n".. string.rep(tab, indent))
        end
    )
end

local function parse(text,settings)
    md2f.settings = {}
    md2f.settings.width = settings.width
    md2f.settings.height = settings.height
    md2f.settings.background_color = settings.background_color or "#bababa25"
    md2f.settings.font_color = settings.font_color or "#FFF"
    md2f.settings.link_color = settings.link_color or "#77AAFF"
    md2f.settings.heading_1_color = settings.heading_1_color or "#AFA"
    md2f.settings.heading_2_color = settings.heading_2_color or "#FAA"
    md2f.settings.heading_3_color = settings.heading_3_color or "#AAF"
    md2f.settings.heading_4_color = settings.heading_4_color or "#FFA"
    md2f.settings.heading_5_color = settings.heading_5_color or "#AFF"
    md2f.settings.heading_6_color = settings.heading_6_color or "#FAF"
    md2f.settings.heading_1_size = settings.heading_1_size or "26"
    md2f.settings.heading_2_size = settings.heading_2_size or "24"
    md2f.settings.heading_3_size = settings.heading_3_size or "22"
    md2f.settings.heading_4_size = settings.heading_4_size or "20"
    md2f.settings.heading_5_size = settings.heading_5_size or "18"
    md2f.settings.heading_6_size = settings.heading_6_size or "16"
    md2f.settings.code_block_mono_color = settings.code_block_mono_color or "#6F6"
    md2f.settings.code_block_font_size = settings.code_block_font_size or 14
    md2f.settings.mono_color = settings.mono_color or "#6F6"
    md2f.settings.block_quote_color = settings.block_quote_color or "#FFA"
    md2f.settings.tab_size = settings.tab_size or 1

    --execute read-write of provided text
    return handleNesting(formspec_parse(escape(text)))
end

return parse