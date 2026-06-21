;; バックアップファイルを作成しない
(setq make-backup-files nil)

;; 自動保存ファイルを作成しない
(setq auto-save-default nil)

;; 自動保存リストファイルを作成しない
(setq auto-save-list-file-prefix nil)

;; ロックファイルを作成しない
(setq create-lockfiles nil)

;; shut up, emacs!
(setq display-warning-minimum-level :error)

;; remap set mark command
(leaf emacs
  :bind (("C-M-SPC" . set-mark-command)))

(leaf leaf-convert)

;; color scheme
(leaf doom-thems
  :config
  (load-theme 'doom-dracula t))

;; modeline
(leaf doom-modeline
  :global-minor-mode t)

;; 垂直補完UI
(leaf vertico
  :global-minor-mode t)

;; fuzzy find
(leaf orderless
  :custom ((completion-styles . '(orderless))
	   (completion-category-defaults . nil)
	   (completion-category-overrides . '((file (styles partial-completion))))))

;; org-mode
(leaf org
  :custom
  (org-directory . "~/org"))

;; ナレッジ管理
(leaf org-roam
  :custom
  (org-roam-directory . "~/src/github.com/myuron/org-roam")
  :config
  (org-roam-db-autosync-mode)
  :bind (("C-c r f" . org-roam-node-find)
	 ("C-c r i" . org-roam-node-insert)
	 ("C-c r t" . org-roam-buffer-toggle)))

;; タスク管理
(leaf org-agenda
  :custom
  (org-agenda-files . `(,org-directory))
  (org-agenda-window-setup . current-window)
  :bind (("C-c a" . org-agenda)))
