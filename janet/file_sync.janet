(import spork/json)
(import spork/http)

(var files @{})
(def path "./files")

(defn get-keys [t]
  (var keys @[])
  (loop [[k _] :pairs t]
    (array/push keys k))
  keys)

# TODO: Not recursing into nested folders.
(defn load-files (path)
  (loop [dir :in (os/dir path)]
    (def full-path (string/join @[path "/" dir "/"] ""))
    
    (loop [file :in (os/dir full-path)]
      (def name (string/replace ".zip" "" file))
      (def count (string/find "_" file))
      
      (when (and (not (nil? count)) 
                 (> count 0))
        (when (not (files dir))
          (set (files dir) @[]))
        (array/push (files dir) file)))))

(defn find-new-files [local-files server-files]
  (var new-files @{})

  (loop [[folder-name folder] :pairs local-files]
    (when (nil? (server-files folder-name))
      (set (new-files folder-name) folder))
    
    (loop [[_ file] :pairs folder]
      (var found false)
      
      (loop [[_ server-file] :pairs (server-files folder-name)]
        (when (= server-file file)
          (set found true)))
      
      (when (not found)
        (when (not (new-files folder-name))
          (set (new-files folder-name) @[]))
        (array/push (new-files folder-name) file))))
  
  new-files)

#-----------------------------------------------
#-------- PROGRAM ------------------------------
#-----------------------------------------------

(load-files path)

(def response (http/request "GET" "http://localhost:8080"))

(assert (= (get response :status) 200))

(def server-files (json/decode (get response :body)))

(def new-files (find-new-files files server-files))

(assert (= 1 (length (get-keys new-files))))
