local lapis = require('lapis')
local json_params = require('lapis.application').json_params
local db = require('lapis.db')
local app = lapis.Application()

app:get("/:user_id", function(self)
  return {
    json = db.query(
      'select * from todos where user_id = ?',
      self.params.user_id
    )
  }
end)

app:get("/:user_id/:todo_id", function(self)
  return {
    json = db.query(
      'select * from todos where user_id = ? and id = ?',
      self.params.user_id, self.params.todo_id
    )
  }
end)

app:post("/create", json_params(function(self)
  local todo = db.query(
    'insert into todos (user_id, title, description) values (?, ?, ?) returning *',
    self.params.user_id, self.params.title, self.params.description
  )

  return { status = 201, json = todo }
end))

app:put("/:user_id/:todo_id/toggle", function(self)
  local todo = db.query(
    'select * from todos where user_id = ? and id = ?',
    self.params.user_id, self.params.todo_id
  )

  db.query('update todos set done = ? where id = ?',
    not todo.done, self.params.todo_id)

  return { status = 200 }
end)

app:delete("/:user_id/:todo_id/delete", function(self)
  db.query('delete from todos where id = ?', self.params.id)
  return { status = 200 }
end)

return app
