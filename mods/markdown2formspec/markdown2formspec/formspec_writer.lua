-- (c) 2022 Dallas DeBruin. Released under MIT license.
-- See the file LICENSE in the source for details.

--- Formspec Hypetext writer for Minetest
-- It extends [lunamark.writer.generic]

local M = {}

local generic = dofile(md2f.mp .. "/lunamark/writer/generic.lua")
local util = dofile(md2f.mp .. "/lunamark/util.lua")
local nbsp = string.format("%s","\160")

--- Returns a new Hypertext writer.
-- For a list of fields, see [lunamark.writer.generic].
function M.new(options)
  options = options or {}
  local Hyper = generic.new(options)

  local escape = util.escaper {
    ["<"] = "\\\\<",
    [";"] = "\\;",
    ["]"] = "\\]",
  }

  Hyper.interblocksep = "\n"

  Hyper.string = escape
  Hyper.citation = escape
  Hyper.verbatim = function(s)
    local _, count = string.gsub(s, "\n", "")
    minetest.log("verbose", "TABSIZE = " .. md2f.settings.tab_size .. ":: NBSP: " .. nbsp)
    local tab = string.rep(nbsp, md2f.settings.tab_size)
    return table.concat({"<mono><style color=",md2f.settings.code_block_mono_color," size=",md2f.settings.code_block_font_size,">",
                          tab,escape(s):gsub("\n","\n" .. tab,count-1),
                        "</style></mono>"})
  end
  function Hyper.code(s)
    minetest.log("verbose","code")
    return {"<mono><style color=",md2f.settings.mono_color,">",escape(s),"</style></mono>"}
  end

  function Hyper.fenced_code(s)
    minetest.log("verbose","fenced_code")
    return Hyper.verbatim(s)
  end
  
  function Hyper.start_document()
    return {"<global background=",md2f.settings.background_color," color=",md2f.settings.font_color,">",Hyper.linebreak}
  end

  function Hyper.emphasis(s)
    minetest.log("verbose","emphasis")
    return {"<i>",s,"</i>"}
  end

  function Hyper.strong(s)
    minetest.log("verbose","strong")
    return  {"<b>",s,"</b>"}
  end

  function Hyper.strong_emphasis(s)
    minetest.log("verbose","strong emphasis")
    return {"<b><i>",s,"</b></i>"}
  end

  function Hyper.header(s,level)
    if level == 0 then
      return s
    end
    return {"<style size=",md2f.settings[table.concat({"heading_",level,"_size"})]," color=",md2f.settings[table.concat({"heading_",level,"_color"})],">",s,"</style>"}
  end

  function Hyper.blockquote(s)
    minetest.log("verbose","blockquote")
    --tab over
    local tab = string.rep(nbsp, md2f.settings.tab_size)
    table.insert(s[1],1,tab)
    for i=2,#s,1 do
      if s[i] == "\n" then
        s[i] = "\n" .. tab
      end
    end

    return {"<style color=",md2f.settings.block_quote_color,">", s, "</style>"}
  end

  local function listitem(s)
    return {table.concat({nbsp,"•",nbsp}), s}
  end

  function Hyper.bulletlist(items,tight)
    minetest.log("verbose","bulletlist")
    for i,str in ipairs(items) do
        table.insert(str, 1, table.concat({nbsp,"•",nbsp}))
    end
    -- 003 and 004 designate start and end of lists, for post-processing nested lists
    return {"\003\n",util.intersperse(items,Hyper.linebreak),"\n\004"} 
  end

  function Hyper.orderedlist(items,tight)
    minetest.log("verbose","orderedlist")
    for i,str in ipairs(items) do
      table.insert(str, 1, table.concat({i,".",nbsp}))
    end
    return util.intersperse(items,Hyper.linebreak)
  end

  function Hyper.link(label, uri, title)
    minetest.log("verbose","link")
    return {"<u>",label,"</u>", " (<style color=",md2f.settings.link_color,">" , uri, "</style>) "}
  end

  function Hyper.image(label, src, title)
    minetest.log("verbose","image")
    --parse the minetest data from the filename:
    local _,_,w,h,float = label[1]:find("(%d*),?(%d*),?([lr]*)")
    local _,_,filename = src:find("([%w%p]*)")
    local image = table.concat({"<img name=",filename})
    if filename:find("item:///.*") then
        image = table.concat({"<item name=",string.sub(filename,9,-1)})
    end
    if float == "l" then
      image = table.concat({image," float=left"})
    elseif float == "r" then
      image = table.concat({image," float=right"})
    end
    if w ~= "" and h ~= "" then
      image = table.concat({image," width=",w," height=",h,">"})
    else
      image = table.concat({image,">"})
    end
    return {"<global halign=center>",Hyper.linebreak,image,"<global halign=left>",Hyper.linebreak}
  end

  Hyper.hrule = function() return table.concat({"<img name=md2f_line.png width=",45*md2f.settings.width," height=4>"}) end

  return Hyper
end

return M
