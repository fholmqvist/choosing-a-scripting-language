(local fennel (require "fennel"))
(local json (require "json"))

(var db {})
(local filename "my-cds.json")

;------------------------------------------------
;-------- HELPERS -------------------------------
;------------------------------------------------

(fn pp [x] (print (fennel.view x)))

(fn y-or-n-p [input]
  (= (string.lower input) "y"))

(fn any [k v fs]
  (var res false)
  (each [_ f (pairs fs)]
    (when (f k v)
      (set res true)))
  res)

;------------------------------------------------
;-------- DOMAIN --------------------------------
;------------------------------------------------

(fn make-cd [title artist rating ripped]
  {:title  title
   :artist artist 
   :rating rating
   :ripped ripped})

(fn add-record [cd]
  (table.insert db cd))

(fn prompt-read [prompt]
  (do
    (io.write (.. prompt ": " ))
    (io.read)))

(fn prompt-for-cd []
  (make-cd (prompt-read "Title")
           (prompt-read "Artist")
           (prompt-read "Rating")
           (prompt-read "Ripped [y/n]")))

(fn add-cds []
  (var done? false)
  (while (not done?)
    (add-record (prompt-for-cd))
    (when (not (y-or-n-p (prompt-read "Another? [y/n]")))
      (set done? true))))

;------------------------------------------------
;-------- DATABASE ------------------------------
;------------------------------------------------

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

(fn select [selector]
  (local res {})
  (each [_ t (pairs db)]
    (each [k v (pairs t)]
      (when (selector k v)
        (table.insert res t))))
  res)

(fn match-predicate [functions predicates key]
  (when (. predicates key)
    (table.insert functions 
      (fn [k v]
        (and (= k key) 
             (= v (. predicates key)))))))

(fn where [predicates]
  (var fns {})
  (match-predicate fns predicates :title)
  (match-predicate fns predicates :artist)
  (match-predicate fns predicates :rating)
  (match-predicate fns predicates :ripped)
  (fn [k v] (any k v fns)))

(load-db)
(pp (select (where {:artist "Stevie Wonder"})))
