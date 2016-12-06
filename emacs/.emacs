;;; XEmacs backwards compatibility file
(desktop-save-mode 1)
(setq desktop-load-locked-desktop t)
(tool-bar-mode -1) 
(setq user-init-file
      (expand-file-name "init.el"
			(expand-file-name ".xemacs" "~")))
(setq custom-file
      (expand-file-name "custom.el"
			(expand-file-name ".xemacs" "~")))

(load-file user-init-file)
(load-file custom-file)
