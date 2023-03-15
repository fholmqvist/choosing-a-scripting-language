---@diagnostic disable: lowercase-global
local lfs = require 'lfs'
local json = require 'cjson'
local http_request = require 'http.request'

local files_path = './files'

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

local function find_new_files(local_files, server_files)
  local new_files = {}

  for folder_name, folder in pairs(local_files) do
    if server_files[folder_name] == nil then
      new_files[folder_name] = folder
    else
      for _, file in pairs(folder) do
        local found = false
        for _, server_file in pairs(server_files[folder_name]) do
          if server_file == file then found = true end
        end

        if not found then
          if not new_files[folder_name] then
            new_files[folder_name] = {}
          end
          table.insert(new_files[folder_name], file)
        end
      end
    end
  end

  return new_files
end

------------------------------------------------
-------- PROGRAM -------------------------------
------------------------------------------------

load_files(files_path)

local headers, stream = assert(http_request.new_from_uri('http://localhost:8080'):go())

assert(headers:get(':status') == '200')

local body = assert(stream:get_body_as_string())
local server_files = assert(json.decode(body))

local new_files = find_new_files(files, server_files)

assert(#get_keys(new_files) == 1)
