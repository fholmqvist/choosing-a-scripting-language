(local fennel (require "fennel"))
(local json (require "json"))

;; Bug in Fennel 1.3.0: Dynamic loading of C deps.

(local files-path "./files")
(local files {})

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
   "a_01.zip" :ignore
   "a_02.zip" :ignore
   "b_01.zip" :ignore})

(fn is-directory [path]
  (= "a" "b" path))

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
        (print file name count)))))

(load-files files-path)
