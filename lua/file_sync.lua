---@diagnostic disable: lowercase-global
local lfs = require 'lfs'
local json = require 'cjson'
local http_request = require 'http.request'

local path = './files'

local files = {}

function pp(t)
  if type(t) == 'table' then
    for k, v in pairs(t) do
      if type(v) == 'table' then
        print(k)
        pp(v)
      else
        print(string.upper(k) .. ':\t' .. tostring(v))
      end
    end
  else
    print(t)
  end
end

local function get_keys(t)
  local keys = {}
  for key, _ in pairs(t) do
    table.insert(keys, key)
  end
  return keys
end

local function load_files(path)
  for file in lfs.dir(path) do
    if file ~= '.' and file ~= '..' then
      local relative_path = path .. '/' .. file

      if lfs.attributes(relative_path)['mode'] == 'directory' then
        load_files(relative_path)
      end

      local name, count = file:gsub('.zip', '')

      if count == 1 then
        local idx = name:find('_')

        if idx ~= nil then
          local key = name:sub(0, idx - 1)
          local dir_name = path:sub(path:find("/[^/]*$") + 1)

          if key ~= nil and key == dir_name then
            if files[key] == nil then
              files[key] = {}
            end

            table.insert(files[key], file)
          end
        end
      end
    end
  end
end

load_files(path)

-- TODO: Find old server / write dummy server.
-- local headers, stream = assert(http_request.new_from_uri('https://lua.org/'):go())

-- assert(headers:get(':status') == '200')

-- local body = assert(stream:get_body_as_string())
-- local server_files = assert(json.decode(body))

local server_files = { a = { "a_01.zip", }, b = { "b_01.zip" }, c = {} }

local new_files = {}
for folder_name, folder in pairs(files) do
  for file_name, file in pairs(folder) do
    if server_files[folder_name][file_name] == nil then
      if new_files[folder_name] == nil then
        new_files[folder_name] = folder
      end

      new_files[folder_name][file_name] = file
    end
  end
end

assert(#get_keys(new_files) == 1)
