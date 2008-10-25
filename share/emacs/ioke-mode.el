;;; ioke-mode2.el --- Major mode for the ioke language

;; Copyright (C) 2008  Ola Bini

;; Author: Ola Bini <ola.bini@gmail.com>
;; Keywords: 

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; 

;;; Code:

(defconst ioke-version "0.1"
  "ioke mode version number")

(defconst ioke-interpreter-executable "ioke"
  "ioke executable")

(defconst ioke-indent-offset 2
  "ioke mode indent offset")

(defconst ioke-electric-parens-p t
  "Should the ioke mode autoindent after parentheses are typed?")

(defconst ioke-clever-indent-p t
  "Should the ioke mode try to dedent and reindent depending on context?")

(defconst ioke-auto-mode-p t
  "Should the ioke mode add itself to the auto mode list?")

(defconst ioke-comment-face font-lock-comment-face
  "The font to use for comments.")

(defconst ioke-prototype-face font-lock-type-face
  "The font to use for known prototypes.")

(defconst ioke-slot-face font-lock-function-name-face
  "The font to use for slots.")

(defconst ioke-object-face font-lock-builtin-face
  "The font to use for cloned objects.")

(defconst ioke-operator-face font-lock-variable-name-face
  "The font to use for operators.")

(defconst ioke-special-face font-lock-warning-face
  "The font to use for special operators.")

(defconst ioke-number-face font-lock-constant-face
  "The font to use for numbers.")

(defconst ioke-braces-face font-lock-preprocessor-face
  "The font to use for braces.")

(defconst ioke-object-assign-face font-lock-builtin-face
  "The font to use for object assignment.")

(defconst ioke-object-clone-face font-lock-warning-face
  "The font to use for object cloning.")

(defconst ioke-custom-face font-lock-builtin-face
  "The font to use for custom names.")

(defconst ioke-nothing-face font-lock-builtin-face
  "The font to use for white names.")

(defconst ioke-prototype-names '(
                                 "Base"
                                 "DefaultBehavior"
                                 "Ground"
                                 "Origin"
                                 "System"
                                 "Runtime"
                                 "Text"
                                 "Number"
                                 "Method"
                                 "DefaultMethod"
                                 "JavaMethod"
                                 "Mixins"
                                 )
  "ioke mode prototype names")

(defconst ioke-slot-names '(
                            "true"
                            "false"
                            "nil"
                            "if"
                            "method"
                            "use"
                            "print"
                            "println"
                            "cell"
                            "documentation"
                            "ifMain"
                            "while"
                            "until"
                            "asText"
                            "mimic"
                            "loop"
                            "break"
                            "self"
                            )
  "ioke mode slot names")

(defconst ioke-operator-symbols '(
				"'"
				"."
				;;"?"
				;;"("
				;;")"

				"++"
				"--"

				"*"
				"/"
				"%"

				"+"
				"-"

				"<<"
				">>"

				">"
				"<"
				"<="
				">="
				"<=>"

				"=="
				"!="

				"&"

				"^"

				"|"

				"&&"

				"||"

				".."

				"="
				"+="
				"-="
				"*="
				"/="
				"%="
				"&="
				"^="
				"|="
				"<<="
				">>="
				":="
				"<-"
				"<->"
				"->"
				)
  "ioke mode operator symbols")

(defconst ioke-operator-names '(
                                "and"
                                "or"
                                "return"
                                "super"
                                )
  "ioke mode operator names")

(defconst ioke-special-names '(
                               "`"
                               "'"
                               "@"
                               "@@"
                               )
  "ioke mode special names")

(defconst ioke-custom-names '(
			    ; your custom identifiers here
			    )
  "ioke mode custom names")

(defconst ioke-region-comment-prefix "{#"
  "ioke region comment prefix")

(defvar ioke-mode-hook nil
  "ioke mode hook")

