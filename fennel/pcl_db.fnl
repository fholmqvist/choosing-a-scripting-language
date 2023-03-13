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
           (tonumber (prompt-read "Rating"))
           (y-or-n-p (prompt-read "Ripped [y/n]"))))

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

(fn update [selector key value]
  (var res {})
  (each [i t (pairs db)]
    (each [k v (pairs t)]
      (when ((where selector) k v)
        (let [inner (. db i)]
          (tset inner key value)
          (set res inner)))))
  res)

;------------------------------------------------
;-------- PROGRAM -------------------------------
;------------------------------------------------

(load-db)

(if (= #db 0)
  (do 
    (print "Adding dummy data...")
    (add-record (make-cd "Songs in the Key of Life" "Stevie Wonder" 10 false))
    (add-record (make-cd "What's Going On" "Marvin Gaye" 10 false))
    (add-record (make-cd "I Never Loved a Man the Way I Love You" "Aretha Franklin" 10 false))
    (add-record (make-cd "Are You Experienced" "Jimi Hendrix" 10 false))
    (add-record (make-cd "Kind of Blue" "Miles Davis" 10 false))
    (add-record (make-cd "There's a Riot Goin' On" "Sly and the Family Stone" 10 false))
    (add-record (make-cd "Superfly" "Curtis Mayfield" 10 false))
    (add-record (make-cd "Exodus" "Bob Marley and the Wailers" 10 false))
    (add-record (make-cd "Star Time" "James Brown" 10 false))
  (save-db))
  (do
    (io.write "\nLoading...")
    (load-db)
    (print " done.")))

(print "\n========== CDS ==========")

(while true
  (io.write "\n> ")
  (local input (io.read))
  (pp (fennel.eval input)))
