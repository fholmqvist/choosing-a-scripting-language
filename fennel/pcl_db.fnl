(local fennel (require "fennel"))
(local json (require "json"))

(var db {})
(local filename "my-cds.json")

(fn pp [x] (print (fennel.view x)))

(fn load-db []
  (pcall #(with-open [f (io.open filename :r)]
    (->> ((f:lines))
        json.decode
        (set db)))))

(fn save-db []
  (with-open [f (io.open filename :w)]
    (->> db
         json.encode
         (f:write))))

(load-db)
(save-db)
(pp db)
