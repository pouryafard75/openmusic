(in-package :om)(in-package :oa)(export '(om-get-current-port ) :om-api)(defun om-get-current-port ()   *curstream*)(in-package :om);=============================================;BREAK PAGES AND CONS PICTURES FOR EACH ONE;=============================================(defmethod make-pages-form-obj ((score scorePanel) (self t)  x top linespace mode scale sel system stem)  (let* ((graph-obj (make-graph-form-obj (objectfromeditor score) 0                                             120 linespace                                              (staff-mode score)                                             (get-approx-scale score)                                             (selection? score) (staff-sys score) (show-stems score)))         (size (staff-size score)))    (set-graph-rectangles graph-obj)    (cons-score-pages-list score self graph-obj (list! system) (* linespace 4))    (make-score-pages-picts  score self graph-obj (+ x (round (* size (score-left-margin score))))                              (round (* size (score-top-margin score))) (staff-zoom score) (slots-mode score)                              size  system (noteaschan? score))    graph-obj))(defmethod make-pages-form-obj ((score voicePanel) self  x top linespace mode scale sel system stem) (let* ((graph-obj (make-graph-form-obj (objectfromeditor score) 0                                        120 linespace                                         (staff-mode score)                                        (get-approx-scale score)                                        (selection? score) system (show-stems score)))        (size (staff-size score))        (deltax (get-key-space score))        (deltay (round (* size (score-top-margin score)))))   (space-objects graph-obj (* 4 linespace))   (set-graph-rectangles graph-obj)   (cons-the-bpf-time score graph-obj)   (om-with-focused-view score     (om-with-clip-rect score (om-make-rect 0 0 1 1)     (om-with-font  (get-font-to-draw 0)                   (draw-object graph-obj score deltax                                 (- deltay (round (* (posy (car (staff-list  system))) (/ size 4))))                                (staff-zoom score) 0 10000000 0 10000000                                 (slots-mode score) size t                                 system nil (noteaschan? score)))))   (cons-score-pages-list score self graph-obj system (* linespace 4))   (make-score-pages-picts  score self graph-obj (+ x (round (* size (score-left-margin score))))                             (round (* (* linespace 4) (score-top-margin score))) (staff-zoom score) (slots-mode score)                             (* linespace 4)  system nil)   graph-obj))(defmethod make-pages-form-obj ((score polyPanel) (self t)  x top linespace mode scale sel system stem) (let* ((graph-obj (make-graph-form-obj (objectfromeditor score) 0                                        120 linespace                                         (staff-mode score)                                        (get-approx-scale score)                                        (selection? score) system (show-stems score)))        (size (staff-size score))        (*internal-score-fonts* (init-fonts-to-draw size))        (deltax (get-key-space score))        (deltay (round (* size (score-top-margin score)))))   (space-objects graph-obj (* 4 linespace))   (set-graph-rectangles graph-obj)   (cons-the-bpf-time score graph-obj)   (om-with-focused-view score        (om-with-clip-rect score (om-make-rect 0 0 1 1)        (om-with-font (get-font-to-draw 0)                   (draw-object graph-obj score deltax                                 (- deltay (round (* (posy (car (staff-list  (car system)))) (/ size 4))))                                (staff-zoom score) 0 10000000 0 10000000                                 (slots-mode score) size t                                 system nil (noteaschan? score)))))   (cons-score-pages-list score self graph-obj system (* linespace 4))   (make-score-pages-picts  score self graph-obj (+ x (round (* size (score-left-margin score))))                             (round (* (* linespace 4) (score-top-margin score))) (staff-zoom score) (slots-mode score)                             (* linespace 4)  system nil)   graph-obj));================================================================;BREAK PAGE;================================================================(defmethod collect-objects-to-break ((self grap-container) n)  (loop for item in (inside self)        append (collect-objects-to-break item n)))(defmethod collect-objects-to-break ((self grap-rest) n)   (list (list n self (rectangle self))))(defmethod collect-objects-to-break ((self grap-group) n)   (list (list n self (rectangle self))))(defmethod collect-objects-to-break ((self grap-chord) n)   (list (list n self (rectangle self))));------------------(defmethod collect-onsets-to-break ((self grap-container) n father)  (loop for item in (inside self)        append (collect-onsets-to-break item n father)))(defmethod collect-onsets-to-break ((self grap-rest) n father)   (list (list n (car (rectangle self)) (main-point self) (offset->ms (reference self) father))))(defmethod collect-onsets-to-break ((self grap-group) n father)   (list (list n (car (rectangle self)) (main-point self) (offset->ms (reference self) father))))(defmethod collect-onsets-to-break ((self grap-chord) n father)   (list (list n (car (rectangle self)) (main-point self) (offset->ms (reference self) father))));------------(defmethod score-get-onsets-to-break ((self notepanel) grapobj)   (list (list 0 (car (rectangle grapobj)) (main-point grapobj) 0)))(defmethod score-get-onsets-to-break ((self chordpanel) grapobj)  (loop for item in (inside grapobj)        for time = 0 then (+ time 500)        append (list (list 0 (car (rectangle item)) (main-point item) time))))(defmethod score-get-onsets-to-break ((self chordseqpanel) grapobj)  (loop for item in (inside grapobj)        append (list (list 0 (car (rectangle item)) (main-point item) (offset->ms (reference item) (reference grapobj))))))(defmethod score-get-onsets-to-break ((self multiseqPanel) grapobj)  (loop for item in (inside grapobj)        for i = 0 then (+ i 1)         append (collect-onsets-to-break item i (reference grapobj))))(defmethod score-get-onsets-to-break ((self voicepanel) grapobj)  (loop for item in (inside grapobj)        append (list (list 0 (- (third (rectangle item)) (car (rectangle item))) (main-point item) (offset->ms (reference item))))))(defmethod score-num-voices ((self scorepanel) ) 1)(defmethod score-num-voices ((self multiseqpanel) )   (length (inside (object (editor self)))))(defun make-pages-from-lines-for-linear-print (list)      (let* ((rep (flat list)))        (loop for item in rep collect (list item))))(defun make-pages-from-lines (list hpage line size score)  (let* ((linesize (get-delta-line line size score ))         (mod (max 1 (floor hpage linesize)))         (rep (multiple-value-list (floor (length list) mod))))    (if (zerop (second rep))      (make-list (car rep) :initial-element (make-list mod :initial-element linesize))    (append (make-list (car rep) :initial-element (make-list mod :initial-element linesize))             (list (make-list (second rep) :initial-element linesize) )))))(defun compute-line-info (list n)  (loop for i from 0 to (- n 1)        collect (count i list :key 'car)));=============================================================================;MAKE PAGE SEGMENTATION STORE THE INFORMATION IN (score-fdoc score);=============================================================================(defmethod cons-score-pages-list ((score scorePanel) (self t) graph-obj line size)  (let* ((onsets+voice (sort (score-get-onsets-to-break score graph-obj) '< :key 'second))         (onsets  (loop for item in onsets+voice collect (second item)))         (wpage (- (score-widht score size) (get-key-space score)))         (hpage (score-height score size))         (mixed-lines (cons-mixed-lines score onsets wpage))         (pages (make-pages-from-lines mixed-lines hpage line size score))         (pages (if *score-printing*                    (make-pages-from-lines-for-linear-print pages) pages))         (fdoc (make-instance 'fdoc))         (numvoices (score-num-voices score))         (linecount -1))   (loop for item in pages do          (let ((newpage (make-instance 'fpage)))            (loop for line in item do                  (let ((newline (make-instance 'fline)))                    (setf curline (nth (incf linecount) mixed-lines))                    (setf (line-info newline) (compute-line-info (first-n onsets+voice (length curline)) numvoices))                    (setf onsets+voice (nthcdr  (length curline) onsets+voice))                    (push newline (line-list newpage))))            (setf (line-list newpage) (reverse (line-list newpage)))            (push newpage (page-list fdoc))))    (setf (page-list fdoc) (reverse (page-list fdoc)))    (score-fdoc score fdoc)))(defmethod cons-mixed-lines ((score notePanel) list linesize)  (list list))(defmethod cons-mixed-lines ((score chordPanel) list linesize)  (setf list (om* list (* (staff-zoom score))))  (let ((i 1) rep rep1)    (loop for item in list do          (if (< item (* i linesize))            (push item rep1)            (progn (push (reverse rep1) rep)                   (setf rep1 nil)                   (push item rep1)                   (setf i (+ i 1)))))    (reverse (push (reverse rep1) rep))))(defmethod cons-mixed-lines ((score chordseqPanel) list linesize)  (setf list (om* list (* (staff-zoom score))))  (let ((i 1) rep rep1)    (loop for item in list do          (if (< item (* i linesize))            (push item rep1)            (progn (push (reverse rep1) rep)                   (setf rep1 nil)                   (push item rep1)                   (setf i (+ i 1)))))    (reverse (push (reverse rep1) rep))))(defmethod cons-mixed-lines ((score multiseqPanel) list linesize)  (setf list (om* list (* (staff-zoom score))))  (let ((i 1) rep rep1)    (loop for item in list do          (if (< item (* i linesize))            (push item rep1)            (progn (push (reverse rep1) rep)                   (setf rep1 nil)                   (push item rep1)                   (setf i (+ i 1)))))    (reverse (push (reverse rep1) rep))))       (defmethod cons-mixed-lines ((score voicePanel) list linesize)  (make-page-break list linesize));(defmethod cons-mixed-lines ((score voicePanel) list linesize);  (make-page-break (x->dx list) linesize));=============================================================================;DRAW PAGES IN A METAFILE;=============================================================================(in-package :om)(defmethod initial-y-position ((score scorePanel) staff size y)  (- y (round (*  (posy (car (staff-list staff)))  (/ size 4)))))(defmethod initial-y-position ((score multiseqpanel) staff size y) y)(defmethod page-tempo ((score scorePanel)) nil)(defmethod page-tempo ((score voicepanel)) (list (show-tempo score)))(defmethod page-tempo ((score polypanel))  (show-tempo score))(defmethod make-score-pages-picts ((score scorePanel) self  grapobj x y zoom  slot size  staff chnote)  (let* ((*internal-score-fonts* (init-fonts-to-draw size))         (newfont (get-font-to-draw 0))         (page-size (score-paper-size score))         (fdoc (score-fdoc score))         pict-pages)    (loop for pict in (score-picts-list score) do          (when pict (om-kill-picture pict)))    (loop for page from 0 to (- (howmany-pages fdoc) 1) do          (let ((newpage (om-record-pict newfont page-size                           (om-with-line-size 0.3                             (om-with-fg-color nil *om-white-color*                                (om-fill-rect 0 0 (om-point-h page-size) (om-point-v page-size))                               (draw-score-page (list! staff)  (howmany-lines fdoc page) score x y (score-widht score size) size (and (= page 0) (page-tempo score)) nil))                             (loop for line from 0 to (- (howmany-lines (score-fdoc score) page) 1) do                                   (draw-page-one-line grapobj score page line                                                        (+ x (get-key-space score)) (initial-y-position score staff size y)                                                       (- (score-widht  score size) (get-key-space score)) (get-delta-line staff size score )                                                       zoom  slot size  staff  chnote 0))))))            (push newpage pict-pages)))    (score-picts-list score (reverse pict-pages))));==================================================================================;DRAW ONE LINE;==================================================================================;-------tools;return les elements pour une page et une ligne donees(defmethod get-page-line-elements ((self grap-container) fdoc pagenum linenum numvoice)  (let ((rep (inside self))        (count 0) page start end)    (loop for i = 0 then (+ i 1)          while (< i pagenum) do          (let ((fpage (nth i (page-list fdoc))))            (loop for item in (line-list fpage) do                  (setf count (+ count (nth numvoice (line-info item)))))))    (setf page (nth pagenum (page-list fdoc)))    (loop for line in (line-list page)          for k = 0 then (+ k 1)          while (<= k linenum) do          (if (= k linenum)              (setf start count                    end (+ count (nth numvoice (line-info line))))            (setf count (+ count (nth numvoice (line-info line))))))    (subseq rep start end)));-------get the x and y position for a page and a line(defmethod compute-delta-x-y ((score scorePanel) pagenum linenum linesizex linesizey)  (let* ((fdoc (score-fdoc score))         (size (staff-size score))         (repx 0) (repy 0))    (loop for i from 0 to (- pagenum 1) do          (setf repx (+ repx (* linesizex (length (line-list  (nth i (page-list fdoc))))))))    (setf repx (+ repx (* linesizex linenum)))    (setf repy (* linesizey linenum))    (list repx repy)));=====DRAW NOTE(defmethod draw-page-one-line ((self grap-note) score pagenum linenum x y linesizex linesizey zoom  slot size  staff chnote numvoice)  (draw-object self (om-get-current-port) x y zoom nil nil nil nil slot size nil staff nil chnote));=====DRAW CHORD(defmethod draw-page-one-line ((self grap-chord) score pagenum linenum x y linesizex linesizey zoom  slot size  staff chnote numvoice)  (let* ((fdoc (score-fdoc score))         (elements (get-page-line-elements  self fdoc pagenum linenum 0)) )    (loop for item in elements do          (draw-prop-note item score pagenum linenum x y linesizex linesizey zoom  slot size staff chnote))    (when *om-tonalite*      (draw-chiffrage self x y zoom size))    (when (stem self)       (draw-stem  self  (round (+  x (/ size 3.5) (* zoom (x self)))) y (selected self) (stem self)))  ; (collect-rectangles self)    (draw-extras self (om-get-current-port) size staff)))(defmethod draw-prop-note ((self grap-note) score pagenum linenum x y linesizex linesizey zoom  slot size  staff  chnote)  (let ((deltaxy (compute-delta-x-y score pagenum linenum linesizex linesizey)))    (setf x (- x (car deltaxy))          y (+ y (second deltaxy)))    (draw-object self (om-get-current-port) x y zoom nil nil nil nil slot size nil staff nil chnote)));=====DRAW CHORDSEQ(defmethod draw-page-one-line ((self grap-chord-seq) score pagenum linenum x y linesizex linesizey zoom  slot size  staff chnote numvoice)  (let* ((fdoc (score-fdoc score))         (elements (get-page-line-elements  self fdoc pagenum linenum 0)))    (loop for item in elements do          (draw-prop-chord item score pagenum linenum x y linesizex linesizey zoom  slot size staff chnote))));draw a chord in a  proportional score (defmethod draw-prop-chord ((self grap-chord) score pagenum linenum x y linesizex linesizey zoom  slot size  staff  chnote)  (let ((deltaxy (compute-delta-x-y score pagenum linenum linesizex linesizey)))    (setf x (- x (car deltaxy))          y (+ y (second deltaxy)))    (draw-object self (om-get-current-port) x y zoom nil nil nil nil slot size nil staff nil chnote)));=====DRAW MULTISEQ(defmethod draw-page-one-line ((self grap-multiseq) score pagenum linenum x y linesizex linesizey zoom  slot size  staff chnote numvoice)  (let* ((fdoc (score-fdoc score))         (posy y))    (loop for chord-seq in (inside self)          for voice = 0 then (+ voice 1) do          (let ((elements (get-page-line-elements  chord-seq fdoc pagenum linenum voice)))            (loop for chord in elements do                  (draw-prop-chord chord score pagenum linenum x (- posy (round (* (posy (car (staff-list (nth voice staff)))) (/ size 4))))                                   linesizex linesizey zoom  slot size staff chnote)))          (setf posy (+ posy (get-delta-system (nth voice staff) size score voice))))));=====DRAW VOICE(defmethod draw-page-one-line ((self grap-voice) score pagenum linenum x y linesizex linesizey zoom  slot size  staff chnote numvoice)  (let* ((fdoc (score-fdoc score))         (elements (get-page-line-elements  self fdoc pagenum linenum 0))         (zoom-line (/ linesizex (- (third (rectangle (car (last elements)))) (first (rectangle (car elements))))))         (delta-mes (first (rectangle (car elements))))         (thetempi (get-voice-tempilist (reference self)))         (deltax  (round (+ (get-key-space score) (* size (score-left-margin score)))))         dynamicpos         )    (loop for item in elements          for i = 0 then (+ i 1) do          (draw-page-measure item score pagenum linenum  (+ deltax (round (* zoom-line (- x  delta-mes)))) y  ;porque el x ?                             linesizex linesizey (* zoom zoom-line)  slot size staff chnote                             (= i 0) (= (+ i 1) (length elements))))    (loop for cur in elements          for next in (cdr elements) do        (setf (nth 2 (rectangle cur)) (nth 0 (rectangle next))))    (when thetempi      (let ((deltaxy (compute-delta-x-y score pagenum linenum linesizex linesizey)))        (setf y (+ y (second deltaxy)))        (loop for cur in elements  do              (setf dynamicpos (draw-tempi-in-mes self (position cur (inside self) :test 'equal) (copy-list thetempi)                                                 cur size staff y                                                 dynamicpos                                                 (car (rectangle cur)))))))));-----Draw a measure(defmethod draw-measure-signature ((self grap-measure) x y size)  (om-draw-string  x (+ (round size 4) y) (format () "~D" (caar (tree (reference self)))))  (om-draw-string  x (+ y (round size 4) (round size 2)) (format () "~D" (cadar (tree (reference self))))))(defmethod draw-measure-number ((self grap-measure) x y size staff)  (let ((i (position self (inside (parent self)) :test 'equal)))    (when (and i (not (= i 0)))      (om-with-font (get-font-to-draw 5)                    (om-draw-string  x (- (+ y (line2pixel (posy (car (staff-list staff))) nil (/ size 4))) (round size 4))                                     (format () "~D" (+ i 1)))))))(defun draw-measure-bar ( x y staff size)  (om-draw-line  x  (+ y (line2pixel (posy (car (staff-list staff))) nil (/ size 4)))                  x (+ y size (line2pixel (posy (car (last (staff-list staff)))) nil (/ size 4)))))(defmethod draw-page-measure ((self grap-measure) score pagenum linenum x y linesizex linesizey zoom slot size staff chnote first-of-line last-of-line)  (let ((space (get-chiffrage-space self size))        (poly-p (poly-p (get-root-parent (reference self))))        (deltaxy (compute-delta-x-y score pagenum linenum linesizex linesizey))        previous)    (setf y (+ y (second deltaxy)))  ; x (- x (car deltaxy))       (loop for item in (inside self) do          (page-draw-object-ryth item score pagenum  x y zoom  slot size  staff chnote)          (when *om-tonalite*            (setf previous (draw-modulation  (parent self) item previous x y zoom size score))))    (collect-rectangles self)    (setf (nth 0 (rectangle self)) (- (nth 0 (rectangle self)) space))    (om-with-fg-color nil *system-color*      (loop for thestaff in (staff-list staff) do            (let ((ys (+ y (line2pixel (posy thestaff) nil (/ size 4)))))              (om-with-font (get-font-to-draw 2)                            (let ((pos (position self (inside (parent self)))))                              (cond                               ((zerop pos) (draw-measure-signature self (car (rectangle self)) ys size))                               ((show-chifrage self)                                (draw-measure-signature self (car (rectangle self)) ys size)                                (t                                 (let ((previous-mes (nth (- pos 1) (inside (parent self)))))                                   (unless (equal (metric self) (metric previous-mes))                                     (draw-measure-signature self (car (rectangle self)) ys size))))))))))      (unless (or first-of-line poly-p )        (draw-measure-bar (car (rectangle self)) y staff size))      (when (and first-of-line (not poly-p))          (draw-measure-number self (car (rectangle self)) y size staff))      (when last-of-line        (draw-measure-bar (round (+ (/ size 4) (* size (score-left-margin score))  (score-widht score size))) y staff size)))    (draw-extras self (om-get-current-port) size staff)));----Draw a group(defmethod page-draw-object-ryth ((self grap-group) score pagenum  x y zoom  slot size  staff chnote)  (loop for item in (inside self) do        (page-draw-object-ryth item score pagenum  x y zoom  slot size  staff chnote))  (collect-rectangles self)   (om-with-fg-color nil (mus-color (reference self))    (let ((dire (dirgroup self)))      (when (figure-? self)        (group-draw-stems self dire x y (rectangle self) zoom size)        (draw-beams-note-in-group self dire x -1 (rectangle self) zoom size)        (draw-num-denom-s self x size (rectangle self)))))   (draw-extras self (om-get-current-port) size staff));----Draw a chord(defmethod page-draw-object-ryth ((self grap-ryth-chord) score pagenum  x y zoom  slot size  staff chnote)   (om-with-fg-color nil (mus-color (reference self))      (let* ((dir (stemdir self))             (thenotes (copy-list (inside self))))        (loop for item in thenotes do              (page-draw-object-ryth item score pagenum  x y zoom  slot size  staff chnote ))        (collect-rectangles self)         (when (bigchord self)              (om-with-font (get-font-to-draw 8)                           (om-draw-string  (+ (car (rectangle self)) (round size 5))                                             (+ (round size 7) (fourth (rectangle self)))                                             (format nil "~D" (bigchord self)))))           (when (figure-? self)              (when (stem self)               (draw-chord-beams self x y zoom (beams-num self) dir size)))           (draw-extras self (om-get-current-port) size staff)         (when *om-tonalite*           (draw-chiffrage self x y zoom size)))      (page-draw-action-boxes self score)))(defun get-box-chord-list (list chord)  (loop for item in list when (equal (reference chord)  (second item)) collect item))(defun page-draw-action-boxes (chord score)  (let ((boxes (get-box-chord-list (score-action-boxes score) chord)))    (loop for item in boxes do          (when (show-always? (car item))            (draw-action-score-box (car item) chord (fourth item) score (om-get-current-port))))));----Draw a rest(defmethod page-draw-object-ryth ((self grap-rest) score pagenum  x y zoom  slot size   staff chnote )   (draw-object-ryth self (om-get-current-port) x y zoom nil nil nil nil slot size nil staff chnote))(defmethod page-draw-object-ryth ((self grap-note) score pagenum  x y zoom  slot size   staff chnote )  (draw-object self (om-get-current-port) x y zoom nil nil nil nil slot size nil staff nil chnote));=====DRAW POLY(defmethod score-get-onsets-to-break ((self polypanel) grapobj)  (let ((grapvoice (car (inside grapobj))))    (loop for item in (inside grapvoice)          append (list (list 0 (- (third (rectangle item)) (car (rectangle item))) (main-point item) (offset->ms (reference item)))))))(defmethod cons-mixed-lines ((score polypanel) list linesize)  (make-page-break list linesize))(defmethod draw-page-one-line ((self grap-poly) score pagenum linenum x y linesizex linesizey zoom  slot size  staff chnote numvoice)  (let* ((fdoc (score-fdoc score))         (posy y)         (deltax  (round (+ (get-key-space score) (* size (score-left-margin score)))))         (deltaline (get-delta-line staff size score))         (linesize  (get-line-size staff score size) )         zoom-line delta-mes allmesures positions)    (loop for voice in (inside self)          for i = 0 then (+ i 1) do          (let* ((elements (get-page-line-elements voice fdoc pagenum linenum 0)) )            (unless delta-mes              (setf delta-mes (first (rectangle (car elements)))))            (unless zoom-line              (setf zoom-line (/ linesizex (- (third (rectangle (car (last elements)))) (first (rectangle (car elements)))))))            (push elements allmesures)            (loop for measure in elements                   for k = 0 then (+ k 1) do                  (draw-page-measure measure score pagenum linenum  (+ deltax (round (* zoom-line (- x  delta-mes))))                                      (- posy (round (* (posy (car (staff-list (nth i staff)))) (/ size 4))))                                      linesizex linesizey (* zoom zoom-line)  slot size (nth i staff) chnote                                     (= k 0) (= (+ k 1) (length elements)))))            (setf posy (+ posy (get-delta-system (nth i staff) size score i))))    (setf allmesures (mat-trans (reverse allmesures)))    (page-draw-aligned-measures self score allmesures staff (+ y (* linenum  deltaline ) ) (+ y (* linenum  deltaline ) (- linesize size)) size)    (draw-extras self (om-get-current-port) size staff)))(defmethod page-draw-aligned-measures ((self grap-poly) score list staff y0 y1 size)  (om-with-font (get-font-to-draw 5)                (let ((num (position (car (car list)) (inside (parent (car (car list)))) :test 'equal)))                  (unless (zerop num)                    (om-draw-string  (car (rectangle (car (car list)))) (- y0  (round size 2))                                 (format () "~D" (+ num 1))))))  (loop for group in (cdr list) do        (let* ((max (loop for item in group maximize (first (rectangle item))))               (firstmes (car group))               (pos (position firstmes (inside (parent firstmes))))               (previous-mes (nth (- pos 1) (inside (parent firstmes))))               )          (loop for item in group do                (setf (nth 0 (rectangle item)) max))          (om-draw-line (car (rectangle (car group))) y0 (car (rectangle (car group))) y1)          (unless (equal (metric firstmes) (metric previous-mes))            (om-with-font (get-font-to-draw 2)                          (let ((posy y0))                            (loop for system in  staff                                  for mes in group                                  for i = 0 then (+ i 1) do                                  (let ((startpos (posy (car (staff-list system)))))                                    (loop for staff in (staff-list system) do                                          (draw-measure-signature mes (+ (car (rectangle mes)) (round size 8))  (+ posy  (* (round size 4) (- (posy staff) startpos))) size)                                          )                                    (setf posy (round (+ posy (get-delta-system system size score i))))))))))))                            ;;;========= **** =========(defmethod get-rectangle-to-draw ((self simple-graph-container) )   (rectangle self))(defmethod get-rectangle-to-draw ((self grap-note))    (when (rectangle self)     (let* ((rec (rectangle self))            (rec (list (- (car rec) 2) (- (second rec) 2) (+ (third rec) 2 ) (+ (fourth rec) 2))))       rec)))(defmethod page-draw-score-selection ((self t) selection pagerect factor) t)(defmethod page-draw-score-selection ((self simple-graph-container) selection pagerect factor)   (if (member (reference self) selection :test 'equal)     (draw-h-rectangle (rectlist-page-to-pixel  pagerect factor (get-rectangle-to-draw self)) :fill t)     (loop for item in (extras self) do           (page-draw-score-selection item selection pagerect factor))))(defmethod page-draw-score-selection ((self grap-container) selection pagerect factor)   (loop for item in (extras self) do           (page-draw-score-selection item selection pagerect factor))   (if (member (reference self) selection :test 'equal)     (draw-h-rectangle (rectlist-page-to-pixel  pagerect factor (rectangle self)) :fill t)     (loop for item in (inside self) do           (page-draw-score-selection item selection pagerect factor))))(defmethod page-draw-score-selection ((self grap-extra-pict) selection pagerect factor)   (if (member (reference self) selection :test 'equal)     (draw-h-rectangle (rectlist-page-to-pixel  pagerect factor (rectangle self)) :fill t)))(defmethod page-draw-score-selection ((self grap-extra-objet) selection pagerect factor)   (if (member (reference self) selection :test 'equal)     (draw-h-rectangle (rectlist-page-to-pixel  pagerect factor (rectangle self)) :fill t)));===========================================;TOOLS;===========================================;======================================;conversion page to pixel and viceversa;======================================(defun point-pixel-to-page (pagerect factor point)  (om-make-point (round  (- (om-point-h point) (om-rect-left pagerect)) factor)                 (round  (- (om-point-v point) (om-rect-top pagerect)) factor)))(defun rect-pixel-to-page (pagerect factor rect)  (om-make-rect (round  (- (om-rect-left rect) (om-rect-left pagerect)) factor)                (round  (- (om-rect-top rect) (om-rect-top pagerect)) factor)                (round  (- (om-rect-right rect) (om-rect-left pagerect)) factor)                (round  (- (om-rect-bottom rect) (om-rect-top pagerect)) factor)))(defun rectlist-pixel-to-page (pagerect factor rect)  (list (round  (- (car rect) (om-rect-left pagerect)) factor)        (round  (- (second rect) (om-rect-top pagerect)) factor)        (round  (- (third rect) (om-rect-left pagerect)) factor)        (round  (- (fourth rect) (om-rect-top pagerect)) factor)))(defun point-page-to-pixel (pagerect factor point)  (om-make-point (round  (+ (* factor (om-point-h point)) (om-rect-left pagerect)))                 (round  (+ (* factor (om-point-v point)) (om-rect-top pagerect)))))(defun rect-page-to-pixel (pagerect factor rect)  (om-make-rect (round  (+ (* factor (om-rect-left rect)) (om-rect-left pagerect)))                (round  (+ (* factor (om-rect-top rect)) (om-rect-top pagerect)))                (round  (+ (* factor (om-rect-right rect)) (om-rect-left pagerect)))                (round  (+ (* factor (om-rect-bottom rect)) (om-rect-top pagerect)))))(defun rectlist-page-to-pixel (pagerect factor rect)  (list (round  (+ (* factor (car rect)) (om-rect-left pagerect)))        (round  (+ (* factor (second rect)) (om-rect-top pagerect)))        (round  (+ (* factor (third rect)) (om-rect-left pagerect)))        (round  (+ (* factor (fourth rect)) (om-rect-top pagerect)))));====================================;get rectangles in page mode;====================================(defun get-i-line-rect (deltax deltay line deltaline linesize width )  (om-make-rect deltax (+ deltay (* line deltaline))                 (+ deltax width) (+ deltay (* line deltaline) linesize))); get the rectangles and staff rects of each page page and lines(defun get-rectangle-pages (self)  (let* ((fdoc (score-fdoc self))         (numpages (length (page-list fdoc)))         (wpict (om-point-h (score-paper-size self)))         (hpict  (om-point-v (score-paper-size self)))         (factor (or (score-scale self) 1))         (fwpict (round (* wpict factor)))         (fhpict (round (* hpict factor)))         (sepw 15)         (seph 15)         (h-pages (max 1 (floor (w self) (+ sepw sepw fwpict))))          (v-pages (ceiling numpages h-pages))         (size (staff-size self))         (staff (list! (staff-sys self)))         (deltay (round (* size (score-top-margin self))))         (deltax  (round (* size (score-left-margin self))))         (deltaline (get-delta-line staff size self))         (linesize (get-line-size staff self size))         (width (score-widht self size))         rep)    (loop for i from 0 to (- v-pages 1)  do          (loop for k from 0 to (- h-pages 1)                while (< (+ (* i  h-pages) k) numpages) do                (let* ((left (+ sepw (* k (+ sepw fwpict))))                       (top (+ seph (* i (+ seph fhpict))))                       (right (+ sepw fwpict (* k (+ sepw fwpict))))                       (bottom (+ seph fhpict (* i (+ seph fhpict))))                       (rect (om-make-rect left top right bottom))                       (pagenum (+ (* i  h-pages) k))                       linesrect)                  (setf linesrect (loop for line from 0 to (- (howmany-lines fdoc pagenum) 1)                                        collect (let ((line-rect (get-i-line-rect deltax deltay line deltaline linesize width )))                                                  (rect-page-to-pixel rect factor line-rect))))                  (push  (list rect linesrect) rep))))    (reverse rep)))(defun get-rectangle-only-pages (self)  (loop for item in (get-rectangle-pages self)        collect (car item)))