(import spork/json)

(var db @[])
(def filename "my-cds.json")

#------------------------------------------------
#-------- HELPERS -------------------------------
#------------------------------------------------

(defn y-or-n-p [input]
  (= (string/ascii-lower input) "y"))

#------------------------------------------------
#-------- DOMAIN --------------------------------
#------------------------------------------------

(defn make-cd [title artist rating ripped]
  @{:title  title
    :artist artist
    :rating rating
    :ripped ripped})

(defn add-record [cd]
  (array/push db cd))

(defn prompt-read [prompt]
  (do
    (prin (string prompt ": "))
    (string/trim (file/read stdin :line))))

(defn prompt-for-cd []
  (make-cd (prompt-read "Title")
           (prompt-read "Artist")
           (scan-number (prompt-read "Rating"))
           (y-or-n-p (prompt-read "Ripped [y/n]"))))

(defn add-cds []
  (var done? false)
  (while (not done?)
    (add-record (prompt-for-cd))
      (set done? (y-or-n-p (prompt-read "Another? [y/n]")))))

#------------------------------------------------
#-------- DATABASE ------------------------------
#------------------------------------------------

(defn load-db []
  (->> (slurp filename)
       json/decode
       (set db)))

(defn save-db []
  (-> (file/open filename)
      (file/write (json/encode db)
      (file/flush)
      (file/close))))

(defn select [selector]
  (var res @[])
  (loop [row :in db]
    (loop [[k v] :pairs row]
      (when (selector k v) (array/push res row))))
  res)

(defn match-predicate [functions predicates key]
  (when (get predicates key)
    (array/push functions
      (fn [k v]
        (and (= k key)
             (= v (get predicates key)))))))

(defn where [predicates]
  (var fns @[])
  (match-predicate fns predicates "title")
  (match-predicate fns predicates "artist")
  (match-predicate fns predicates "rating")
  (match-predicate fns predicates "ripped")
  (fn [k v] (all (fn [p] (p k v)) fns)))

(defn update [selector key value]
  (var res @[])
  (for i 0 (- (length db) 1)
    (let [row (get db i)]
      (loop [[k v] :pairs (get db i)]
        (when ((where selector) k v)
          (set (row key) value)
          (array/push res row)))))
  res)

#------------------------------------------------
#-------- PROGRAM -------------------------------
#------------------------------------------------

(load-db)

(if (= (length db) 0)
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
    (prin "\nLoading...")
    (load-db)
    (print " done.")))

(print "\n========== CDS ==========")

(while true
  (prin "\n> ")
  (var input (file/read stdin :line))
  (pp (eval-string input)))