(defvar ioke-keymap 
  (let ((ioke-keymap (make-sparse-keymap)))
    (if ioke-electric-parens-p
        (progn
          (define-key ioke-keymap "\C-c\C-t" 'ioke-eval-buffer)
          (define-key ioke-keymap "(" 'ioke-electric-open-paren)
          (define-key ioke-keymap ")" 'ioke-electric-close-paren)
          (define-key ioke-keymap "[" 'ioke-electric-open-s-paren)
          (define-key ioke-keymap "]" 'ioke-electric-close-s-paren)
          (define-key ioke-keymap "{" 'ioke-electric-open-c-paren)
          (define-key ioke-keymap "}" 'ioke-electric-close-c-paren)
          (define-key ioke-keymap "\C-c#" 'ioke-comment-region)
          ))
    ioke-keymap)
  "ioke mode keymap")

(defconst ioke-font-lock-keywords
  (list
    `(,(concat "\\<" (regexp-opt ioke-prototype-names t) "\\>") . ioke-prototype-face)
    `(,(concat "\\<[A-Z][[:alnum:]!?_:-]*\\>") . ioke-prototype-face)
    `(,(concat "\\<" (regexp-opt ioke-slot-names t) "\\>") . ioke-slot-face)
    `(,(concat "\\<" (regexp-opt ioke-custom-names t) "\\>") . ioke-custom-face)
    `(,(concat "\\<" (regexp-opt ioke-operator-names t) "\\>") . ioke-operator-face)
    `(,(regexp-opt ioke-special-names t) . ioke-special-face)
;    '("\\<[[:alnum:]!?_:-]+\\>" . ioke-nothing-face)
    `(,(regexp-opt ioke-operator-symbols t) . ioke-operator-face)
    '("\\([[:alnum:]!?_:-]+\\)[[:space:]]*[+*/-]?=[^=]" 1 ioke-object-assign-face t)
    '("\\([[:alnum:]!?_:-]+\\)[[:space:]]*=[^=][[:space:]]*[[:alnum:]_:-]+[[:space:]]+clone" 1 ioke-object-clone-face t nil)
    '("\\<[[:digit:]_]+\\>" 0 ioke-number-face t)
    '("[](){}[]+" 0 ioke-braces-face t)
    '("{#\\(.\\|\n\\)*#}" 0 ioke-comment-face t)
    '("#[^}].*$" 0 ioke-comment-face t)
   )
  "ioke mode font lock keywords")

(defvar ioke-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?\n "> b" st)
    st)
  "ioke mode syntax table")

(defun ioke-eval-buffer () (interactive)
       "Evaluate the buffer with ioke."
       (shell-command-on-region (point-min) (point-max) "ioke"))

(defun ioke-indent-line ()
  "ioke mode indent line"
  (interactive)
  (if (bobp)
      (indent-line-to 0)
    (let (current-depth current-close-flag current-close-open-flag
	  last-indent last-depth last-close-flag last-close-open-flag)
      (save-excursion
	(let (start-point end-point)
	  ; get the balance of parentheses on the current line
	  (end-of-line)
	  (setq end-point (point))
	  (beginning-of-line)
	  (setq current-close-flag (looking-at "^[]} \\t)]*)[]} \\t)]*$"))
	  (setq current-close-open-flag (looking-at "^[[:space:]]*[]})].*[({[][[:space:]]*$"))
	  (setq start-point (point))
	  (setq current-depth (car (parse-partial-sexp start-point end-point)))
	  ; and the previous non-blank line
	  (while (progn 
		   (forward-line -1)
		   (beginning-of-line)
		   (and (not (bobp))
			(looking-at "^\\s-*$"))))
	  (setq last-indent (current-indentation))
	  (end-of-line)
	  (setq end-point (point))
	  (beginning-of-line)
	  (setq last-close-flag (looking-at "^[]} \\t)]*)[]} \\t)]*$"))
	  (setq last-close-open-flag (looking-at "^[[:space:]]*[]})].*[({[][[:space:]]*$"))
	  (setq start-point (point))
	  (setq last-depth (car (parse-partial-sexp start-point end-point)))))
      (let ((depth last-depth))
	(if ioke-clever-indent-p
	    (setq depth (+ depth
			   (if current-close-flag current-depth 0)
			   (if last-close-flag (- last-depth) 0)
			   (if current-close-open-flag -1 0)
			   (if last-close-open-flag 1 0))))
	(indent-line-to (max 0
			     (+ last-indent
				(* depth ioke-indent-offset))))))))

(defun ioke-electric-open-paren ()
  "ioke mode electric close parenthesis"
  (interactive)
  (insert ?\()
  (let ((marker (make-marker)))
    (set-marker marker (point-marker))
    (indent-according-to-mode)
    (goto-char (marker-position marker))
    (set-marker marker nil)))

(defun ioke-electric-close-paren ()
  "ioke mode electric close parenthesis"
  (interactive)
  (insert ?\))
  (let ((marker (make-marker)))
    (set-marker marker (point-marker))
    (indent-according-to-mode)
    (goto-char (marker-position marker))
    (set-marker marker nil))
  (blink-matching-open))

(defun ioke-electric-open-c-paren ()
  "ioke mode electric close parenthesis"
  (interactive)
  (insert ?\{)
  (let ((marker (make-marker)))
    (set-marker marker (point-marker))
    (indent-according-to-mode)
    (goto-char (marker-position marker))
    (set-marker marker nil)))

(defun ioke-electric-close-c-paren ()
  "ioke mode electric close parenthesis"
  (interactive)
  (insert ?\})
  (let ((marker (make-marker)))
    (set-marker marker (point-marker))
    (indent-according-to-mode)
    (goto-char (marker-position marker))
    (set-marker marker nil))
  (blink-matching-open))

(defun ioke-electric-open-s-paren ()
  "ioke mode electric close parenthesis"
  (interactive)
  (insert ?\[)
  (let ((marker (make-marker)))
    (set-marker marker (point-marker))
    (indent-according-to-mode)
    (goto-char (marker-position marker))
    (set-marker marker nil)))

(defun ioke-electric-close-s-paren ()
  "ioke mode electric close parenthesis"
  (interactive)
  (insert ?\])
  (let ((marker (make-marker)))
    (set-marker marker (point-marker))
    (indent-according-to-mode)
    (goto-char (marker-position marker))
    (set-marker marker nil))
  (blink-matching-open))

(defun ioke-comment-region (beg end &optional arg)
  "Comment region for Io."
  (interactive "r\nP")
  (let ((comment-start ioke-region-comment-prefix))
    (comment-region beg end arg)))

(defun ioke-mode ()
  "ioke (testing) mode"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table ioke-syntax-table)
  (use-local-map ioke-keymap)
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '(ioke-font-lock-keywords nil nil nil))
  (set (make-local-variable 'indent-line-function) 'ioke-indent-line)
  (setq major-mode 'ioke-mode)
  (setq mode-name "ioke mode")
  (run-hooks 'ioke-mode-hook)
  (if ioke-auto-mode-p
      (add-to-list 'auto-mode-alist '("\\.ik$" . ioke-mode))))

(provide 'ioke-mode)
;;; ioke-mode.el ends here
