;;; hs.el -- Harlem Shake
;;; Author: Sriram Thaiyar <sriram.thaiyar@gmail.com>
;;; Dashcon 2014 (internal On-Site.com conference)
;;; Slides:
;;; https://docs.google.com/presentation/d/1OLhBfh76CtpBIsCL66TexJ5koQIfiI2yYXY7bO25Yu0/edit?usp=sharing
;;; Tested under OS X.
;;; For better effects: hs.mp3 (the Harlem Shake music) in current directory.
;;;

(defvar hs-face-widths
  '(ultra-condensed extra-condensed condensed
                    semi-condensed normal semi-expanded
                    expanded extra-expanded ultra-expanded))

(defvar hs-face-weights
  '(ultra-bold extra-bold bold semi-bold normal
               semi-light light extra-light ultra-light))

(defvar hs-face-colors
  '("Yellow" "Red" "Orange" "Blue" "Green" "Black" "White"))

(defun rand-elt (list)
  (nth (random (length list)) list))

(defun hs-change (i &optional no-color)
  (let ((ch (char-to-string (char-before (point))))
        (olay (car (overlays-at (point))))
        (olay-face-params
         (list ;:width (rand-elt hs-face-widths)
               :height (rand-elt '(80 100 120 140 160 180))
                ;:weight (rand-elt hs-face-weights)
               )))
    (unless no-color
      (push (rand-elt hs-face-colors) olay-face-params)
      (push :foreground olay-face-params))
    (when (null olay)
      (setq olay (make-overlay (point) (1+ (point)))))
    (backward-char 1)
    (delete-char 1)
    (overlay-put olay 'face olay-face-params)
    (insert (if (zerop (mod i 2)) (upcase ch) (downcase ch)))))

(defun hs ()
  (interactive)
  (let ((buf-string (buffer-substring-no-properties (window-start) (window-end)))
        (proc (start-process "afplay" "*afplay*" "/usr/bin/afplay" "hs.mp3")))
    (sit-for 1.0)
    (with-current-buffer (get-buffer-create " *hs*")
      (erase-buffer)
      (insert buf-string)
      (switch-to-buffer (current-buffer))
      (goto-char (point-min))
      (re-search-forward "[A-Za-z]" nil t)
      (let ((pt (point)))
        (dotimes (i 30)
          (goto-char pt)
          (hs-change i 'no-color)
          (end-of-line)
          (sit-for 0.5))
        (dotimes (i 18)
          (dotimes (j 300)
            (let ((n-lines (count-lines (point-min) (point-max))))
              (goto-char (point-min))
              (forward-line (random n-lines))
              (let ((n-chars (- (point-at-eol) (point))))
                (ignore-errors (forward-char (random n-chars))))
              (when (re-search-forward "[A-Za-z]" nil t)
                (hs-change j))))
          (goto-char (point-min))
          (end-of-line)
          (if (> i 14)
              (sit-for 1.2)
            (sit-for 0.5))))
      (kill-buffer)
      (kill-process proc))))
