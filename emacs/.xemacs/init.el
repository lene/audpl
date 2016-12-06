;;; .emacs --- GNU Emacs/XEmacs configuration file. -*-coding: latin-2;-*-

;; Copyright (C) 1994-1999 Tudor Hulubei

;; Author: Tudor Hulubei <tudor@hulubei.net>
;; Maintainer: Tudor Hulubei <tudor@hulubei.net>
;; Created: August 1994
;; Version: $Revision: 1.1 $
;; Keywords: configuration, .emacs
;; $Id: .emacs,v 1.1 2005/05/09 17:04:03 tudor Exp $

;; This .emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 2, or (at your
;; option) any later version.
;;
;; This .emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with .emacs; see the file COPYING.  If not, write to the Free
;; Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.


;;; History:

;;; Commentary:
;;;   1. As of 1.202, this .emacs no longer attempts to go around
;;;      problems in GNU Emacs < 20.2 & XEmacs < 20.3.  It should
;;;      load correctly though.
;;;   2. M-f over a $ character in a C/C++ string doesn't work.  Bug
;;;      in c-forward-into-nomenclature?
;;;   3. VM can't send mail if OUTBOX is empty.

;;; Todo:
;;;   1. Smooth horizontal scroll in both Emacsen.
;;;   2. Unify the scroll-up and scroll-down advices (impossible?).
;;;   3. Control the popup menus in all the major modes.
;;;   4. Make `Insert' and `Delete' work in `dired' mode.
;;;   5. Make scroll-up/down hit BOF/EOF in GNU Emacs.
;;;   6. GNU Emacs doesn't show the ^Ms.  XEmacs does.
;;;   7. The vm-skip-read-messages stuff doesn't work.
;;;   8. VM has problems initially, when the INBOX is empty.
;;;   9. I can't see the line number on the modeline sometimes;
;;;      make ^L display it in the minibuffer.
;;;  10. Emacs 19.34 doesn't have "when".

;;; Code:

;;; Detect the Emacs flavor.
(defvar emacs-version-no (+ (* emacs-major-version 100) emacs-minor-version))
(defvar gnuemacs-flag (string-match "GNU" (emacs-version)))
(defvar xemacs-flag (not gnuemacs-flag))

;;; Just in case `when' is not defined.  Stolen from GNU Emacs 20.4.
(defmacro when (cond &rest body)
  "(when COND BODY...): if COND yields non-nil, do BODY, else return nil."
  (list 'if cond (cons 'progn body)))

;;; Avoid mass hysteria.  Disable the toolbar.
(when (boundp 'default-toolbar-visible-p)
  (set-specifier default-toolbar-visible-p nil))

;;; Put all of your autosave files in one place.  Do this first to
;;; make sure that `~/.autosave' is created if missing.
(setq auto-save-directory (expand-file-name "~/.autosave/")
      auto-save-directory-fallback auto-save-directory)

(defun tryload (f) (condition-case nil (require f) (error nil)))
(defun tryrun (f) (condition-case nil (f) (error nil)))

;;; Attempt to load some optional features.  The order is important!
(mapcar #'tryload
        (list 'cl 'mail-utils 'vm 'vm-save 'vm-reply 'rmail ;'feedmail
              'footnote 'sendmail 'message 'mailcrypt 'bbdb 'smiley
              'browse-url 'time 'vc-hooks 'ediff-hook 'dired 'redo
              'completion 'tex-site 'recent-files 'icomplete 'msb
              'filladapt 'rsz-minibuf 'paren 'appt 'iswitchb 'flyspell
              'auto-save 'gdb-highlight 'auto-save 'view-less
              'sh-script 'mwheel 'highlight-headers 'func-menu
              'br-start 'hmouse-tag 'disp-table 'lisp-mnt 'supercite
              'cal-desk-calendar 'font-lock 'lazy-shot 'desktop))

(unless (featurep 'lazy-shot) (tryload 'lazy-lock))

(defmacro* progn-compiled (&body body)
  "Just like progn, but the body is executed byte-compiled.
Written by David Bakhash <cadet@mit.edu>."
  (let ((fname (gensym)))
    `(progn
       (setf (symbol-function ',fname) (function* (lambda () ,@body)))
       (byte-compile ',fname)
       (unwind-protect (funcall ',fname) (fmakunbound ',fname)))))

(defun file-regular-readable-p (filename)
  "Return t if file FILENAME is the name of a readable regular file."
  (and (file-regular-p filename) (file-readable-p filename)))

(defun file-empty-p (filename)
  "Return t if file FILENAME is the name of an empty file."
  (equal (eighth (file-attributes filename)) 0))

;;; GNU Emacs has different names for `point-at-bol' and
;;; `point-at-eol'.
(when (not (fboundp 'point-at-bol))
  (defalias 'point-at-bol 'line-beginning-position))
(when (not (fboundp 'point-at-eol))
  (defalias 'point-at-eol 'line-end-position))

;;; Configure the Reply-To address & stuff based on it.
(setq mail-default-reply-to (getenv "REPLYTO"))
(setq mail-host-address (system-name))

(when (or (equal mail-default-reply-to nil)
          (equal mail-default-reply-to ""))
  (setq mail-default-reply-to
        (concat (user-login-name) "@" mail-host-address)))

;; Make sure we can use bash2 under RedHat 6.0 as the login shell.
(if (boundp 'sh-alias-alist)
    (setq sh-alias-alist (append sh-alias-alist '((bash2 . bash)))))

;;; Miscellaneous settings, common to both Emacsen.
(setq truncate-lines t
      enable-local-eval t
      undo-limit 100000
      undo-threshold 100000
      undo-high-threshold 120000
      blink-matching-paren-distance 32768
      require-final-newline 'ask
      tab-width 8
      baud-rate 115200
      compilation-always-signal-completion t
      modeline-click-swaps-buffers t
      tex-dvi-view-command "xdvi"
      tex-default-mode 'latex-mode      ; TeX file not recognized => use LaTeX.
      dabbrev-case-replace nil          ; Dynamic abrevs preserve case.
      mark-ring-max 64                  ; # of marks kept in the mark ring.
      next-line-add-newlines nil        ; Don't add newlines at the end.
      vc-initial-comment t              ; Ask for an initial comment in VC.
      enable-recursive-minibuffers t    ; Allow recursive minibuffer ops.
      suggest-key-bindings 0            ; No delay after binding suggestions.
      custom-file "~/.xemacs/custom.el" ; Customize shouldn't overwrite .emacs.
      mail-use-rfc822 t                 ; Use the RFC822 email address parser.
      query-user-mail-address nil
;;      user-mail-address (mail-strip-quoted-names mail-default-reply-to)
)

;;; Load whatever customizations the user might have.
;;; Do it early, so that we can overwrite them. :-)
(if (and (fboundp 'defgroup) (file-exists-p custom-file))
    (load-file custom-file))

;;;(when (featurep 'iswitchb) (iswitchb-default-keybindings))
(when (featurep 'rsz-minibuf) (resize-minibuffer-mode))
(when (featurep 'completion) (initialize-completions))
(when (featurep 'icomplete) (icomplete-mode))
(when (featurep 'time) (display-time))

(when (fboundp 'calc)
  (setq calc-algebraic-mode t))
(when (fboundp 'line-number-mode)
  (line-number-mode 1))
(when (fboundp 'column-number-mode)
  (column-number-mode 1))
(when (fboundp 'mail-mode)
  (add-hook 'mail-mode-hook 'no-address-auto-fill)
  (add-hook 'mail-mode-hook 'footnote-mode-if-present))
(when (fboundp 'message-mode)
  (add-hook 'message-mode-hook 'no-address-auto-fill)
  (add-hook 'message-mode-hook 'footnote-mode-if-present))

(when (featurep 'dired)
  (setq dired-compression-method
        'gzip dired-no-confirm (list 'revert-subdirs))
  (add-hook
   'dired-load-hook
   #'(lambda ()
       (define-key dired-mode-map "\C-M" 'dired-advertised-find-file)
       ;; FIXME: bind Insert to dired-mark and dired-flag-file-deletion
       ;; to dired-flag-file-deletion.  HOW!?
       ;;(define-key dired-mode-map [(insert)] 'dired-flag-file-deletion)
       ;;(define-key dired-mode-map [(delete)] 'dired-flag-file-deletion)
       )))

(when (featurep 'redo)
  (global-set-key "\C-^" 'redo)
  (global-set-key [(control ?6)] 'redo))

(if (fboundp 'cperl-mode)
    (progn
      (add-hook 'cperl-mode-hook
                #'(lambda ()
                    (setq cperl-indent-level 4)
                    (setq cperl-continued-statement-offset 0)))
      (defun my-perl-mode () (cperl-mode)))
  (if (fboundp 'perl-mode)
      (progn
        (add-hook 'perl-mode-hook
                  #'(lambda ()
                      (setq perl-indent-level 4)
                      (setq perl-continued-statement-offset 0)))
        (defun my-perl-mode () (cperl-mode)))
    (defun my-perl-mode () (text-mode))))


(when (fboundp 'gnus)
  (setq gnus-check-new-newsgroups nil   ; ~/.newsrc should contain `group:'.
        gnus-read-active-file 'some
        gnus-subscribe-newsgroup-method 'gnus-subscribe-interactively
        gnus-show-all-headers t
        gnus-permanently-visible-groups ".*"))

