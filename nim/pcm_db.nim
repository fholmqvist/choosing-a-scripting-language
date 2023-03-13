import std/json, std/marshal, strutils

type
    CD = object
        artist: string
        title: string
        rating: int
        ripped: bool

type
    DB = object
        cds: seq[CD]

const filename = "my-cds.json"

var db = DB()

#------------------------------------------------
#-------- HELPERS -------------------------------
#------------------------------------------------

proc y_or_n_p(input: string): bool =
    input.toLowerAscii == "y"

#------------------------------------------------
#------- DOMAIN ---------------------------------
#------------------------------------------------

#------------------------------------------------
#------- DATABASE -------------------------------
#------------------------------------------------

proc loadDB() =
    db.cds = to(parseJson readFile filename, seq[CD])

proc saveDB() =
    writeFile(filename, $$db.cds)

proc print(db: DB) =
    for cd in db.cds:
        echo cd

#------------------------------------------------
#------- PROGRAM --------------------------------
#------------------------------------------------

loadDB()

db.print
