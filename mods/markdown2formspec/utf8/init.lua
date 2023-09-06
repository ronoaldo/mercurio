local module_path = md2f.mp .. "/utf8/"

local ffi_enabled, ffi = pcall(require, 'ffi')

local utf8 = {
  config = {},
  default = {
    debug = nil,
    logger = io.write,
    loadstring = (loadstring or load),
    unpack = (unpack or table.unpack),
    cache = {
      regex = setmetatable({},{
        __mode = 'kv'
      }),
      plain = setmetatable({},{
        __mode = 'kv'
      }),
    },
    locale = nil,
    int32array = function(size)
      if ffi_enabled then
        return ffi.new("uint32_t[?]", size + 1)
      else
        return {}
      end
    end,
    conversion = {
      uc_lc = nil,
      lc_uc = nil
    }
  },
  regex = {
    compiletime = {
      charclass = {},
      begins = {},
      ends = {},
      modifier = {},
    }
  },
  util = {},
}

function utf8:require(name)
  name = string.gsub(name, "%.", "/")
  local full_module_path = module_path .. name .. ".lua"
  return dofile(full_module_path)
end

function utf8:init()
  for k, v in pairs(self.default) do
    self.config[k] = self.config[k] or v
  end

  self:require "util"
  self:require "primitives.init"
  self:require "functions.lua53"

  return self
end

return utf8
