---@diagnostic disable: deprecated, lowercase-global
local json = require 'cjson'

db = {}
filename = 'my-cds.json'

-------------------------------------------------
-------- HELPERS --------------------------------
-------------------------------------------------

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

local function any(k, v, fs)
  for _, f in pairs(fs) do
    if f(k, v) then
      return true
    end
  end

  return false
end

local function y_or_n_p(input)
  return string.lower(input) == 'y'
end

-------------------------------------------------
-------- DOMAIN ---------------------------------
-------------------------------------------------

local function make_cd(title, artist, rating, ripped)
  return {
    title = title,
    artist = artist,
    rating = rating,
    ripped = ripped
  }
end

local function add_record(cd)
  table.insert(db, cd)
  return db
end

local function prompt_read(prompt)
  io.write(prompt .. ': ')
  return io.read()
end

local function prompt_for_cd()
  return make_cd(
    prompt_read('Title'),
    prompt_read('Artist'),
    tonumber(prompt_read('Rating')) or 0,
    y_or_n_p(prompt_read('Ripped [y/n]'))
  )
end

function add_cds()
  while true do
    add_record(prompt_for_cd())
    if not y_or_n_p(prompt_read('Another? [y/n]')) then
      break
    end
  end

  return db
end

-------------------------------------------------
-------- DATABASE -------------------------------
-------------------------------------------------

function save_db()
  local file = io.open(filename, 'w')
  if file == nil then
    print('Could not open file: ', filename)
    return
  end

  file:write(json.encode(db))
  file:close()

  return 'ok'
end

function load_db()
  local file = io.open(filename, 'r')
  if file == nil then
    print('Could not open file: ', filename)
    return
  end

  for data in file:lines('a') do
    db = json.decode(data)
  end

  file:close()

  return 'ok'
end

function select(selector)
  local res = {}
  for _, t in pairs(db) do
    for k, v in pairs(t) do
      if selector(k, v) then
        table.insert(res, t)
      end
    end
  end

  pp(res)
end

local function match_predicate(functions, predicates, key)
  if predicates[key] then
    table.insert(functions, function(k, v)
      return k == key and v == predicates[key]
    end)
  end
end

function where(predicates)
  local fns = {}

  match_predicate(fns, predicates, 'title')
  match_predicate(fns, predicates, 'artist')
  match_predicate(fns, predicates, 'rating')
  match_predicate(fns, predicates, 'ripped')

  return function(k, v)
    return any(k, v, fns)
  end
end

function update(selector, key, value)
  for i, t in pairs(db) do
    for k, v in pairs(t) do
      if where(selector)(k, v) then
        db[i][key] = value
        return db[i]
      end
    end
  end
end

-------------------------------------------------
-------- PROGRAM --------------------------------
-------------------------------------------------

load_db()

if #db == 0 then
  print('Adding dummy data...')
  add_record(make_cd('Songs in the Key of Life', 'Stevie Wonder', 10, false))
  add_record(make_cd("What's Going On", 'Marvin Gaye', 10, false))
  add_record(make_cd('I Never Loved a Man the Way I Love You', 'Aretha Franklin', 10, false))
  add_record(make_cd('Are You Experienced', 'Jimi Hendrix', 10, false))
  add_record(make_cd('Kind of Blue', 'Miles Davis', 10, false))
  add_record(make_cd("There's a Riot Goin' On", 'Sly and the Family Stone', 10, false))
  add_record(make_cd('Superfly', 'Curtis Mayfield', 10, false))
  add_record(make_cd('Exodus', 'Bob Marley and the Wailers', 10, false))
  add_record(make_cd('Star Time', 'James Brown', 10, false))
  save_db()
else
  io.write('\nLoading...')
  load_db()
  print(' done.')
end

print('\n========== CDS ==========')

while true do
  io.write('\n> ')
  local input = io.read()
  pp(loadstring(input)())
end
