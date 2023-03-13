import std/json, std/marshal, std/rdstdin, std/tables, strutils

type CD = object
    artist: string
    title: string
    rating: int
    ripped: bool

type DB = object
    cds: seq[CD]

type Selector = proc(k: string, v: string): bool

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

proc make_cd(title: string, artist: string, rating: int, ripped: bool): CD =
    CD(title: title, artist: artist, rating: rating, ripped: ripped)

proc add_record(cd: CD) =
    db.cds.insert(cd)

proc prompt_read(prompt: string): string =
    readLineFromStdin(@[prompt, ": "].join())
    
proc prompt_for_cd(): CD =
    make_cd(prompt_read("Title"), 
        prompt_read("Artist"),
        parseInt(prompt_read("Rating")),
        y_or_n_p(prompt_read("Ripped [y/n]")))

proc add_cds(): DB =
    while true:
        add_record(prompt_for_cd())
        if not y_or_n_p(prompt_read("Another? [y/n]")):
            break
    db
    
#------------------------------------------------
#------- DATABASE -------------------------------
#------------------------------------------------

proc save_db() =
    writeFile(filename, $$db.cds)

proc load_db() =
    db.cds = to(parseJson readFile filename, seq[CD])

proc print(db: DB) =
    for cd in db.cds:
        echo cd

proc select(selector: Selector): seq[CD] =
    var res: seq[CD] = @[]
    for cd in db.cds:
        for k, v in cd.fieldPairs:
            when v is string:
                if selector(k, v):
                    res.insert(cd)
    res

proc match_predicate(functions: var seq[Selector], 
    predicates: Table[string, string], key: string) =
    if predicates.hasKey(key):
        functions.insert(proc(k: string, v: string): bool =
            k == key and v == predicates[key])

proc where(predicates: Table[string, string]): 
    Selector =
    var fns: seq[Selector] = @[]

    match_predicate(fns, predicates, "title")
    match_predicate(fns, predicates, "artist")
    match_predicate(fns, predicates, "rating")
    match_predicate(fns, predicates, "ripped")

    return proc(k: string, v: string): bool =
        for f in fns:
            if f(k,v):
                return true
        false

# Won't be able to (elegantly) write update
# as tables are typed to single K, V types.

#------------------------------------------------
#------- PROGRAM --------------------------------
#------------------------------------------------

load_db()

echo select(where({"artist": "Stevie Wonder"}.toTable))
