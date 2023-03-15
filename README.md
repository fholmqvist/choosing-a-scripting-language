# Choosing a scripting language

I haven't picked a scripting for personal projects. Time to change that.  
Only problem is, there's so many options, which one do you pick?

Let's write some problems in the ones that look interesting and compare notes.

| Language | Implementation | Status                  |
| -------- | -------------- | ----------------------- |
| Lua      | PCL DB         | Done                    |
| Lua      | FileSync       | Done                    |
| Fennel   | PCL DB         | Done                    |
| Fennel   | FileSync       | Blocked on 1.3.0 bug    |
| Janet    | PCL DB         | Done                    |
| Janet    | FileSync       | Done                    |
| Nim      | PCL DB         | Blocked on typed tables |
| Go       | FileSync       | Done                    |

```
PCL DB = Practical Common Lisp Chapter 3: Practical: A Simple Database.

FileSync = Reads files in folders, compares them against files on a server, sends the diff.
```
