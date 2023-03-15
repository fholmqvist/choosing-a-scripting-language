(local fennel (require "fennel"))
(local json (require "json"))

;; Bug in Fennel 1.3.0: Dynamic loading of C deps.

(local files-path "./files")
(var files {})

;------------------------------------------------
;-------- HELPERS -------------------------------
;------------------------------------------------

(fn pp [x] (print (fennel.view x)))

;------------------------------------------------
;-------- PRETEND LFS ---------------------------
;------------------------------------------------

(fn lfs-dir [path]
  {:.         :ignore 
   :..        :ignore 
   "a"        :ignore
   "b"        :ignore
   "a_01.zip" :ignore
   "a_02.zip" :ignore
   "b_01.zip" :ignore})

(fn is-directory [path]
  (= "a" "b" path))

;------------------------------------------------
;-------- DOMAIN ---- ---------------------------
;------------------------------------------------

(fn get-keys [t]
  (var keys {})
  (each [key _ (pairs t)]
    (table.insert keys key))
  keys)

(fn load-files [path]
  (when (not (= path nil))
    (each [file (pairs (lfs-dir path))]
      (when (and (not (= "."  file)) 
                 (not (= ".." file)))
        (local relative-path (.. path "/" file))
        
        (when (is-directory relative-path)
          (load-files nil))
          
        (local (name count) (string.gsub file ".zip" ""))
        (when (= count 1)
          (local idx (string.find name "_"))
          
          (when (not (= idx nil))
            (local key (string.sub name 0 (- idx 1)))
            (local dir-name (string.sub path (+ (string.find path "/[^/]*$") 1)))
            
            ;; Skipping dir-name comparison as it makes no
            ;; sense without real directories.
            (when (and (not (= key nil))) ;(= key dir-name))
              (when (= (. files key) nil)
                (tset files key {}))
              (table.insert (. files key) file))))))))

;; Can't load http.request. Abandoning for now.

;------------------------------------------------
;-------- PROGRAM -------------------------------
;------------------------------------------------

(load-files "a/")
(pp files)
