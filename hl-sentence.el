;;; hl-sentence.el --- highlight a sentence based on customizable face

;; Copyright (c) 2011 Donald Ephraim Curtis

;; Author: Donald Ephraim Curtis <dcurtis@milkbox.net>
;; URL: http://github.com/milkypostman/hl-sentence
;; Version: 3
;; Keywords: highlighting

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Highlight the current sentence using `hl-sentence' face.
;;
;; To use this package, add the following code to your
;; `emacs-init-file'
;;
;; (require 'hl-sentence) (add-hook 'YOUR-MODE-HOOK 'hl-sentence-mode)
;;
;; You can customize the face to make it look the way you like
;;
;; (set-face-attribute 'hl-sentence nil
;;                     :foreground "#444")
;;
;; Please send bug reports to
;; https://github.com/milkypostman/hl-sentence/issues
;;
;; This mode started out as a bit of elisp at
;; http://www.emacswiki.org/emacs/SentenceHighlight by Aaron Hawley.
;;
;; 2021-11-14 Twitchy Ears fork.
;;
;; This now uses major mode dependant function dispatchers to guess
;; the start and end of sentence, this means it is ... better but not
;; perfect at dealing with org-mode.  Also I made the face not
;; overwrite current highlighting in the sentence so its a lot more of
;; a background thing.
;;
;; See the documentation for the two variables
;; hl-sentence-begin-mode-dispatcher and
;; hl-sentence-end-mode-dispatcher for more details, but the short
;; version is:
;;
;; (puthash modename function hl-sentence-begin-mode-dispatcher)
;; (puthash modename function hl-sentence-end-mode-dispatcher)

;;; Code:
(defgroup hl-sentence nil
  "Highlight the current sentence."
  :group 'convenience)

;;;###autoload
(defmacro hl-sentence-create-face ()
  "Macro used to define/redefine the hl-sentence face, it pulls the background element from highlight but sets the foreground transparent."
  `(defface hl-sentence '((t
                          :foreground nil
                          :background ,(face-attribute 'highlight :background)))
  "The face used to highlight the current sentence."
  :group 'hl-sentence))
;;;###autoload
(hl-sentence-create-face)

;;;###autoload
(defvar hl-sentence-begin-mode-dispatcher
      #s(hash-table
         size 30
         test eql
         data (org-mode hl-sentence-begin-pos-org))
      "Stores functions based on major mode to find beginning of sentence.

Use '(puthash modename function hl-sentence-begin-mode-dispatcher)' to add
your function for your desired mode.")

;;;###autoload
(defvar hl-sentence-end-mode-dispatcher
      #s(hash-table
         size 30
         test eql
         data (org-mode hl-sentence-end-pos-org))
      "Stores functions based on major mode to find end of sentence.

Use '(puthash modename function hl-sentence-end-mode-dispatcher)' to add
your function for your desired mode.")

(defun hl-sentence-begin-pos-org ()
  "Return the point of the beginning of a sentence, org aware."
  (save-excursion
    (cond

     ;; Treat org headings as a single thing, just get the start
     ((org-at-heading-p)
      (progn
        (org-beginning-of-line)
        (point)))
     
     ;; Treat org items as the bounding element and try and get
     ;; sentences within them.
     ((org-at-item-p)
      (let ((item-begin (progn
                          (save-excursion
                            (org-beginning-of-item)
                            (point))))
            (text-begin (hl-sentence-begin-pos-text)))
        (if (< text-begin item-begin)
            item-begin
          text-begin)))

     ;; Treat property drawers like headlines
     ((org-at-drawer-p)
      (progn
        (org-beginning-of-line)
        (point)))

     (t (hl-sentence-begin-pos-text)))))

(defun hl-sentence-begin-pos-text ()
  "Return the point at the beginning of a sentence, plain text expected."
  (save-excursion
    (unless (= (point) (point-max))
      (forward-char))
    (backward-sentence)
    (point)))

(defun hl-sentence-begin-pos (dispatcher)
  "Return the point at the beginning of a sentence, uses DISPATCHER to look
up functions based on your major mode to find things sensibly.  If there
is no specific function for that mode it will call
'hl-sentence-begin-pos-text' and treat the buffer like plain text."
  ;; (interactive)
  (save-excursion
    (let ((func (if dispatcher
                    (gethash major-mode dispatcher))))
      (if func
          (funcall func)
          ;; This is some real fun to bug chase.
          ;;(let ((loc (funcall func)))
          ;;  (message "begin-pos %s" loc)
          ;;  loc)
        (hl-sentence-begin-pos-text)))))


(defun hl-sentence-end-pos-org ()
  "Return the point of the end of a sentence. org aware."
  (save-excursion
    (cond

     ;; Treat headlines like single thing
     ((org-at-heading-p)
           (progn
             (org-end-of-line)
             (point)))

     ;; Treat org items as a bounding box and try and find sentences
     ;; within them
     ((org-at-item-p)
      (let ((item-end (progn
                        (save-excursion
                          (org-end-of-item)
                          (point))))
            (text-end (hl-sentence-end-pos-text)))
        (if (> text-end item-end)
            item-end
          text-end)))

     ;; Treat drawers like headlines
     ((org-at-drawer-p)
      (progn
        (org-end-of-line)
        (point)))
     
     (t (hl-sentence-end-pos-text)))))

(defun hl-sentence-end-pos-text ()
  "Return the point at the end of a sentence, expects plain text." 
  (save-excursion
    (unless (= (point) (point-max))
      (forward-char))
    ;; This causes a lot of issues in org and I'm not sure it gains
    ;; anything in text.
    ;; 
    ;; (backward-sentence) 
    (forward-sentence)
    (point)))
         
(defun hl-sentence-end-pos (dispatcher)
  "Return the point at the end of a sentence, uses DISPATCHER to look
up functions based on your major mode to find things sensibly.  If there
is no specific function for that mode it will call
'hl-sentence-end-pos-text' and treat the buffer like plain text."
  ;; (interactive)
  (save-excursion
    (let ((func (if dispatcher
                    (gethash major-mode dispatcher))))
      (if func
          (funcall func)
          ;;(let ((loc (funcall func)))
          ;;  (message "end-pos %s" loc)
          ;;  loc)
        (hl-sentence-end-pos-text)))))

(defvar hl-sentence-extent nil
  "The location of the hl-sentence-mode overlay.")

;;;###autoload
(define-minor-mode hl-sentence-mode
  "Enable highlighting of currentent sentence."
  :init-value nil
  (if hl-sentence-mode
      (add-hook 'post-command-hook 'hl-sentence-current nil t)
    (move-overlay hl-sentence-extent 0 0 (current-buffer))
    (remove-hook 'post-command-hook 'hl-sentence-current t)))

(defun hl-sentence-current ()
  "Highlight current sentence."
  (and hl-sentence-mode (> (buffer-size) 0)
       (boundp 'hl-sentence-extent)
       hl-sentence-extent
       (move-overlay hl-sentence-extent
		     (hl-sentence-begin-pos hl-sentence-begin-mode-dispatcher)
		     (hl-sentence-end-pos hl-sentence-end-mode-dispatcher)
		     (current-buffer))))

(setq hl-sentence-extent (make-overlay 0 0))
(overlay-put hl-sentence-extent 'face 'hl-sentence)

(provide 'hl-sentence)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; hl-sentence.el ends here
