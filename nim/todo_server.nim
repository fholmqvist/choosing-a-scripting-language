import jester, db_postgres, json, strformat, strutils

let db = open("localhost", "postgres", "postgres", "todo")

# Dates are stringly typed as DateTime and
# Option[DateTime] aren't supported by std/json.
type Todo = object
    id: string
    user_id: string
    title: string
    description: string
    created_at: string
    done: bool
    finished_at: string

proc column_to_bool(s: string): bool =
    # input is always "f"?
    return if s == "t": true else: false

proc to_todo(row: Row): Todo =
    return Todo(
        id: row[0],
        user_id: row[1],
        title: row[2],
        description: row[3],
        created_at: row[4].substr(0, 18),
        done: row[5].column_to_bool(),
        finished_at: row[6].substr(0, 18))

proc statement_to_row(s: string): Row =
    return db.getRow(sql(s))

routes:
    get "/@user_id":
        let user_Id = "@user_id"
        let row = statement_to_row(fmt"select * from todos where user_id = {user_id}")
        echo row
        let todo = row.to_todo()
        resp $(%* todo), "application/json"
