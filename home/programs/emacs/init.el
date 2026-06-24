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
(leaf doom-themes
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

;; skk
(leaf nskk
  :custom
  (nskk-dict-system-dictionary-files . "~/.nix-profile/share/skk/SKK-JISYO.L")
  :config
  (nskk-global-mode 1))

;; which-key
(leaf which-key
  :global-minor-mode t)

;; org-mode
(leaf org
  :custom
  (org-directory . "~/org")
  (org-agenda-files . '("~/org"))
  (org-refile-targets . '((org-agenda-files :maxlevel . 1)))
  (org-columns-default-format . "%68ITEM(Task) %6Effort(Effort){:} %6CLOCKSUM(Clock){:}")
  (org-startup-indented . t)
  (org-log-done . time)
  :bind (("C-c t i" . org-clock-in)
         ("C-c t o" . org-clock-out)
	 ("C-c t s" . org-set-effort)))

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
  :require t
  :setq ((org-agenda-custom-commands quote
				     (("x" "Unscheduled Tasks" tags-todo "-SCHEDULED>=\"<today>\"-DEADLINE>=\"<today>\"" nil))))
  :bind (("C-c a" . org-agenda)))

(leaf org-capture
  :custom
  (org-capture-templates . '(("t" "Todo Entroy to Inbox" entry (file+headline "~/org/0_inbox.org" "Inbox")
			      "** TODO %?\n")))
  :bind (("C-c c" . org-capture)))

;; タイム管理
(leaf org-pomodoro
  :bind (("C-c p" . org-pomodoro))) 
