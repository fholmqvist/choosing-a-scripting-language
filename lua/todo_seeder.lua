math.randomseed(os.time())

local sha = require('sha2')
local pg = require('pgmoon')

local lines = {}
for line in io.lines('../words_alpha.txt') do
  lines[#lines + 1] = line
end

local length = #lines

local function random_word()
  return lines[math.random(length)]
end

local function gen_name()
  return random_word()
end

local function gen_email(name)
  return name .. '@mail.com'
end

local function gen_password()
  return sha.sha256(random_word())
end

local function gen_title()
  return string.format('%s %s', random_word(), random_word())
end

local function gen_description()
  return string.format('%s %s %s', random_word(), random_word(), random_word(), random_word())
end

local db = pg.new({
  host = "127.0.0.1",
  port = "5432",
  user = "postgres",
  password = "postgres",
  database = "todo"
})

assert(db:connect())

print('Starting.\n')

print('Truncating todos.')
assert(db:query('truncate todos'))

print('Truncating users.')
assert(db:query('truncate users cascade'))

local function insert_quadratic()
  print('Inserting quadratically.\n')

  local start_time = os.time()

  for user_id = 1, 100 do
    local name = gen_name()
    local email = gen_email(name)
    local password = gen_password()

    assert(db:query('insert into users (name, email, password) values($1, $2, $3)',
      name, email, password))

    for _ = 1, 100 do
      local title = gen_title()
      local description = gen_description()
      local done = math.random(1, 2) == 1

      assert(db:query('insert into todos (user_id, title, description, done) values ($1, $2, $3, $4)',
        user_id, title, description, done))
    end

    print(string.format('Inserted 100 todos for user %s.', user_id))
  end

  print('\nDone.')

  local end_time = os.time()

  print(string.format('Took: %ss.', os.difftime(end_time, start_time)))
end

local function insert_linear()
  print('Inserting linearly.\n')

  local start_time = os.time()

  for user_id = 1, 100 do
    local name = gen_name()
    local email = gen_email(name)
    local password = gen_password()

    assert(db:query('insert into users (name, email, password) values($1, $2, $3)',
      name, email, password))

    local query = 'insert into todos (user_id, title, description, done) values '

    for _ = 1, 100 do
      local title = gen_title()
      local description = gen_description()
      local done = math.random(1, 2) == 1

      query = query .. string.format('(%s, \'%s\', \'%s\', %s),', user_id, title, description, done)
    end

    query = query:sub(0, -2)

    assert(db:query(query))

    print(string.format('Inserted 100 todos for user %s.', user_id))
  end

  print('\nDone.')

  local end_time = os.time()

  print(string.format('Took: %ss.', os.difftime(end_time, start_time)))
end

insert_linear()
