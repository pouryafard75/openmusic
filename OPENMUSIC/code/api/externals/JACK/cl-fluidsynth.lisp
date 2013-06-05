;;===========================================================================
;;JACK API for Common Lisp/CFFI
;;
;;This program is free software; you can redistribute it and/or modify
;;it under the terms of the GNU Lesser General Public License as published by
;;the Free Software Foundation; either version 2.1 of the License, or
;;(at your option) any later version.
;;  
;;This program is distributed in the hope that it will be useful,
;;but WITHOUT ANY WARRANTY; without even the implied warranty of
;;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;GNU Lesser General Public License for more details.
;;  
;;You should have received a copy of the GNU Lesser General Public License
;;along with this program; if not, write to the Free Software 
;;Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;
;;Author: Anders Vinjar

(in-package :cl-jack)

;;; setup external fluidsynth to connect midi from jack to
;;; TODO: wrap and load libfluidsynth.so to get this inside
;;;

(defparameter *fluidsynth-pid* nil)
(defparameter *fluidynth-io* nil)
(defparameter *fluid-synth-cmd* nil)
(defparameter *fluid-soundfont* "/usr/share/soundfonts/default.sf2")

(setf *fluid-synth-cmd*
      (format nil "fluidsynth -j -m jack -o midi.jack.id='OM_fluid' ~A" *fluid-soundfont*))

(defun launch-fluidsynth ()
  (unless *fluidsynth-pid*
    (when (and (streamp *fluidynth-io*) (open-stream-p *fluidynth-io*))
      (close *fluidynth-io*))
    (setf *fluidsynth-pid* nil)
    (multiple-value-bind (io err pid)
	(system:run-shell-command *fluid-synth-cmd*
				  :wait nil
				  :input :stream
				  :output :stream
				  :error-output nil)
      (setf *fluidsynth-pid* pid)
      (setf *fluidynth-io* io)
      (format *standard-output* "started fluidsynth: pid: ~A" pid)
      (list pid io))))

(unless *fluidsynth-pid*
  (launch-fluidsynth))


(defun quit-fluidsynth ()
  (when (and (open-stream-p *fluidynth-io*) *fluidsynth-pid*)
    (format *fluidynth-io* "quit~%")
    (format *standard-output* "stopped fluidsynth: pid: ~A" *fluidsynth-pid*)
    (setf *fluidsynth-pid* nil)
    (when (open-stream-p *fluidynth-io*)
      (close *fluidynth-io*))))

(om::om-add-init-func 'launch-fluidsynth)
(om::om-add-exit-cleanup-func 'quit-fluidsynth)
