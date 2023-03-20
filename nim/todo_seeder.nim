import random, strutils, strformat, nimSHA2, db_postgres, times

randomize()

let
    lines = readFile("../words_alpha.txt").split("\n")
    length = lines.len()

proc random_word(): string =
    return lines[rand(length-1)]

proc gen_name(): string =
    return random_word()

proc gen_email(name: string): string =
    return fmt"{name}@mail.com"

proc gen_password(): string =
    return computeSHA256(random_word()).toHex

proc gen_title(): string =
    return fmt"{random_word()}{random_word()}"

proc gen_description(): string =
    return fmt"{random_word()}{random_word()}{random_word()}"

let db = open("localhost", "postgres", "postgres", "todo")

echo "Starting.\n"

echo "Truncating todos."
db.exec(sql"truncate todos restart identity")

echo "Truncating users."
db.exec(sql"truncate users restart identity cascade")

proc insert_quadratic() =
    echo "Inserting quadratically.\n"

    let start_time = now()

    for user_id in countup(1, 100):
        let
            name = gen_name()
            email = gen_email(name)
            password = gen_password()

        db.exec(sql"insert into users (name, email, password) values (?, ?, ?)",
            name, email, password)

        for _ in countup(1, 100):
            let
                title = gen_title()
                description = gen_description()
                done = rand(2) == 1

            db.exec(sql"insert into todos (user_id, title, description, done) values (?, ?, ?, ?)",
                user_id, title, description, done)

        echo fmt"Inserted 100 todos for user {user_id}."

    echo "\nDone."

    let end_time = now()

    echo fmt"Took: {end_time-start_time}."

proc insert_linear() =
    echo "Inserting quadratically.\n"

    let start_time = now()

    for user_id in countup(1, 100):
        let
            name = gen_name()
            email = gen_email(name)
            password = gen_password()

        db.exec(sql"insert into users (name, email, password) values (?, ?, ?)",
            name, email, password)

        var query = "insert into todos (user_id, title, description, done) values "

        for _ in countup(1, 100):
            let
                title = gen_title()
                description = gen_description()
                done = rand(2) == 1

            query = query & fmt"({user_id}, '{title}', '{description}', '{done}'), "

        query = query.substr(0, query.len()-3)

        db.exec(sql(query))
        echo fmt"Inserted 100 todos for user {user_id}."

    echo "\nDone."

    let end_time = now()

    echo fmt"Took: {end_time-start_time}."

insert_linear()
