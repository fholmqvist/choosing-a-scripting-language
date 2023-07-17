# Choosing a scripting language

I've never had a scripting language for short, one-off projects. Time to change that.
Only problem is, there's so many options, which one do you pick?

Let's write some problems in the ones that look interesting and compare notes.

| Language | Implementation | Status                  |
| -------- | -------------- | ----------------------- |
| Lua      | PCL DB         | Done                    |
| Lua      | File Sync      | Done                    |
| Lua      | Todo Seeder    | Done                    |
| Lua      | Todo Server    | Done                    |
| Fennel   | PCL DB         | Done                    |
| Fennel   | File Sync      | Blocked on 1.3.0 bug    |
| Janet    | PCL DB         | Done                    |
| Janet    | File Sync      | Done                    |
| Nim      | PCL DB         | Blocked on typed tables |
| Nim      | File Sync      | Done                    |
| Nim      | Todo Seeder    | Done                    |
| Go       | File Sync      | Done                    |
| Crystal  | File Sync      | Done                    |

```
PCL DB = Practical Common Lisp Chapter 3: Practical: A Simple Database.

File Sync = Reads files in folders, compares them against files on a server, displays the diff.

Todo Seeder = Seeds a PSQL database with users and todos.
```
