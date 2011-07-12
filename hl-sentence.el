;; (require 'hl-line)

(setq hl-sentence-end "[^.].[.?!]+\\([]\"')}]*\\|<[^>]+>\\)\\($\\| $\\|\t\\| \\)[ \t\n]*")

(setq hl-sentence-face (make-face 'hl-sentence-face))
;; (set-face-attribute 'hl-sentence-face nil :foreground "#d5cfd9")

(defun hl-sentence-begin-pos () (save-excursion (unless (= (point) (point-max)) (forward-char)) (backward-sentence) (point)))
(defun hl-sentence-end-pos () (save-excursion (unless (= (point) (point-max)) (forward-char)) (backward-sentence) (forward-sentence) (point)))

(setq hl-sentence-mode nil)

(defun hl-sentence-current (&rest ignore)
  "Highlight current sentence."
    (and hl-sentence-mode (> (buffer-size) 0)
    (progn
      (and  (boundp 'hl-sentence-extent)
        hl-sentence-extent
        (move-overlay hl-sentence-extent (hl-sentence-begin-pos) (hl-sentence-end-pos) (current-buffer)) ;;; XEmacs: use set-extent-endpoints instead of move-overlay
      )
)))

(setq hl-sentence-extent (make-overlay 0 0))
(overlay-put hl-sentence-extent 'face hl-sentence-face)

;;;###autoload
(define-minor-mode hl-sentence-mode
  (progn
    (if hl-sentence-mode
        (move-overlay hl-sentence-extent 0 0 (current-buffer)))
    (add-hook 'post-command-hook 'hl-sentence-current))
  )


(provide 'hl-sentence)
