;;; init.el --- Initialization Configuration for Emacs

;;; Commentary:
;;; Leon's initalization of Emacs

;;; Code:
;; Enables C-x n n to do narrow-to-region.
;;         C-x n w to widen-to-region again
(put 'narrow-to-region 'disabled nil)
;; Pressing "a" in Dired visits the directory/file and kills the previous buffer.
;; That is much better than pressing RET and leaving DIRED buffers open.
(put 'dired-find-alternate-file 'disabled nil)
;; Make C-z (suspend-frame) do nothing
(defun suspend-frame() "Disable this function." (interactive) )

;; Global keybindings
(global-set-key (kbd "M-n")     'forward-paragraph)
(global-set-key (kbd "M-p")     'backward-paragraph)

;; Various user configuration
(setq user-full-name "Leon Wang"
      user-mail-address "leongwang@arista.com"
      custom-file "~/.emacs.d/custom.el"
      ;; Makes lsp-mode faster by changing read-process-output-max
      ;; from the default 4 KB to 1 MB
      read-process-output-max (* 1024 1024)
      ;; Make lsp-mode faster by increasing the garbage collector threshold.
      gc-cons-threshold 800000
      gc-cons-percentage 0.1)

;; Load ~/.emacs.d/custom.el if it exists.
(when (file-exists-p custom-file)
  (load custom-file))

;; Set default font-size
(set-face-attribute 'default nil :height 140)

;; Set default bidirectional direction to reduce long-line handling burden.
(setq-default bidi-paragraph-direction 'left-to-right)
(if (version<= "27.1" emacs-version)
    ;; Turn off bidirectional parentheses algorithm (bpa) to reduce long-line handling burden.
    (setq bidi-inhibit-bpa t)
    ;; Automatically detect long-lines and replace all modes with so-long-mode to
    ;; greatly speed up long-line handling.
    (global-so-long-mode 1))

;; Turn on line numbering
;;   The number of columns needed to display line numbers should only grow
;;   to minimize visual stuttering.
(setq-default display-line-numbers-grow-only t)
(global-display-line-numbers-mode)
;; Turn on column numbering
(column-number-mode)
;; Turn on fill column mode
;;   Set fill-column to 80
(setq-default fill-column 80)
(global-display-fill-column-indicator-mode)

;; Show trailing whitespace unless text and prog-mode
(defun my-show-trailing-whitespace ()
  "Do as function name say."
  (setq show-trailing-whitespace t))
(add-hook 'text-mode-hook #'my-show-trailing-whitespace)
(add-hook 'prog-mode-hook #'my-show-trailing-whitespace)

;; Turn on battery percentage
(display-battery-mode)
;; Turn on display time
;;   Remove load average from display time
(setq-default display-time-default-load-average nil)
(display-time-mode)

;; Set default "M-x shell" to Brew-installed Bash
(setq-default explicit-shell-file-name "/usr/local/bin/bash")
;; Set default "M-x shell-command" to Brew-installed Bash
(setq shell-file-name "/usr/local/bin/bash")

;; Issue with Emacs 27.2 + MacOS having the wrong TLS algorithm priority
;; to connect to Emacs package repositories.
(when (and (equal emacs-version "27.2")
           (eql system-type 'darwin))
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))
;; Emacs package repositories.
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("MELPA" . "https://melpa.org/packages/")))
;; After Emacs 27.0, package-initialize is called
;; automatically before loading init.el
(when (version< emacs-version "27.0")
  ;; package-initialize will refresh deleted packages in M-x list-packages.
  (package-initialize))

;; Portable 'use-package shim
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Exec-path-from-shell ensures environment variables inside Emacs
;; look the same as in the user's shell.
;; When loading GUI Emacs on OS X and Linux, take $PATH, $MANPATH from shell,
;; and set exec-path to $PATH.
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  ;; Manually set $SHELL environment variable to brew-installed bash because
  ;; Emacs doesn't play well with brew-installed zsh's custom theme.
  (setenv "SHELL" "/usr/local/bin/bash")
  (exec-path-from-shell-initialize)
  ;; Additionally also take $GOPATH and $PYTHONPATH from shell.
  (exec-path-from-shell-copy-env "GOPATH")
  (exec-path-from-shell-copy-env "PYTHONPATH"))

;; Solarized-theme is a popular low-contrast theme.
(use-package solarized-theme
  :config
  (load-theme 'solarized-dark t))

;; Diminish hides or abbreviates minor modes.
;; Can be used as :diminish keyword in use-package
(use-package diminish)

;; Smart Mode Line is a sexy mode-line for Emacs.
(use-package smart-mode-line
  :config
  (setq sml/theme 'respectful)
  (setq sml/no-confirm-load-theme t)
  ;; Add a % sign to battery display
  (setq sml/battery-format " %p%% ")
  (setq sml/shorten-directory t)
  ;; Path name takes up a maximum of 33 characters
  (setq sml/name-width 33)
  (setq sml/shorten-modes t)
  ;; Right-justify anything after the (minor-)mode-list
  (setq sml/mode-width 'full)
  ;; Filler Hack for Emacs Version 29.1 since the right-justification doesn't work properly.
  (setq sml/extra-filler -5)
  ;; Add abbreviation to common working paths
  (add-to-list 'sml/replacer-regexp-list '("^~/go/src/arista/" ":GAr:") t)
  (add-to-list 'sml/replacer-regexp-list '("^:GAr:gopenconfig/" ":GArOc:") t)
  (add-to-list 'sml/replacer-regexp-list '("^:GArOc:eos/mapping/" ":GArOcMap:") t)
  (sml/setup))

;; Buffer-move moves buffers around.
(use-package buffer-move
  :bind (("M-s u" . buf-move-up)
	 ("M-s d" . buf-move-down)
	 ("M-s l" . buf-move-left)
	 ("M-s r" . buf-move-right)))

;; Switch-window provides a visual way to switch windows.
(use-package switch-window
  :bind ("C-x o" . switch-window)
  :config
  (setq switch-window-shortcut-style 'qwerty)
  (setq switch-window-threshold 2)
  (setq switch-window-minibuffer-shortcut ?z))

;; Smartparens tries to smartly deal with parentheses pairs in Emacs.
(use-package smartparens
  :hook ((prog-mode text-mode) . smartparens-mode)
  :config
  (require 'smartparens-config) ;; default smartparens config
  :diminish smartparens-mode)

;; Flycheck a modern on-the-fly syntax checking extension.
(use-package flycheck
  :config
  (use-package flycheck-pos-tip)
  :hook ((after-init . global-flycheck-mode)
         (after-init . flycheck-pos-tip-mode))
  :diminish flycheck-mode)

;; Flyspell performs on-the-fly spelling checking.
(use-package flyspell
  :if (executable-find "aspell")
  :config
  (setq ispell-program-name "aspell")
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :diminish flyspell-mode)

;; Flyspell-correct provides several functions to start the correction process.
(use-package flyspell-correct
  :after (flyspell ivy)
  :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper))
  :config
  ;; Flyspell-correct-ivy uses the Ivy interface for flyspell-correct.
  (use-package flyspell-correct-ivy))

;; Company is a text completion framework for Emacs.
(use-package company
  :hook (after-init . global-company-mode)
  :init
  (setq company-idle-delay 0
	company-selection-wrap-around t
	company-show-numbers t)
  :diminish company-mode)

;; Ivy + Counsel + Swiper
;; Ivy is a generic completion mechanism + UI for Emacs
(use-package ivy
  :init (ivy-mode)
  :diminish ivy-mode
  :config
  ;; Flx is a fuzzy matching engine.
  (use-package flx :defer t)
  (setq ivy-height 20 ;; show 20 results
	;; Add Recentf and bookmarks to ivy-switch-buffer
	ivy-use-virtual-buffers t
	;; Use default regex match engine in swiper and counsel-projectile-rg,
	;; and flx fuzzy match engine for all other completion.
	ivy-re-builders-alist '((swiper . ivy--regex-plus)
				(counsel-rg . ivy--regex-plus)
                                (t . ivy--regex-fuzzy)))

  ;; Counsel is a collection of Ivy-enhanced versions of common Emacs commands.
  (use-package counsel
    :init (counsel-mode)
    :diminish counsel-mode
    :bind
    ;; Semantic mode not enabled, so only provide imenu
    ("M-o" . counsel-semantic-or-imenu)
    :config
    ;; Change default from match string beginnings to match substrings
    (setq ivy-initial-inputs-alist nil
	  ivy-height-alist '((counsel-yank-pop . 10))
	  counsel-yank-pop-separator "\n--\n"
	  ;; Counsel-imenu jump to definition when selecting candidates.
	  ivy-update-fns-alist '((counsel-imenu . auto)))
    ;; Amx is a forked version of Smex or Smart-enhanced "M-x"
    ;; Amx sorts "M-x" commands by last-used
    (use-package amx
      :demand t))

  ;; Swiper is an alternative to isearch that uses ivy to show
  ;; an overview of all matches.
  (use-package swiper
    :bind ("C-s" . swiper)
    :config
    ;; For some reason ivy-configure for swiper is not working without manually
    ;; setting it in init.el.
    (ivy-configure 'swiper
      :occur #'swiper-occur
      :update-fn #'swiper--update-input-ivy
      :unwind-fn #'swiper--cleanup
      :index-fn #'ivy-recompute-index-swiper))

  ;; Use Ivy as the interface to select from xref candidates.
  (use-package ivy-xref
  :init
  ;; xref initialization is different in Emacs 27 - there are two different
  ;; variables which can be set rather than just one
  (when (>= emacs-major-version 27)
    (setq xref-show-definitions-function #'ivy-xref-show-defs))
  ;; Necessary in Emacs <27. In Emacs 27 it will affect all xref-based
  ;; commands other than xref-find-definitions (e.g. project-find-regexp)
  ;; as well
  (setq xref-show-xrefs-function #'ivy-xref-show-xrefs)))

;; Projectile is a project interaction library for Emacs.
(use-package projectile
  :init
  (projectile-mode)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (add-to-list 'projectile-globally-ignored-directories "vendor")
  :config
  ;; Counsel-projectile provides further ivy integration into Projectile.
  (use-package counsel-projectile
    :init (counsel-projectile-mode)
    :bind (("C-x b" . counsel-projectile)
	   ("M-i" . counsel-projectile-rg)))
  :diminish projectile-mode)

;; Which-key is a minor mode for Emacs that displays the key bindings
;; following your currently entered incomplete command (a prefix) in a popup.
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode)

;;; YAML-major-mode
;; YAML-mode is a Emacs mode for YAML (Yet Another Markup Language)
(use-package yaml-mode :defer t
  :init (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode)))

;;; JSON-major-mode
;; JSON-mode is a major mode for editing JSON files.
(use-package json-mode :defer t
  :init (add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode)))

;; lsp-mode is Language Server Protocol support for Emacs
(use-package lsp-mode
  :custom
  (lsp-auto-guess-root t)
  (lsp-enable-file-watchers nil)
  (lsp-imenu-sort-methods '(position))
  (lsp-restart 'ignore)
  (lsp-response-timeout 2)
  :config
  (lsp-register-custom-settings
   '(("gopls.completeUnimported" t t) ;; autocomplete unimported packages
     ("gopls.staticcheck" t t))))     ;; enables analyses from staticcheck.io.

;;; Python-major-mode
;; lsp-python-ms is a lsp-mode client leveraging Microsoft’s
;; python-language-server.
(use-package lsp-python-ms
  :init (setq lsp-python-ms-auto-install-server t)
  :hook (python-mode . (lambda ()
                          (require 'lsp-python-ms)
                          (lsp))))

;;; Go-major-mode
(unless (getenv "GOPATH")
  (setenv "GOPATH" "/Users/leongwang/go"))

;; Go-mode is the Emacs mode for editing Go code.
(use-package go-mode
  :defer t
  :hook ((go-mode . (lambda ()
                      (add-hook 'before-save-hook
                                #'lsp-format-buffer t t)
                      (add-hook 'before-save-hook
                                #'lsp-organize-imports t t )))
         (go-mode . lsp)
         (go-dot-mod-mode . lsp))
  :config
  (defun leongwang/go-mode-setup ()
    ;; workaround for imenu not matching multiline signatures
    ;; https://github.com/dominikh/go-mode.el/issues/57
    (setq-local imenu-generic-expression
                '(("type" "^type *\\([^ \t\n\r\f]*(\\)" 1)
                  ("func" "^func \\(.*\\)(" 1)))
    ;; Set tab-width to 4 spaces
    (setq tab-width 4))
  (add-hook 'go-mode-hook #'leongwang/go-mode-setup))

;; Magit is a git porcelain inside Emacs.
(use-package magit
  :bind
  ("C-c g" . magit-status)
  :config
  (defun magit-push-to-gerrit-corp ()
    (interactive)
    (magit-git-command-topdir "git push origin HEAD:refs/for/master"))
  (defun magit-push-to-horseland-gerrit ()
    (interactive)
    (magit-git-command-topdir "git push origin HEAD:refs/for/main"))
  (transient-append-suffix 'magit-push "m"
    '("g" "Push to gerrit.corp" magit-push-to-gerrit-corp))
  (transient-append-suffix 'magit-push "g"
    '("h" "Push to horseland-gerrit" magit-push-to-horseland-gerrit)))

;;; init.el ends here
