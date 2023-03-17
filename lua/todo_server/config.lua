local config = require("lapis.config")

config("development", {
  server = "nginx",
  code_cache = "off",
  num_workers = "1",
  postgres = {
    host = "127.0.0.1",
    user = "postgres",
    password = "postgres",
    database = "todo"
  }
})
