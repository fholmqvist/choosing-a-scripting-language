(import spork/json)
(import spork/http)

(var files @{})
(def path "../testing")

#------------------------------------------------
#------- HELPERS --------------------------------
#------------------------------------------------

(defn get-all-files [t]
  (var keys @[])
  (loop [[_ folder] :pairs t
         [_ file] :pairs folder]
      (array/push keys file))
  keys)

#------------------------------------------------
#------- DOMAIN ---------------------------------
#------------------------------------------------

(defn load-files (path)
  (loop [dir :in (os/dir path)]
    (def full-path (string/join @[path "/" dir "/"] ""))

    (when-let [stat (os/stat full-path)
               mode (stat :mode)
               _    (= mode :directory)]
      (loop [file :in (os/dir full-path)
             :let [name (string/replace ".zip" "" file)
                   count (string/find "_" file)]
             :when (and (not (nil? count))
                             (> count 0))]

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
      
      (when-let [server-folder (server-files folder-name)]
        (loop [[_ server-file] :pairs server-folder]
          (when (= server-file file)
            (set found true)))
        
        (when (not found)
          (when (not (new-files folder-name))
            (set (new-files folder-name) @[]))
          (array/push (new-files folder-name) file)))))
  
  new-files)

#-----------------------------------------------
#-------- PROGRAM ------------------------------
#-----------------------------------------------

(load-files path)

(def response (http/request "GET" "http://localhost:8080"))

(assert (= (get response :status) 200))

(def server-files (json/decode (get response :body)))

(def new-files (find-new-files files server-files))

(assert (= 3507 (length (get-all-files new-files))))
