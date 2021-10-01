;; *** Startup file for GNU Emacs 27 (Windows + Cygwin) ***

;; Benchmark calls to 'require' and 'load' functions
(use-package benchmark-init
  :config
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

;; Measure init time
(add-to-list 'after-init-hook
             (lambda ()
               (message (format "Init time: %.2fs"
                                (string-to-number (substring (emacs-init-time) 0 -8))))))

;; Package repositories
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))

;; Set the option to t to enable backtrace
(setq debug-on-error nil)

;; Prefer UTF-8 (affects markdown-preview, at least)
(prefer-coding-system 'utf-8)

;; Default start directory
(cd "~")

;; Path to manually installed packages
(defvar site-lisp (concat user-emacs-directory "site-lisp/"))
(add-to-list 'load-path site-lisp)

;; Keep automated customizations in a separate file
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file t)

;; Save history
(setq savehist-save-minibuffer-history t
      history-delete-duplicates t)
(savehist-mode 1)

;; Recent files
(recentf-mode)

;; Save session
(desktop-save-mode)

;; Save place
(save-place-mode 1)

;; Ignore some files for backup
;; https://emacs.stackexchange.com/questions/2082/turn-off-automatic-backups-for-specific-files
(defvar my-backup-ignore-regexps (list "\\.emacs\\.desktop" "\\.recentf")
  "List of filename regexps not to back up.")

(defun my-backup-enable-p (name)
  "Filter certain file backups."
  (when (normal-backup-enable-predicate name)
     (let ((backup t))
      (mapc (lambda (re)
              (setq backup (and backup (not (string-match re name)))))
            my-backup-ignore-regexps)
      backup)))

(setq backup-enable-predicate 'my-backup-enable-p)

;; Font & frame size
(set-frame-font "Lucida Console 12" t)
(setq default-frame-alist '((top . 50) (left . 75) (width . 110) (height . 42)))

;; Colours
(set-background-color "#E8E8E8")

;; Display column number on modeline
(setq column-number-indicator-zero-based nil)
(column-number-mode t)

;; Title bar format (buffer name, full file name)
(setq frame-title-format "[%b] %f")

;; Display date and time in the mode line
(setq display-time-format "%Y-%m-%d [%H:%M]"
      display-time-default-load-average nil)
(display-time)

;; Load abbreviations table
(setq-default abbrev-mode t)
(setq abbrev-file-name (concat user-emacs-directory ".abbrev_defs"))

;; Bash shell
(setq explicit-shell-file-name "bash")

;; Shell hacks (http://www.khngai.com/emacs/cygwin.php)
(add-hook 'shell-mode-hook
          (lambda ()
            (local-set-key '[up] 'comint-previous-input)
            (local-set-key '[down] 'comint-next-input)
            ;; Search command history based on what's already typed
            (local-set-key '[(shift tab)] 'comint-next-matching-input-from-input)))

;; F9 = start a shell (and delete other windows); C-u F9 = start another shell
;; https://www.emacswiki.org/emacs/ShellMode
(defun alt-shell-dwim (arg)
  (interactive "P")
  (let* ((shell-buffer-list
          (let (blist)
            (dolist (buff (buffer-list) blist)
              (when (string-match "^\\*shell\\*" (buffer-name buff))
                (setq blist (cons buff blist))))))
         (name (if arg
                   (generate-new-buffer-name "*shell*")
                 (car shell-buffer-list))))
    (shell name)
    (delete-other-windows)))

(global-set-key [f9] 'alt-shell-dwim)

;; Scroll only one line when moving past the bottom of the screen
(setq scroll-step 1)

;; Buffer switching: https://github.com/joostkremers/nswbuff
(use-package nswbuff
  :config
  (setq nswbuff-display-intermediate-buffers t)
  (setq nswbuff-clear-delay 2)
  (setq nswbuff-recent-buffers-first nil)
  (global-set-key (kbd "C-<tab>") 'nswbuff-switch-to-next-buffer)
  (global-set-key (kbd "C-S-<tab>") 'nswbuff-switch-to-previous-buffer))

;; Hippie-expand (M-spacebar) completes almost anything
(global-set-key "\M- " 'hippie-expand)

;; Go to line: C-l (overrides default keybinding for recenter-top-bottom)
(global-set-key "\C-l" 'goto-line) 

;; Ignore case when completing (for example 'TeX-'). This is not a Custom user option.
(setq completion-ignore-case t)

:; Standard C-v, C-c, C-x + rectangles (https://www.emacswiki.org/emacs/CuaMode)
(cua-mode t)

;; Word-wrap in text mode
(add-hook 'text-mode-hook 'visual-line-mode)

;; F1 = help
(global-set-key [f1] 'help)

;; F5 = customize option
(global-set-key [(f5)] 'customize-option)

;; F11 = save buffer
(defun my-save-buffer (&optional arg)
  "Like `save-buffer', but no-op in certain modes."
  (interactive "p")
  (unless (derived-mode-p 'compilation-mode
                          'help-mode
                          'dired-mode)
    (basic-save-buffer t)))  ; confirmation msg also when there are no changes

(define-key global-map [f11] 'my-save-buffer)

;; F12 = kill buffer (strange issue with *helm* buffers...)
(defun my-kill-buffer ()
  "Kill buffer."
  (interactive)
  (unless (string-match "^\\*Pymacs" (buffer-name))
    (kill-buffer)))

(define-key global-map [f12] 'my-kill-buffer)

;; Use Cygwin "find"
(setq find-program "C:/cygwin64/bin/find")

;; grep command ({dir1,dir2} is expanded by the shell)
;;(setq grep-command "grep --color=always --exclude-dir={backup,.cache,.git} -I -r -n -e ")
(setq grep-command "ag --ignore backup --vimgrep ")
(setq grep-use-null-device nil)

;; Printing
(setq gsprint "c:\\Program Files\\Ghostgum\\gsview\\gsprint.exe")
(setq lpr-command gsprint)
(setq ps-lpr-command gsprint)
(setq ps-lpr-switches '("-query"))
(setq lpr-switches '("-query"))
(setq ps-printer-name t)
(setq printer-name t)

;; Skeletons
(define-skeleton latex-skel
  "Insert a LaTeX article skeleton into current buffer."
  "Prompt:"
"\\documentclass[11pt,a4paper]{article}
\\usepackage[utf8]{inputenc}\n
\\begin{document}
\\section{First section}\n
\\end{document}\n")

(define-skeleton xslt2-skel
  "Insert an XSLT 2.0 skeleton into current buffer."
  "Prompt: "
"<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\"
                version=\"2.0\">

 <xsl:output indent=\"yes\"/>

  <!-- Identity transform -->
  <xsl:template match=\"@* | node()\">
    <xsl:copy>
      <xsl:apply-templates select=\"@* | node()\" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match=\"/\">
   <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>\n")

;; Web browser
;(setq browse-url-browser-function 'eww-browse-url)
(setq browse-url-browser-function 'browse-url-default-browser)
(global-set-key "\C-xm" 'browse-url-at-point)

;; Open Explorer: https://emacs.stackexchange.com/q/7742
(defun expl ()
  "Open the current file's directory in Explorer."
  (interactive)
  (if default-directory
    (browse-url-of-file (expand-file-name default-directory))
    (error "No `default-directory' to open")))

;; Emacs Code Browser (https://github.com/ecb-home/ecb)
(defun my-ecb ()
  "Load and start ECB."
  (interactive)
  (add-to-list 'load-path (concat site-lisp "ecb"))
  (load-file (concat site-lisp "ecb/ecb.elc"))
  (semantic-mode)
  (ecb-activate)
  (ecb-rebuild-methods-buffer))

;; Resize the ECB window (https://www.emacswiki.org/emacs/PracticalECB)
(add-hook 'ecb-activate-hook
          (lambda ()
            (ecb-redraw-layout)
            (modify-all-frames-parameters '((width . 140)))))

(add-hook 'ecb-deactivate-hook
          (lambda ()
            (modify-all-frames-parameters '((width . 110)))))

;; Gnus
(use-package gnus
  :defer t
  :config
  (setq gnus-use-dribble-file nil)
  (setq gnus-select-method '(nntp "gmane.io"))

  ;; Do not hide read articles
  (setq gnus-mark-article-hook nil)

  ;; Always list all groups (read or unread)
  (setq gnus-permanently-visible-groups "gmane"))

;; dired-x: dired-jump, dired-omit-mode (toggle: C-x M-o)
(use-package dired-x
  :bind ("C-x C-j" . dired-jump)
  :hook (dired-mode . dired-omit-mode)
  :config
  (setq dired-omit-verbose nil)
  (setq dired-omit-files
        ;; "^\\.?#\\|^\\.$" 
        (rx (or (seq bol (? ".") "#") 
                (seq bol "." eol)))))

;; Dired sorting
(use-package ls-lisp
  :config
  (setq ls-lisp-dirs-first t)
  (setq ls-lisp-ignore-case t)
  (setq ls-lisp-verbosity '()))

(use-package dired-sort-menu
  :hook (dired-load . (lambda() dired-sort-menu)))

;; Dired: sort backup files chronologically
(add-hook 'dired-mode-hook
          (lambda ()
            (if (string= default-directory (file-truename (concat user-emacs-directory "backup/")))
                (dired-sort-toggle-or-edit))))

;; Dired: restore sensible DnD behaviour
;; https://gregmunger.typepad.com/weblog/2009/11/turn-off-drag-drop-copy-dired-behavior-in-emacs-231.html
(setq dired-dnd-protocol-alist
      '(("^file:///" . dnd-open-local-file)
        ("^file://" . dnd-open-file)
        ("^file:" . dnd-open-local-file)))

;; Nice icons to show in dired
(use-package all-the-icons
  :hook (dired-mode . all-the-icons-dired-mode)
  :config (setq all-the-icons-dired-monochrome nil))

;; AUCTeX: add commands for XeLaTeX, LuaLaTeX, Texify
(use-package latex
  :defer t
  :config
  (add-to-list 'TeX-command-list (list "---- end-custom ----" ""))
  (add-to-list 'TeX-command-list
               '("XeLaTeX" "%`xelatex%(mode)%' %t" TeX-run-TeX nil t))
  (add-to-list 'TeX-command-list
               '("LuaLaTeX" "%`lualatex%(mode)%' %t" TeX-run-TeX nil t))
  (add-to-list 'TeX-command-list
               (list "Texify clean view"
                     "texify --engine=luatex --run-viewer -c -p %t"  
                     'TeX-run-command nil t))
  (add-to-list 'TeX-command-list (list "---- start-custom ----" ""))

  ;; Open PDF in Acrobat Reader and more...
  :hook
  (LaTeX-mode . (lambda ()
                  (setq font-latex-fontify-script nil)           ; Don't fontify sub/superscript
                  (setq TeX-PDF-mode t)
                  (setq TeX-save-query nil)
                  (setq TeX-show-compilation t)
                  (setq TeX-command-default "Texify clean view") ; Needs to be here to work?
                  (setq TeX-view-program-selection '((output-pdf "Acroread")))
                  (setq TeX-view-program-list '(("Acroread" "AcroRd32.exe %o")))
                  (setq TeX-auto-save t)
                  (setq TeX-parse-self t))))

;; nXML for XML
(use-package nxml-mode
  :mode "\\.xsd\\'"
  ;; [C-return] clashes with cua-mode's rectangles. ESC TAB can also be used.
  ;; https://lists.defectivebydesign.org/archive/html/emacs-devel/2005-05/msg00339.html
  ;; https://stackoverflow.com/q/6837511/407651 (unable to make this work)
  :hook
  (nxml-mode . (lambda ()
                 (define-key nxml-mode-map [C-return] 'completion-at-point)
                 (visual-line-mode -1))))

;; RELAX NG compact syntax
(use-package rnc-mode
  :mode ("\\.rnc\\'")
  :init
  (setq rnc-enable-flymake nil)
  (setq rnc-jing-jar-file "c:/Java/jing-20181222/bin/jing.jar"))

;; https://stackoverflow.com/questions/12492/pretty-printing-xml-files-on-emacs
(defun pprint-xml-region (begin end)
  "Pretty-print XML markup in region."
  (interactive "r")
  (save-excursion
    (nxml-mode)
    (goto-char begin)
    (while (search-forward-regexp "\>[ \\t]*\<" nil t)
      (backward-char) (insert "\n"))
    (indent-region begin end)))

;; Support for Tidy (XML)
(use-package tidy
  :commands tidy-build-menu
  :hook (nxml-mode . (lambda ()
                       (tidy-build-menu nxml-mode-map))))

;; Python mode with Jedi
;; Jedi.el: https://github.com/tkf/emacs-jedi. Sets up a virtualenv.
;; Jedi: https://github.com/davidhalter/jedi
(use-package jedi
  :hook (python-mode . jedi:setup)
  :init (setq jedi:complete-on-dot t))

;; Pymacs: one Python bug fix; https://github.com/dgentry/Pymacs
(add-to-list 'load-path (concat site-lisp "Pymacs"))
(use-package pymacs
  :disabled
  :config
  (add-to-list 'pymacs-load-path (concat user-emacs-directory "python"))
  (pymacs-load "util"))

;; JDEE for Java (installed via MELPA; jdee-server installed manually)
(use-package jdee
  :mode ("\\.java$" . jdee-mode)
  :hook (jdee-mode . (lambda ()
                       ;(local-set-key (kbd "<tab>") 'jdee-complete-menu)
                       (load "jdc")))
  :init
  (setq jdee-server-dir (concat site-lisp "jdee-server/target")))

;; Perl
(use-package cperl-mode
  :mode ("\\.pl\\'")
  :hook (cperl-mode . imenu-add-menubar-index)
  :init
  (defalias 'perl-mode 'cperl-mode)
  (setq cperl-hairy t))

;; XQuery
(use-package xquery-mode
  :mode ("\\.xq$"))

;; JavaScript
(use-package js2-mode
  :mode ("\\.js\\'"))

;; AsciiDoc
(use-package adoc-mode
  :mode ("\\.adoc\\'"))

;; Markdown
(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)  ; GitHub-flavoured
         ("\\.md\\'" . markdown-mode)
         ("\\.text\\'" . markdown-mode)))

;; reStructuredText
(use-package rst
  :mode ("\\.rst\\'" . rst-mode)
  :hook (rst-adjust . rst-toc-update)
  
  ;; Enable the Xref backend (xref-find-references does not work)
  ;; https://gitlab.com/ideasman42/emacs-xref-rst/
  :hook (rst-mode . (lambda () (xref-rst-mode)))
  :hook (rst-mode . (lambda ()
                      (add-hook 'xref-backend-functions #'xref-rst-xref-backend))))

;; Dockerfile
(use-package dockerfile-mode
  :mode ("Dockerfile\\'"))

;; PO files
(use-package po-mode
  :mode ("\\.po\\'\\|\\.pot\\'"))

;; Insert Unicode characters (https://github.com/ndw/xmlunicode)
(use-package xmlunicode-helm
  :bind ("\C-ci" . xmlunicode-character-insert-helm))

;; Describe Unicode character at point
(global-set-key "\C-cd" 'describe-char)

; Org mode
(use-package org
  :mode ("\\.org$" . org-mode)
  :init
  ;; Org -> HTML options
  (setq org-html-htmlize-output-type 'css)
  (setq org-html-head-include-default-style nil)
  ;; org-babel: no confirmation of code evaluation
  (setq org-confirm-babel-evaluate nil)
  ;; Org source syntax highlighting of code
  (setq org-src-fontify-natively nil)
  ;; Open Org document expanded; do not hijack Ctrl+Tab
  :hook (org-mode . (lambda ()
                      (outline-show-all)
                      (define-key org-mode-map [(control tab)] nil)))
  :config
  ;; Enable Python in org-babel
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t))))

;; YASnippet
(use-package yasnippet
  :hook ((prog-mode text-mode) . yas-minor-mode))

;; Helm: completion & narrowing (recent files, bookmarks)
;; C-a overrides default keybinding for beginning-of-line
(use-package helm
  :bind ("\C-a" . helm-mini)
  :config
  (setq helm-mini-default-sources '(helm-source-recentf
                                    helm-source-bookmarks))
  ;; Search with ag
  (setq helm-ag-command-option "--ignore backup"))

;; Vertico: yet another completion package
(use-package vertico
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

;; Orderless completion style
(use-package orderless
  :init
  (setq completion-styles '(substring orderless)))

;; Consult: utilities related to completion and searching
(use-package consult
  :config (setq consult-preview-key nil))  ; Disable previews

;; Go to a directory
(use-package consult-dir
  :bind ("C-q" . consult-dir)
  :config (setq consult-dir-sources '(consult-dir--source-recentf)))