(when (featurep 'highlight-headers)
  (defun adjust-message-highlighting ()
    (set-face-underline-p 'message-headers nil)
    (set-face-underline-p 'message-header-contents nil)
    (set-face-underline-p 'message-cited-text nil)
    (set-face-underline-p 'message-highlighted-header-contents nil)
    (set-face-foreground 'message-headers "red")
    (set-face-foreground 'message-header-contents "blue")
    (set-face-foreground 'message-cited-text
                         (if window-system "green4" "green"))))

(defun footnote-mode-if-present ()
  "Use footnote-mode if available."
  (interactive)
  (when (fboundp 'footnote-mode)
    (footnote-mode)))

(defun my-browse-url-function (url &rest new-window)
  "Under X, browse the web with netscape.  Under text mode, use w3."
  (interactive "p")
  (if (eq window-system 'x)
      (when (fboundp 'browse-url-netscape) (browse-url-netscape url t))
    (when (fboundp 'browse-url-w3) (browse-url-w3 url nil))))

(setq browse-url-browser-function 'my-browse-url-function)
(setq-default url-be-asynchronous t)

(when (fboundp 'turn-on-reftex)
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (add-hook 'latex-mode-hook 'turn-on-reftex))

(when (featurep 'tex-site)
  (setq TeX-auto-save t
        TeX-parse-self t)
  (setq-default TeX-master nil))


(when (featurep 'recent-files)
  (setq recent-files-use-full-names nil
        recent-files-number-of-entries 16
        recent-files-number-of-saved-entries 32
        recent-files-dont-include '("~/\\.newsrc" "~$" "^/tmp/." "^/.+@.+:.+")
        recent-files-permanent-submenu t
        recent-files-non-permanent-submenu t
        recent-files-menu-title "Work")
  (recent-files-initialize))

(when (fboundp 'ffap)
  (require 'ffap)
  (ffap-bindings)
  (when (fboundp 'browse-url)
    (setq ffap-url-fetcher 'browse-url)))

(when (featurep 'filladapt)
  (setq filladapt-mode-line-string nil)
  (setq-default filladapt-mode t))

(when (featurep 'view-less)
  (global-set-key "\C-ct" 'toggle-truncate-lines)
  (add-hook 'compilation-mode-hook
            #'(lambda () (toggle-truncate-lines 1))))

(defun file-rrne-p (filename)
  (and (file-regular-readable-p filename) (not (file-empty-p filename))))

(when (fboundp 'calendar)
  (when (file-regular-readable-p (setq diary-file "~/.diary"))
    (if (fboundp 'fancy-schedule-display-desk-calendar)
        (add-hook 'diary-display-hook 'fancy-schedule-display-desk-calendar)
      (add-hook 'diary-display-hook 'fancy-diary-display))
    (add-hook 'list-diary-entries-hook 'sort-diary-entries)
    (add-hook 'today-visible-calendar-hook 'calendar-mark-today)
    (setq number-of-diary-entries 2
          mark-holidays-in-calendar t
          all-christian-calendar-holidays t)
    (if (fboundp 'appt-initialize)
        (appt-initialize)
      (add-hook 'diary-hook 'appt-make-list))
    (setq appt-check-time-syntax t)
    (diary)))

(when (fboundp 'flyspell-mode)
  (when (fboundp 'global-flyspell-mode)
    (global-flyspell-mode t))
  (setq flyspell-global-modes '(vm-mail-mode mail-mode message-mode)
        flyspell-issue-welcome-flag nil
        flyspell-mode-line-string nil
        flyspell-highlight-flag nil	; Minibuffer reports.
        ispell-parser 'tex)
  ;; Take care of some flyspell bugs...
  (if (<= emacs-version-no 2004)
      (setq flyspell-persistent-highlight nil)))

(if (fboundp 'show-paren-mode)
    (show-paren-mode)
;  (paren-set-mode 'paren)
)

(when gnuemacs-flag
  (global-set-key '[(mouse-3)] 'mouse-major-mode-menu))

(when (or (eq window-system 'win32) (eq window-system 'w32))
  (setq grep-null-device "c:\\nullfile"
        process-coding-system-alist
        '(("cmdproxy" . (raw-text-dos . raw-text-dos)))))

;;; Confuse novice users :-).
(put 'eval-expression   'disabled nil)
(put 'capitalize-region 'disabled nil)
(put 'upcase-region     'disabled nil)
(put 'downcase-region   'disabled nil)

(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'icomplete-minibuffer-setup-hook
          #'(lambda ()
              (make-local-variable 'resize-minibuffer-window-max-height)
              (setq resize-minibuffer-window-max-height 3)))
(add-hook 'compilation-mode-hook
          #'(lambda ()
              (defconst compilation-window-height 10)
              (define-key compilation-minor-mode-map "\C-M"
                'compile-goto-error)))
(add-hook 'buffer-menu-mode-hook
          #'(lambda ()
              (define-key Buffer-menu-mode-map [f2]
                #'(lambda ()
                    (interactive)
                    (save-some-buffers t)
                    (buffer-menu-line-3)))
              (define-key Buffer-menu-mode-map "\C-M"
                #'(lambda ()
                    (interactive)
                    (bury-buffer (current-buffer))
                    (Buffer-menu-this-window)))
              ))

;;; Hide the difference between GNU Emacs (which uses overlays) and
;;; XEmacs (which uses extents).  XEmacs supports overlays too, maybe
;;; it would be ok to use overlays for both Emacsen.
(defun make-extent/overlay (begin end)
  (if (fboundp 'make-extent)
      (make-extent begin end)
    (if (fboundp 'make-overlay)
        (make-overlay begin end))))

(defun set-extent/overlay-property (extent/overlay property value)
  (if (fboundp 'make-extent)
      (set-extent-property extent/overlay property value)
    (if (fboundp 'make-overlay)
        (overlay-put extent/overlay property value))))

(defun set-extent/overlay-endpoints (extent/overlay begin end)
  (if (fboundp 'make-extent)
      (set-extent-endpoints extent/overlay begin end)
    (if (fboundp 'make-overlay)
        (move-overlay extent/overlay begin end))))

(defun delete-extent/overlay (extent/overlay)
  (if (fboundp 'make-extent)
      (delete-extent extent/overlay)
    (if (fboundp 'make-overlay)
        (delete-overlay extent/overlay))))

;;; Note: If you make changes to the colors defined here, make sure
;;; you remove ~/.emacs.customize, otherwise the settings here may
;;; not take effect.
(when (and (fboundp 'defgroup) (fboundp 'defface))
  (defmacro efa (device luminosity foreground background bold underline)
    "Expand face attributes into a list suitable for `defface' and
`custom-set-faces'."
    (list 'list (list 'list (list 'list
                                  `(list 'class 'color)
                                  `(list 'type ,device)
                                  `(list 'background ,luminosity))
                      `(list ':foreground ,foreground
                             ':background ,background
                             ':bold ,bold
                             ':underline ,underline))))

  (custom-set-faces
   `(calendar-today-face
     (,@(efa 'tty 'dark "white" "red" nil nil)
	,@(efa 'x 'light "white" "red" nil nil)
	,@(efa 'x 'dark "white" "red" nil nil)))
   `(holiday-face
     (,@(efa 'tty 'dark "white" "blue" nil nil)
	,@(efa 'x 'light "white" "blue" nil nil)
	,@(efa 'x 'dark "white" "blue" nil nil)))
   `(dired-face-directory
     (,@(efa 'tty 'dark "blue" nil nil nil)
	,@(efa 'x 'light "darkorchid" nil t nil)
	,@(efa 'x 'dark "cyan" nil t nil)))
   `(dired-face-executable
     (,@(efa 'tty 'dark "green" nil t nil)
	,@(efa 'x 'light "forestgreen" nil t nil)
	,@(efa 'x 'dark "green" nil t nil)))
   `(font-lock-reference-face
     (,@(efa 'tty 'dark "red" nil nil nil)
	,@(efa 'x 'light "orangered" nil nil nil)
	,@(efa 'x 'dark "pink" nil t nil)))
   `(font-lock-type-face
     (,@(efa 'tty 'dark "cyan" nil nil nil)
	,@(efa 'x 'light "darkorchid" nil nil nil)
	,@(efa 'x 'dark "cyan" nil nil nil)))
   `(font-lock-variable-name-face
     (,@(efa 'tty 'dark "yellow" nil t nil)
	,@(efa 'x 'light "blueviolet" nil nil nil)
	,@(efa 'x 'dark "gold" nil t nil)))
   `(font-lock-comment-face
     (,@(efa 'tty 'dark "red" nil t nil)
	,@(efa 'x 'light "red" nil t nil)
	,@(efa 'x 'dark "red" nil t nil)))
   `(font-lock-keyword-face
     (,@(efa 'tty 'dark "white" nil t nil)
	,@(efa 'x 'light "black" nil t nil)
	,@(efa 'x 'dark "white" nil t nil)))
   `(font-lock-function-name-face
     (,@(efa 'tty 'dark "blue" nil t nil)
	,@(efa 'x 'light "mediumblue" nil t nil)
	,@(efa 'x 'dark "yellow" nil t nil)))
   `(font-lock-preprocessor-face
     (,@(efa 'tty 'dark "blue" nil nil nil)
	,@(efa 'x 'light "navy" nil t nil)
	,@(efa 'x 'dark "blue" nil t nil)))
   `(font-lock-string-face
     (,@(efa 'tty 'dark "green" nil t nil)
	,@(efa 'x 'light "forestgreen" nil nil nil)
	,@(efa 'x 'dark "green" nil t nil)))
   `(font-lock-doc-string-face
     (,@(efa 'tty 'dark "green" nil t nil)
	,@(efa 'x 'light "forestgreen" nil nil nil)
	,@(efa 'x 'dark "green" nil t nil)))
   `(isearch
     (,@(efa 'tty 'dark "white" "green" t nil)
	,@(efa 'x 'light "black" "aquamarine" nil nil)
	,@(efa 'x 'dark "black" "green" nil nil)))
   `(modeline
     (,@(efa 'tty 'dark "black" "white" t nil)
	,@(efa 'x 'light "lightgray" "black" nil nil)
	,@(efa 'x 'dark "black" "white" nil nil)))
   `(info-node
     (,@(efa 'tty 'dark "yellow" nil t nil)
	,@(efa 'x 'light "red" nil nil nil)
	,@(efa 'x 'dark "yellow" nil t nil)))
   `(info-xref
     (,@(efa 'tty 'dark "green" nil t nil)
	,@(efa 'x 'light "blue" nil nil nil)
	,@(efa 'x 'dark "green" nil t nil)))
   `(man-bold
     (,@(efa 'tty 'dark "red" nil t nil)
	,@(efa 'x 'light "red" nil nil nil)
	,@(efa 'x 'dark "red" nil nil nil)))
   `(man-heading
     (,@(efa 'tty 'dark "blue" nil t nil)
	,@(efa 'x 'light "blue" nil nil nil)
	,@(efa 'x 'dark "blue" nil nil nil)))
   `(man-italic
     (,@(efa 'tty 'dark "blue" nil t nil)
	,@(efa 'x 'light "forestgreen" nil nil nil)
	,@(efa 'x 'dark "blue" nil nil nil)))
   `(man-xref
     (,@(efa 'tty 'dark "yellow" nil t nil)
	,@(efa 'x 'light "magenta" nil nil nil)
	,@(efa 'x 'dark "yellow" nil nil nil)))
   )


  (when (not (fboundp 'current-line-mode))
    ;; Display the current line with a distinctive face in some modes.
    (defgroup current-line nil
      "Variables dealing with the display of the current line."
      :group 'environment)

    (defface current-line-face
      '((((class color)) (:foreground "white" :background "blue")))
      "Face used to highlight the current line."
      :group 'current-line)

    (defcustom current-line-major-modes
      (list 'Buffer-menu-mode
	    'dired-mode
	    'compilation-mode
	    'vm-summary-mode
	    'rmail-summary-mode)
      "A list of major modes in which the current line is displayed with a
distinctive face.  Modify this as needed."
      :group 'current-line)

    (defvar current-line-extent/overlay nil)
    (make-variable-buffer-local 'current-line-extent/overlay)

    (defun current-line-update ()
      (when (member major-mode current-line-major-modes)
	(unless current-line-extent/overlay
	  (setq current-line-extent/overlay (make-extent/overlay 1 1))
	  (set-extent/overlay-property
	   current-line-extent/overlay 'face 'current-line-face)
	  (set-extent/overlay-property
	   current-line-extent/overlay 'priority 1))
	(set-extent/overlay-endpoints
	 current-line-extent/overlay (point-at-bol) (point-at-eol))))

    (defun current-line-mode (arg)
      "Display the current line with a distinctive face (current-line-face).
If ARG is nil, the appearance of the current line is not changed."
      (interactive "P")
      (if arg
	  (add-hook 'post-command-hook 'current-line-update)
	(remove-hook 'post-command-hook 'current-line-update))
      nil)
    )
  (current-line-mode t)
  )

;;; Without this, the address fields will be auto-filled, resulting in
;;; weird behaviour.  Thanks to WJCarpenter <bill@carpenter.org> for
;;; suggesting this fix.
(defun no-address-auto-fill ()
  (make-local-variable 'auto-fill-inhibit-regexp)
  (setq auto-fill-inhibit-regexp "\\(resent-\\)?\\(to:\\|cc:\\|bcc:\\)"))

(defun kill-frame ()
  "Delete the current frame, and if it is the last one, quit Emacs."
  (interactive)
  (if (cdr (frame-list))
      (delete-frame)
    ;; We always want to save these buffers, no need to ask the user.
    (mapcar #'(lambda (buffer)
                (when (string-match
                       (concat "INBOX$\\|OUTBOX$\\|\\.*.mail$\\|"
                               "RMAIL$\\|SMAIL$\\|"
                               ".contacts\\|.diary")
                       (buffer-name buffer))
                  (save-excursion
                    (set-buffer (buffer-name buffer))
                    (save-buffer))
                  (kill-buffer buffer)))
            (buffer-list))
    ;; These buffers will be reloaded by the code that uses them.
    (mapcar #'(lambda (name)
                (let ((buffer (get-buffer name)))
                  (when buffer (kill-buffer buffer))))
            '(".contacts" ".diary"))
    (save-buffers-kill-emacs)))

;;; In comint modes the [up] and [down] keys will be mapped to this
;;; two functions and will use the history only when the point is at
;;; the command line.  In any other place the [up] and [down] keys
;;; will behave as usual, i.e. move the point to the previous or next
;;; line.  Smart, eh?
(defun smart-comint-up ()
  "Implement the behaviour of the up arrow key in comint mode.  At
the end of buffer, do comint-previous-input, otherwise just move in
the buffer."
  (interactive)
  (let ((previous-region-status (if xemacs-flag (region-active-p) nil)))
    (if (= (point) (point-max))
        (comint-previous-input 1)
      (previous-line 1))
    (when previous-region-status
      (activate-region))))

(defun smart-comint-down ()
  "Implement the behaviour of the down arrow key in comint mode.  At
the end of buffer, do comint-next-input, otherwise just move in the
buffer."
  (interactive)
  (let ((previous-region-status (if xemacs-flag (region-active-p) nil)))
    (if (= (point) (point-max))
        (comint-next-input 1)
      (forward-line 1))
    (when previous-region-status
      (activate-region))))

;;; Set up the smart comint arrow keys.  See smart-comint-up/down.
(defun setup-smart-comint-arrow-keys ()
  "Set up the smart comint arrow keys.  See smart-comint-up/down."
  (local-set-key [up] 'smart-comint-up)
  (local-set-key [down] 'smart-comint-down))

;;; This hook will be called when entering several `comint' modes:
;;; 'gud/gdb', `shell', `term', `ielm', `tex-shell'.
(mapcar #'(lambda (hook) (add-hook hook 'setup-smart-comint-arrow-keys))
        (list 'gdb-mode-hook 'shell-mode-hook 'term-mode-hook
              'ielm-mode-hook 'tex-shell-hook))

;;; Yes, we want these global, but only after `gud' is loaded.
(when (fboundp 'gdb)
  (add-hook
   'gdb-mode-hook
   #'(lambda ()
       (global-set-key [f7] (if (fboundp 'gud-step) 'gud-step 'gdb-step))
       (global-set-key [f8] (if (fboundp 'gud-next) 'gud-next 'gdb-next)))))

;;; It is better to go to the next line here because this way we can
;;; call this with a numeric argument.
(defun delete-trailing-spaces (arg)
  "Remove all the tabs and spaces at the end of lines."
  (interactive "p")
  (while (> arg 0)
    (end-of-line nil)
    (delete-horizontal-space)
    (forward-line 1)
    (decf arg 1)))

;;; Remove all the tabs and spaces at the end of the lines.
(defun buffer-delete-trailing-spaces ()
  "Remove all the tabs and spaces at the end of all the lines in the buffer."
  (interactive)
  (message "Deleting trailing spaces...")
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (delete-trailing-spaces 1)))
  (message "Deleting trailing spaces... done"))

(defun buffer-menu-line-3 ()
  "Just like buffer-menu, but jump on line 3."
  (interactive)
  (buffer-menu)
  (goto-line 3))

;;; Bind major modes to file types.
(setq auto-mode-alist
      (append '(("\\.C$"                . c++-mode)
                ("\\.cc$"               . c++-mode)
                ("\\.CC$"               . c++-mode)
                ("\\.c\\+\\+$"          . c++-mode)
                ("\\.C\\+\\+$"          . c++-mode)
                ("\\.cpp$"              . c++-mode)
                ("\\.CPP$"              . c++-mode)
                ("\\.cxx$"              . c++-mode)
                ("\\.CXX$"              . c++-mode)
                ("\\.hh$"               . c++-mode)
                ("\\.H$"                . c++-mode)
                ("\\.c$"                . c-mode)
                ("\\.h$"                . c-mode)
                ("\\.l$"                . c-mode)
                ("\\.y$"                . c-mode)
                ("\\.s$"                . asm-mode)
                ("\\.S$"                . asm-mode)
                ("\\.f77$"              . fortran-mode)
                ("\\.F77$"              . fortran-mode)
                ("\\.f90$"              . fortran-mode)
                ("\\.F90$"              . fortran-mode)
                ("\\.hpf$"              . fortran-mode)
                ("\\.HPF$"              . fortran-mode)
                ("\\.html.in$"          . html-mode)
                ("\\.HTML.IN$"          . html-mode)
                ("\\.phtml$"            . html-mode)
                ("\\.PHTML$"            . html-mode)
                ("\\.phtml.in$"         . html-mode)
                ("\\.PHTML.IN$"         . html-mode)
                ("Makefile.*$"          . makefile-mode)
                ("makefile.*$"          . makefile-mode)
                ("\\.tex$"              . tex-mode)
                ("\\.texi$"             . texinfo-mode)
                ("\\.texinfo$"          . texinfo-mode)
                ("\\.el$"               . emacs-lisp-mode)
                ("\\.emacs\\.?.*$"      . emacs-lisp-mode)
                ("\\.pl$"               . my-perl-mode)
                ("\\.pm$"               . my-perl-mode)
                ("\\.sh$"               . sh-mode)
                ("\\.fqm$"              . mail-mode)
                ("\\.mail$"             . vm-mode-if-present)
                ("INBOX.*$"             . vm-mode-if-present)
                ("OUTBOX.*$"            . vm-mode-if-present)
                ("RMAIL.*$"             . rmail-mode)
                ("SMAIL.*$"             . rmail-mode)
                ("configure.in"         . autoconf-mode)
                ) auto-mode-alist))

(defun vm-mode-if-present ()
  "Use vm-mode if VM is available, otherwise use text-mode."
  (interactive)
  (if (featurep 'vm)
      (vm-mode)
    (text-mode)))

(defun line-to-top-of-window ()
  "Scroll current line to top of window."
  (interactive)
  (recenter 0))

;;; Scroll current line to botton of window.  If running XEmacs, the
;;; last line might not be completely visible, so we will avoid
;;; positioning on it.
(defun line-to-bottom-of-window ()
  "Scroll current line to bottom of window."
  (interactive)
  (recenter (- (window-height) (if (and xemacs-flag window-system) 3 2))))

(defun buffer-untabify ()
  "Convert all tabs in buffer with multiple spaces, preserving columns."
  (interactive)
  (message "Untabifying buffer...")
  (untabify (point-min) (point-max))
  (message "Untabifying buffer... done"))

;;; Tabifying is a good thing as long as it is used *ONLY* for
;;; indentation.  Otherwise it will affect strings as well, which is a
;;; _VERY BAD THING_!!!  Therefore we have to call tabify for each
;;; line... and is so slowwwww!
(defun buffer-smart-tabify ()
  "Convert multiple spaces in buffer into tabs, preserving columns."
  (interactive)
  (progn-compiled
   (message "Tabifying buffer...")
   (save-excursion
     (goto-char (point-min))
     (let ((percent 0) (old-percent 0) (indent-tabs-mode nil)
           (characters (- (point-max) (point-min))) (line 1)
           b e column)
       (while (not (eobp))
         (goto-line line)
         (beginning-of-line)
         (when (looking-at "[ \t]*")
           (setq b (match-beginning 0)
                 e (match-end 0))
           (unless (eq e b)
             (goto-char e)
             (setq column (current-column))
	     (unless (equal (buffer-substring b e) (make-string (- e b) ?\ ))
	       (delete-region b e)
	       (indent-to column))))
         (setq percent (/ (* 100 (point)) characters))
         (when (> percent old-percent)
           (message "Tabifying buffer... (%d%%)" percent))
         (setq old-percent percent)
         (end-of-line)
         (setq line (1+ line)))))
   (message "Tabifying buffer... done")))

(defun buffer-beautify ()
  "Calls both buffer-delete-trailing-spaces and buffer-smart-tabify."
  (interactive)
  (message "Cleaning up buffer...")
  (buffer-delete-trailing-spaces)
  (buffer-smart-tabify)
  (message "Cleaning up buffer... done"))

(defun prev-error ()
  "Visit the previous compilation error message and corresponding source code.
See next-error."
  (interactive)
  (next-error -1))

(defun persistent-dired (arg)
  "A version of `find-file' that can retry `arg' times on failure.
After that, it asks for permission before attempting another set of
`arg' retries, etc."
  (interactive "p")
  (when (< arg 1) (setq arg 1))
  (let ((cnt arg) filename)
    (if (fboundp 'ffap)
        (setq filename (ffap-prompter)))
    (if (not filename)
        (setq filename (read-from-minibuffer "Find file or URL: ")))
    (while (equal (condition-case nil
                      (if (fboundp 'ffap)
                          (find-file-at-point filename)
                        (find-file filename)) (error nil)) nil)
      (when (equal (decf cnt) 0)
        (setq cnt arg)
        (unless (y-or-n-p "Retry?")
          (error "Failed"))))))

;;; Key bindings.
(global-set-key [up] 'previous-line)
(global-set-key [down] 'next-line)
(global-set-key [right] 'forward-char)
(global-set-key [left] 'backward-char)
(global-set-key [prior] 'scroll-down)
(global-set-key [next] 'scroll-up)
(global-set-key [home] 'beginning-of-line)
(global-set-key [begin] 'beginning-of-line)
(global-set-key [end] 'end-of-line)
(global-set-key [select] 'kill-ring-save-and-deactivate-mark)
(global-set-key [insertchar] 'overwrite-mode)
(global-set-key [kp-9] 'scroll-down)
(global-set-key [kp-3] 'scroll-up)
(global-set-key [kp-7] 'beginning-of-line)
(global-set-key [kp-1] 'end-of-line)
(global-set-key [f1] 'buffer-menu-line-3)
(global-set-key [kp-f1] 'buffer-menu-line-3)
(global-set-key [f2] 'save-buffer)
(global-set-key [kp-f2] 'save-buffer)
(global-set-key [f3] 'hexl-mode)
(global-set-key [kp-f3] 'hexl-mode)
(global-set-key [f4] 'kill-buffer)
(global-set-key [kp-f4] 'kill-buffer)
(global-set-key [f5] 'delete-other-windows)
(global-set-key [f6] 'other-window)
(global-set-key [f8] 'cvs-update)
(global-set-key [f9] 'compile)
(global-set-key [f10] 'calendar)
(global-set-key [f11] #'(lambda () (interactive) (dired "~/mail/draft")))
(global-set-key [f12] (if (fboundp 'vm) 'vm 'rmail))
(global-set-key "\C-m" 'newline-and-indent)
(global-set-key "\C-j" 'newline)
(global-set-key "\M-\r" 'complete)
(global-set-key "\M-[H" 'beginning-of-line)
(global-set-key "\M-[F" 'end-of-line)
(global-set-key "\M-Ow" 'end-of-line)
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-x\C-c" 'kill-frame)
(global-set-key "\C-c\C-c" 'comment-region)
(global-set-key "\C-c\C-o" 'oo-browser)
(global-set-key [(shift up)] 'prev-error)
(global-set-key [(shift down)] 'next-error)


;;; C-c LETTER key bindings are reserved for users.
(global-set-key "\C-c " 'set-mark-command)
(global-set-key "\C-cC" 'calendar)
(global-set-key "\C-cu" 'buffer-untabify)
(global-set-key "\C-cT" 'buffer-smart-tabify)
(global-set-key "\C-cD" 'buffer-delete-trailing-spaces)
(global-set-key "\C-cB" 'buffer-beautify)
(global-set-key "\C-cb" 'buffer-menu-line-3)
(global-set-key "\C-c$" 'flyspell-mode)
(global-set-key "\C-cF" 'persistent-dired)
(global-set-key "\C-cf" 'line-to-top-of-window)
(global-set-key "\C-cl" 'line-to-bottom-of-window)
(global-set-key "\C-cS" 'tags-search)
(global-set-key "\C-cR" 'tags-query-replace)
(global-set-key "\C-cm" 'compile)
(global-set-key "\C-cd" 'gdb)
(global-set-key "\C-cU" 'rename-uniquely)
(global-set-key "\C-cH" 'hexl-mode)
(global-set-key "\C-c[" 'next-error)
(global-set-key "\C-c]" 'prev-error)
(global-set-key "\C-cn" 'gnus)
(global-set-key "\C-cq" 'feedmail-queue-reminder)
(global-set-key "\C-cs" 'term)
(global-set-key "\C-cw" 'what-line)
(global-set-key "\C-ch" 'font-lock-fontify-buffer)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This section takes care of initializations that can be done in ;;;
;;; both Emacsen, but in different ways.                           ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Differentiate between `backspace' and `delete'.
(if xemacs-flag
    (setq delete-key-deletes-forward t)
  (global-set-key [deletechar] 'delete-char)
  (global-set-key [delete] 'delete-char))

;;; Shift-tab inserts a tab.  Useful when tab does indentation.
(if xemacs-flag
    (global-set-key [iso-left-tab] #'(lambda () (interactive) (insert ?\t)))
  (global-set-key [S-iso-lefttab] #'(lambda () (interactive) (insert ?\t))))

;;; The number of lines in the `Messages' buffer.
(if xemacs-flag
    (setq log-message-max-size 1000)
  (setq message-log-max 1000))

;;; `auto-compression-mode' screws VM.
(if gnuemacs-flag
    (auto-compression-mode 1)
  (if (tryload 'crypt)
      (setq crypt-encryption-type 'pgp
            crypt-confirm-password t
            crypt-never-ever-decrypt t)))

;;; Make sure reaching end/beginning of buffer does not deactivate
;;; the region when using `scroll-up' & `scroll-down'.
;; (when xemacs-flag
;;   (defadvice scroll-up (around scroll-up freeze)
;;     (interactive "_P")
;;     (let ((zmacs-region-stays t))
;;       (if (interactive-p)
;;           (condition-case nil ad-do-it
;;             (end-of-buffer (goto-char (point-max))))
;;         ad-do-it)))
;;   (defadvice scroll-down (around scroll-down freeze)
;;     (interactive "_P")
;;     (let ((zmacs-region-stays t))
;;       (if (interactive-p)
;;           (condition-case nil ad-do-it
;;             (beginning-of-buffer (goto-char (point-min))))
;;         ad-do-it)))
;;   (when (featurep 'dired)
;;     (defadvice dired-scroll-up (around dired-scroll-up freeze)
;;       (interactive "_P")
;;       (let ((zmacs-region-stays t))
;;         (if (interactive-p)
;;             (condition-case nil ad-do-it
;;               (end-of-buffer (goto-char (point-max))))
;;           ad-do-it)))
;;     (defadvice dired-scroll-down (around dired-scroll-down freeze)
;;       (interactive "_P")
;;       (let ((zmacs-region-stays t))
;;         (if (interactive-p)
;;             (condition-case nil ad-do-it
;;               (beginning-of-buffer (goto-char (point-min))))
;;           ad-do-it)))))

;;; GNU Emacs stuff that doesn't exist under XEmacs + some fixes.
(when gnuemacs-flag
  (transient-mark-mode 1)
  (setq mark-even-if-inactive t)
  (when window-system (mouse-avoidance-mode 'animate))
  (menu-bar-mode (if window-system 1 -1))
  (defun build-mail-aliases () (build-mail-abbrevs))
  (add-hook 'mail-setup-hook 'mail-abbrevs-setup)
  (add-hook 'mail-setup-hook
            #'(lambda ()
                (substitute-key-definition
                 'next-line 'mail-abbrev-next-line
                 mail-mode-map global-map)
                (substitute-key-definition
                 'end-of-buffer 'mail-abbrev-end-of-buffer
                 mail-mode-map global-map)))
  ;; GNU Emacs insists on placing the cursor at the beginning of the
  ;; line when walking through the history.  RMS argues that this way
  ;; one can kill the entire line with a signel C-k.  BS.
  ;; (defadvice next-history-element (after next-history-element freeze)
  ;;   (interactive "p")
  ;;   (end-of-line))
  ;; (defadvice previous-history-element (after previous-history-element freeze)
  ;;   (interactive "p")
  ;;   (end-of-line))
  ;; )
  )

;;; XEmacs stuff that doesn't work under GNU Emacs.
(when xemacs-flag
  (setq igrep-use-zgrep t)
  (setq use-dialog-box nil)
  (setq-default ps-print-color-p nil)
  (setq-default ps-paper-type 'a4)
  (set-glyph-image modeline-pointer-glyph "leftbutton")
  (add-hook 'shell-mode-hook 'install-shell-fonts)
  (global-set-key "\C-xrd" 'delete-rectangle)
  (global-set-key '(shift button1) 'mouse-track-do-rectangle)

  (when (fboundp 'center-to-window-line)
    (global-set-key "\C-l" 'center-to-window-line))

  ;; Use colors if $COLORTERM is defined.
  (when (and (getenv "COLORTERM") (eq 'tty (device-type)))
    (set-device-class nil 'color))

  ;; Configure the menus.
  (setq font-menu-ignore-scaled-fonts nil
        buffers-menu-submenus-for-groups-p t
        complex-buffers-menu-p t)

  ;; Change the continuation glyph face so it stands out more
  (and (fboundp 'set-glyph-property)
       (boundp 'continuation-glyph)
       (set-glyph-property continuation-glyph 'face 'bold))

  ;; Activate the Mail & News buttons on the toolbar.
  (when (fboundp 'vm) (setq toolbar-mail-reader 'vm))
  (when (fboundp 'gnus) (setq toolbar-news-reader 'gnus))

  ;; Prevent the info & news toolbar buttons from creating new frames.
  (when (fboundp 'info) (defun toolbar-info () (interactive) (info)))
  (when (fboundp 'gnus) (defun toolbar-news () (interactive) (gnus)))

  (global-set-key [(control x) T]
    #'(lambda () (interactive)
        (set-specifier default-toolbar-visible-p
                       (not (specifier-instance
                             default-toolbar-visible-p)))))

  (add-hook 'dired-mode-hook
            #'(lambda ()
                (unless window-system
                  (set-face-background 'dired-face-marked "blue")
                  (set-face-background 'dired-face-flagged "red")
                  (set-face-foreground 'dired-face-directory "magenta")
                  (set-face-foreground 'dired-face-permissions "white"))))
)



(defun cc-define-keys (map)
  (when (fboundp 'c-forward-into-nomenclature)
    (define-key map "\M-b" 'c-backward-into-nomenclature)
    (define-key map "\M-f" 'c-forward-into-nomenclature)
    (define-key map [(control left)] 'c-backward-into-nomenclature)
    (define-key map [(control right)] 'c-forward-into-nomenclature))
  (when (fboundp 'c-comment-edit)
    (define-key map "\C-cc" 'c-comment-edit))
  (when (fboundp 'c-beginning-of-defun)
    (define-key map "\C-\M-a" 'c-beginning-of-defun)
    (define-key map "\C-\M-e" 'c-end-of-defun)))

;;; Use a modified version of the BSD style for C, C++ & Java code.
;;; If you want to change the indentation, go to the line that is not
;;; indented the way you want and type `C-c C-o'.  Then `C-x ESC ESC'
;;; to find out what you need to add to your .emacs.
(add-hook 'c-mode-common-hook
          #'(lambda ()
              (c-set-style "BSD")
              (setq indent-tabs-mode nil)
              ;; New stuff added for XEmacs under RedHat 7.2 on some
              ;; machines (not all, for some reason).  Comment it out
              ;; if it doesn't work for you.
              (c-set-offset 'arglist-intro 4)
              (c-set-offset 'defun-block-intro 4)
              (c-set-offset 'access-label -6)
              (c-set-offset 'topmost-intro -4)
              (c-set-offset 'topmost-intro-cont -4)
              (c-set-offset 'statement-block-intro 4)
              (c-set-offset 'statement-cont 4)
              (c-set-offset 'statement-case-intro 4)
              (c-set-offset 'substatement 4)
              (c-set-offset 'inline-open -4)
              (c-set-offset 'member-init-intro 4)
              (c-set-offset 'brace-list-intro 4)
              ;; End of new stuff.
              (c-set-offset 'access-label -2)
              (c-set-offset 'case-label 2)
              (c-set-offset 'inher-intro 0)
              (c-set-offset 'label 2)
              (cc-define-keys c-mode-map)
              (cc-define-keys c++-mode-map)
              (cc-define-keys java-mode-map)))

(when (featurep 'font-lock)
  (setq font-lock-maximum-size nil
        font-lock-maximum-decoration t
        font-lock-auto-fontify t)
  (if (fboundp 'global-font-lock-mode)
      (global-font-lock-mode t)
    (add-hook 'mail-mode-hook 'turn-on-font-lock))
  (if (featurep 'lazy-shot)
      (progn
        (add-hook 'font-lock-mode-hook 'turn-on-lazy-shot)
        (setq lazy-shot-verbose nil
              lazy-shot-stealth-verbose nil
              lazy-shot-stealth-time 15))
    (when (featurep 'lazy-lock)
      (setq font-lock-support-mode 'lazy-lock-mode
            lazy-lock-stealth-time 15
            lazy-lock-stealth-verbose nil)))

  ;; Fontify some extra C & C++ keywords.
  (setq my-c-extra-keywords
        (list                           ; why is .+_t not working here???
         (cons (concat "\\<\\("
                       "[a-zA-Z_][a-zA-Z_0-9]*_t\\(\\|ype\\)\\|FILE\\|DIR"
                       "\\)\\>")
               'font-lock-type-face)))

  (setq my-c++-extra-keywords
        (list
         (cons (concat "\\<\\(" "typename\\|mutable\\|explicit\\|export\\|"
                       "string\\|vector\\|list\\|deque\\|stack\\|\\hash\\|"
                       "wstring\\|"
                       "\\(hash_\\|\\)\\(multi\\|\\)\\(set\\|map\\)\\|"
                       "\\(priority_\\|\\)queue\\|\\(.+_\\|\\)iterator"
                       "\\)\\>")
               'font-lock-type-face)))

  )


;;; Save the current desktop at exit, including all the non-nil global
;;; variables that end in `-history'.  They will be restored in the
;;; next emacs session.  Use M-x desktop-save in order to enable
;;; desktop saving.  THIS CODE SHOULD CLOSE TO THE END OF .emacs!
(when (featurep 'desktop)
  (progn-compiled
   (defun vhistoryp (symbol)
     (and (boundp symbol) (not (fboundp symbol)) (symbol-value symbol)
          (string-match ".*-history$" (symbol-name symbol)))))
  (add-hook 'desktop-save-hook
            #'(lambda ()
                (progn-compiled
                 (message "Saving desktop & history...")
                 (nconc desktop-globals-to-save
                        (mapcar #'intern
                                (delete "load-history"
                                        (all-completions "" obarray
                                                         #'vhistoryp))))
                 (message "Saving desktop & history... done"))))
  (setq desktop-missing-file-warning nil)
  (desktop-load-default)
  (setq history-length 250)
  (add-to-list 'desktop-globals-to-save 'file-name-history)
  (desktop-read))

;;; We don't need this annoying buffer, I think...
(condition-case nil (kill-buffer " *completion-save-buffer*") (error nil))

;;; .emacs ends here

;(load "blink-cursor")
;(blink-cursor-mode)
;(paren-activate)

;;************************************************************************
;;
;; local .emacs startup file for Computational Physics I
;; 
;; (c) Jens Dreger 1997
;;
;; uses the following keybindings:
;;
;; +-------+-----+----+----+ +-------+-------+-------+-------+
;; |   F1  |  F2 | F3 | F4 | |  F5   |   F6  |  F7   |  F8   |
;; |       |next |    |    | |new    |add to |kill   |comment|
;; |compile|error|    |    | |comment|comment|comment|block  |
;; +-------+-----+----+----+ +-------+-------+-------+-------+
;;
;;************************************************************************

;; Don't print the copyright message when emacs starts up.
(setq inhibit-startup-message t)

;; If you want to use your own emacs lisp files, add the path here
;;(setq load-path (append load-path '("/home/dreger/emacs/lisp")))

(setq Info-default-directory-list 
      (append Info-default-directory-list '("/usr/lib/teTeX/info/")))

;; Put time and load average in status lines.
;;(display-time)

;; Do not beep !
(setq visible-bell t)

;; Highlight matching parenthesis whenever the cursor is over a brace
(setq-default show-paren-mode t)
(setq-default case-fold-search t)
(setq-default case-replace t)

;; always use context highlighting
(setq-default global-font-lock-mode t)

;; enable syntax colorization
(setq-default font-lock-maximum-decoration t)
(setq-default font-lock-mode 1)
(setq-default line-number-mode 1)
(setq-default column-number-mode 1)

;; If you are using a windowing system such as X, you can cause the region
;; to be highlighted when the mark is active by:
(setq-default transient-mark-mode t)

;; Use delete-selection mode.
;; When ON, typed text replaces the selection if the selection is active.
;; When OFF, typed text is just inserted at point. This mode also allows
;; you to delete (not kill) the highlighted region by pressing DEL.
(setq-default delete-selection-mode t) 

;; configure c-mode
;(require 'cc-mode)

;;; ********************
;;; Load a partial-completion mechanism, which makes minibuffer completion
;;; search multiple words instead of just prefixes; for example, the command
;;; `M-x byte-compile-and-load-file RET' can be abbreviated as `M-x b-c-a RET'
;;; because there are no other commands whose first three words begin with
;;; the letters `b', `c', and `a' respectively.
;;;


(defun compile-source-command-line ()
  "Cut the compilation commandline from a source comment line like
/* compile with: gcc -o hello hello.c -lm */
If no such line can be found, use 'make -k' as compilation command."
  (interactive)
  (save-excursion
    (let ((compile-string)
	  (old-case-fold-search case-fold-search))
      (setq case-fold-search t)
      (goto-char (point-min))
      (if (re-search-forward "compile[ \t\n]*with:[ \t\n]*\\(.*\\)$" nil t)
	  (progn
	    (setq case-fold-search old-case-fold-search)
	    (setq compile-string (match-string 1))
	    (string-match "\\( \\|\\	\\)*\\(\\*/\\)?\\( \\|\\	\\)*$" compile-string)
	    (substring compile-string 0 (match-beginning 0)))
	(progn
	  (setq case-fold-search old-case-fold-search)
	  "make -k")))))

(defun save-get-command-and-compile ()
  "This function is meant to be bound to a key for easy compilation
of the source-file in the active (c-mode) buffer. It saves the active
buffer without asking for confirmation, then tries to cut the compilation
command-line from a 'compile with: ...' comment in the source file and
runs 'M-x compile' on that command."
  (interactive)
  (save-buffer)
  (compile (compile-source-command-line))
  )

(global-set-key "\C-cc" 'save-get-command-and-compile )
;(global-set-key "\C-DEL" 'kill-primary-selection )
;(global-set-key "\C-insert" 'yank-clipboard-selection )

(add-hook 'c-mode-common-hook
	  '(lambda ()
	     (define-key c-mode-base-map "\C-m" 'newline-and-indent)))

(add-hook 'c-mode-hook
	  '(lambda ()
;; key bindings for c-mode
	     (define-key global-map [f1 RET] 'save-get-command-and-compile )
	     (global-set-key 'f1 'save-get-command-and-compile )
	     (define-key global-map "\C-cc" 'save-get-command-and-compile )
	     (local-set-key 'f2 'next-error)
	     (local-set-key 'f3 'undo)
	     (local-set-key 'f4 'query-replace)
	     (local-set-key 'f5 'indent-for-comment)
	     (local-set-key 'f6 'indent-new-comment-line)
	     (local-set-key 'f7 'kill-comment)
	     (local-set-key 'f8 'comment-region)
;; don't ask about save when compiling
	     (setq compilation-ask-about-save nil)
;; don't ask for commandline when compiling
	     (setq compilation-read-command nil)
	     (setq compile-command "gmake -k")
;; we want comments like /* some text */ every comment line 
	     (setq comment-multi-line nil)))

(add-hook 'c-mode-hook 'turn-on-font-lock)

(setq c++-mode-hook c-mode-hook)

;; control TAB-behavior: indent only if before text
(setq c-tab-always-indent nil)

(setq font-lock-maximum-decoration '((html-mode . nil) (t . t)) )

;; if you don't like the default colors, put your favorite colors here
;(add-hook 'font-lock-mode-hook
;	  '(lambda ()
;	     (modify-face 'font-lock-comment-face "#cccc99" nil nil t nil nil)))



(put 'downcase-region 'disabled nil)


;; check wich Emacs we are running, and on which platform
(cond
 ((string-match "XEmacs" (emacs-version))
  (message "customizing XEmacs")
   
  ;; put all the XEmacs specific customization in here
;  (load-library "completer")

  ;; display the big menu bar
;  (load "big-menubar")

    ;;; ********************
    ;;; Font-Lock is a syntax-highlighting package.  When it is enabled and you
    ;;; are editing a program, different parts of your program will appear in
    ;;; different fonts or colors.  For example, with the code below, comments
    ;;; appear in red italics, function names in function definitions appear in
    ;;; blue bold, etc.  The code below will cause font-lock to automatically be
    ;;; enabled when you edit C, C++, Emacs-Lisp, and many other kinds of
    ;;; programs.
    ;;;
    ;;; The "Options" menu has some commands for controlling this as well.
    ;;;
  (require 'font-lock)

  (setq font-lock-use-default-fonts t)
  (setq font-lock-use-default-colors t)

    ;;; ********************
    ;;; Func-menu is a package that scans your source file for function
    ;;; definitions and makes a menubar entry that lets you jump to any
    ;;; particular function definition by selecting it from the menu.  The
    ;;; following code turns this on for all of the recognized languages.
    ;;; Scanning the buffer takes some time, but not much.
    ;;;
    ;;; Send bug reports, enhancements etc to:
    ;;; David Hughes <ukchugd@ukpmr.cs.philips.nl>
    ;;;
;  (require 'func-menu)
;  (define-key global-map 'f8 'function-menu)
;  (add-hook 'find-file-hooks 'fume-add-menubar-entry)
;  (define-key global-map "\C-cl" 'fume-list-functions)
;  (define-key global-map "\C-cg" 'fume-prompt-function-goto)
;  (when (featurep 'func-menu)
    ;; For descriptions of the following user-customizable variables,
    ;; type C-h v <variable>
;    (setq fume-max-items 25
;	  fume-fn-window-position 3
;	  fume-auto-position-popup t
;	  fume-display-in-modeline-p t
;	  fume-menubar-menu-location "File"
;	  fume-buffer-name "*Function List*"
;	  fume-no-prompt-on-valid-default nil)
;    (global-set-key "\C-cG" 'fume-prompt-function-goto)
;    (global-set-key "\C-cL" 'fume-list-functions)
;    (global-set-key "\C-cN" 'fume-goto-next-function)
;    (global-set-key "\C-cP" 'fume-goto-previous-function)
;    (if xemacs-flag
;	(global-set-key '(control button3) 'mouse-function-menu)
;      (global-set-key '(control mouse-3) 'mouse-function-menu))
;    (add-hook 'find-file-hooks 'fume-add-menubar-entry))
    
  ;; The Hyperbole information manager package uses (shift button2) and
  ;; (shift button3) to provide context-sensitive mouse keys.  If you
  ;; use this next binding, it will conflict with Hyperbole's setup.
  ;; Choose another mouse key if you use Hyperbole.
;  (define-key global-map '(shift button3) 'mouse-function-menu)

  ;; Options Menu Settings
  ;; =====================
  (cond
   ((and (string-match "XEmacs" emacs-version)
	 (boundp 'emacs-major-version)
	 (or (and
	      (= emacs-major-version 19)
	      (>= emacs-minor-version 14))
	     (= emacs-major-version 20))
	 (fboundp 'load-options-file))
    (load-options-file "/home/helge/.xemacs-options")
    ))
  ;; ============================
  ;; End of Options Menu Settings

  ;;==========================================================================
  ;;                    scroll on  mouse wheel
  ;;==========================================================================
    
  (define-key global-map 'button4
    '(lambda (&rest args)
       (interactive) 
       (let ((curwin (selected-window)))
	 (select-window (car (mouse-pixel-position)))
	 (scroll-down 5)
	 (select-window curwin)
	 )))
  (define-key global-map [(shift button4)]
    '(lambda (&rest args)
       (interactive) 
       (let ((curwin (selected-window)))
	 (select-window (car (mouse-pixel-position)))
	 (scroll-down 1)
	 (select-window curwin)
	 )))
  (define-key global-map [(control button4)]
    '(lambda (&rest args)
       (interactive) 
       (let ((curwin (selected-window)))
	 (select-window (car (mouse-pixel-position)))
	 (scroll-down)
	 (select-window curwin)
	 )))
      
  (define-key global-map 'button5
    '(lambda (&rest args)
       (interactive) 
       (let ((curwin (selected-window)))
	 (select-window (car (mouse-pixel-position)))
	 (scroll-up 5)
	 (select-window curwin)
	 )))
  (define-key global-map [(shift button5)]
    '(lambda (&rest args)
       (interactive) 
       (let ((curwin (selected-window)))
	 (select-window (car (mouse-pixel-position)))
	 (scroll-up 1)
	 (select-window curwin)
	 )))
  (define-key global-map [(control button5)]
    '(lambda (&rest args)
       (interactive) 
       (let ((curwin (selected-window)))
	 (select-window (car (mouse-pixel-position)))
	 (scroll-up)
	 (select-window curwin)
	 )))
					; XEmacs specific stuff ends here
  )
 ((string-match "GNU" (emacs-version))
  (message "customizing GNU Emacs")
					; put all the GNU Emacs specific customization in here
					; do the things which depend on the OS:
  (cond 
   ((string-match "linux" system-configuration)
    (message "customizing GNU Emacs for Linux")
					; anything special about Linux begins here 

					; and ends here
    )
   ((string-match "freebsd" system-configuration)
    (message "customizing GNU Emacs for FreeBSD")
					; anything special about Linux begins here 

					; and ends here
    )
   ((string-match "nt4" system-configuration)
    (message "customizing GNU Emacs for Win NT")
					; anything special about Windows
    )
					; anything special for the OS ends here
   )
					; GNU Emacs specific stuff ends here
  )
 )

;; Automatic (un)compression on loading/saving files (gzip(1) and similar)
;; We start it in the off state, so that bzip2(1) support can be added.
;; Code thrown together by Ulrik Dickow for ~/.emacs with Emacs 19.34.
;; Should work with many older and newer Emacsen too.  No warranty though.
;;
;;(if (fboundp 'auto-compression-mode) ; Emacs 19.30+
;;    (auto-compression-mode 0)
;;  (require 'jka-compr)
;;  (toggle-auto-compression 0))
;; Now add bzip2 support and turn auto compression back on.
;;(add-to-list 'jka-compr-compression-info-list
;;             ["\\.bz2\\(~\\|\\.~[0-9]+~\\)?\\'"
;;             "zipping"        "bzip2"         ()
;;              "unzipping"      "bzip2"         ("-d")
;;              nil t])
;;(toggle-auto-compression 1 t)

(custom-set-faces
 '(default ((t (:size "13pt" :family "Courier"))) t))
(custom-set-variables)
