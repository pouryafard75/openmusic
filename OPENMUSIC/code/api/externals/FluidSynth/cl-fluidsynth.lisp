;;===========================================================================
;;FluidSynth API for Common Lisp/CFFI
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

(in-package :cl-fluidsynth)

(fluid_version_str)

;; (om::om-shell "opera /usr/share/doc/fluidsynth-devel-1.1.6/html/index.html &")

(defvar *fluidsynth* nil)
(defvar *fluidsynth-settings* nil)
(defvar *fluidplayer* nil)
(defvar *fluid-midi-player* nil)
(defvar *fluidadriver* nil)

(defvar *fluid-midi-driver-settings* nil)

(unless *fluidsynth*
  (progn
    (setf *fluidsynth-settings* (new_fluid_settings))
    (fluid_settings_setint *fluidsynth-settings* "audio.jack.autoconnect" 1)
    (fluid_settings_setstr *fluidsynth-settings* "audio.jack.id" "OM_fluidsynth")
    (setf *fluidsynth* (new_fluid_synth *fluidsynth-settings*))
    (setf *fluidplayer* (new_fluid_player *fluidsynth*))
    (setf *fluidadriver* (new_fluid_audio_driver *fluidsynth-settings* *fluidsynth*))
    (fluid_synth_sfload *fluidsynth* "/usr/share/soundfonts/FluidR3_GM.sf2" 1)))

;; (fluid_settings_setint *fluidsynth-settings* "gain" 2)

;;(fluid_player_get_status *fluidplayer*)

(unless *fluid-midi-driver-settings*
  (progn
    (setf *fluid-midi-driver-settings* (new_fluid_settings))
    (fluid_settings_setstr *fluid-midi-driver-settings* "midi.driver" "jack")
    (fluid_settings_setstr *fluid-midi-driver-settings* "midi.jack.id" "OM_fluidsynth")))

(defcallback cl-fluid-handle-midi-event :int
    ((data (:pointer :void))
     (event (:pointer fluid_midi_event_t)))
  (declare (ignore data))    
  (fluid_synth_handle_midi_event *fluidsynth* event)
  ;;(print (format nil "event type: ~X" (fluid_midi_event_get_type event)))
  1)

(unless *fluid-midi-player*
  (setf *fluid-midi-player* (new_fluid_midi_driver
			     *fluid-midi-driver-settings*
			     (callback cl-fluid-handle-midi-event)
			     (null-pointer))))

(cl-jack::jack-connect cl-jack::*CLJackClient*
		       (cl-jack::jack-port-name cl-jack::*jack-midi-output-port*)
		       "OM_fluidsynth:midi")

;;(delete_fluid_midi_driver *fluid-midi-player*)

#|





(cl-jack::jack-get-client-name cl-jack::*CLJACKCLIENT*)
(cl-jack::jack-get-ports cl-jack::*CLJACKCLIENT* "" "" 0)

(with-foreign-object (fluidports :pointer)
  (setf fluidports (cl-jack::jack-get-ports cl-jack::*CLJACKCLIENT*  "fluid" "midi" 0))
  (loop for i from 0
     and port = (mem-aref fluidports :string i)
     while port
     collect port))

(cl-jack::jack-get-ports cl-jack::*CLJACKCLIENT*  "fluid" "midi" 0)

(cl-jack::jack-connect cl-jack::*CLJACKCLIENT* "OM_fluidsynth" )

;; play midi-file from file:

(fluid_player_add *fluidplayer* "/home/andersvi/prosjekter/GESTURES/vib-enkel/marimba-test.midi")
(fluid_player_play *fluidplayer*)
(fluid_player_stop *fluidplayer*)


(progn
  (delete_fluid_audio_driver *fluidadriver*)
  (delete_fluid_player *fluidplayer*)
  (delete_fluid_synth *fluidsynth*)
  (delete_fluid_settings *fluidsynth-settings*))

(fluid_synth_noteon *fluidsynth* 0 63 127)
(fluid_synth_noteoff *fluidsynth* 0 63)

(loop repeat 120
   for note = (+ 20 (random 70))
   do
     (fluid_synth_noteon *fluidsynth* 0 note 100)
     (sleep 1/16)
     (fluid_synth_noteoff *fluidsynth* 0 note))

;; arpeggio example

(defun schedule-noteon (chan key ticks)
  (let ((ev (new_fluid_event)))
    (fluid_event_set_dest ev synth_destination)
    (fluid_event_noteon ev chan key 127)
    (fluid_sequencer_send_at sequencer ev ticks 1)
    (delete_fluid_event ev)))

(defun schedule-noteoff (chan key ticks)
  (let ((ev (new_fluid_event)))
    (fluid_event_set_dest ev synth_destination)
    (fluid_event_noteoff ev chan key)
    (fluid_sequencer_send_at sequencer ev ticks 1)
    (delete_fluid_event ev)))

(defun schedule-timer-event ()
  (let ((ev (new_fluid_event)))
    (fluid_event_set_source ev -1)
    (fluid_event_set_dest ev client_destination)
    (fluid_event_timer ev nil)
    (fluid_sequencer_send_at sequencer ev time_marker 1)
    (delete_fluid_event ev)))

(defun schedule-pattern (notes duration)
  (let* ((now time_marker)
	 (siz (length notes))
	 (note-duration (floor duration siz)))
    (loop for i from 0 below siz
	 for note = (nth i notes)
	 do
	 (schedule-noteon 0 note now)
	 (schedule-noteoff 0 note (+ now note-duration)))
    (incf time_marker duration)))

(defcallback sequencer-callback
    :void ((time :unsigned-int) (event fluid_event_t)
	   (seq fluid_sequencer_t) (data (:pointer :void)))
  (declare (ignore time event seq data))
  (schedule-timer-event)
  (schedule-pattern notes duration)
  )

(reverse '(60 64 67 72 76 79 84 79 76 72 67 64))
(setf notes #(64 72 67 79 76 79 76 72 84 60 64 67))
(setf duration 1440)
(setf notes #(60 64 67 72 76 79 84 79 76 72 67 64))
(setf notes (make-array 12 :initial-contents
			(loop repeat 12
			     collect (+ 12 (random 100)))))

(setf pattern_size (length notes))
(setf *fluidsynth-settings* (new_fluid_settings))

(fluid_settings_setint *fluidsynth-settings* "audio.jack.autoconnect" 1)

(setf synth (new_fluid_synth settings))
(setf audiodriver (new_fluid_audio_driver *fluidsynth-settings* synth))
(setf sequencer (new_fluid_sequencer))
(setf synth_destination (fluid_sequencer_register_fluidsynth sequencer synth))
(setf client_destination (fluid_sequencer_register_client
			  sequencer
			  "arpeggio" (callback sequencer-callback) nil))
(setf n (fluid_synth_sfload synth "/usr/share/soundfonts/FluidR3_GM.sf2" 1))
(setf time_marker (fluid_sequencer_get_tick sequencer))
(schedule-pattern )
(schedule-timer-event)
(schedule-pattern)

;;cleanup

(progn
  (delete_fluid_synth synth)
  (delete_fluid_sequencer sequencer)
  (delete_fluid_audio_driver audiodriver)
  (delete_fluid_settings *fluidsynth-settings*))
|#
