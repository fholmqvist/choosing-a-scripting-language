(import json)

(var db @[])
(def filename "my-cds.json")

#------------------------------------------------
#-------- HELPERS -------------------------------
#------------------------------------------------

(defn y-or-n-p [input]
  (= (string/ascii-lower) "y"))

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

#------------------------------------------------
#-------- PROGRAM -------------------------------
#------------------------------------------------

(load-db)
(pp db)
