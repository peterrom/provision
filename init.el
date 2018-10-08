(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(unless package--initialized (package-initialize t))

(defun packages-install (packages)
  (dolist (it packages)
    (when (not (package-installed-p it))
      (package-install it)))
  (delete-other-windows))

(defun init--install-packages ()
  (packages-install
   '(zenburn-theme
     better-defaults
     magit
     elpy
     smex
     expand-region
     multiple-cursors
     flycheck
     projectile
     flx-ido
     ido-vertical-mode
     avy)))

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))



(require 'better-defaults)



(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)

(ido-vertical-mode t)
(setq ido-vertical-define-keys 'C-n-C-p-up-down-left-right)

;; disable ido faces to see flx highlights.
(setq ido-enable-flex-matching t)
(setq ido-use-faces nil)



(setq inhibit-startup-message t)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file :noerror)

(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(setq fill-column 79)
(blink-cursor-mode 0)
(setq avy-background t)



(add-hook 'dired-load-hook
          (lambda ()
            (load "dired-x")))

(autoload 'dired-jump "dired-x"
  "Jump to Dired buffer corresponding to current buffer." t)

(autoload 'dired-jump-other-window "dired-x"
  "Like \\[dired-jump] (dired-jump) but in other window." t)



(smex-initialize)



;; "Summary:" message template is included in commit message...
(eval-after-load 'log-edit
  '(remove-hook 'log-edit-hook 'log-edit-insert-message-template))

(setq log-edit-require-final-newline nil)



(defun my-c-hook ()
  (c-set-style "linux")
  (company-mode)
  (local-set-key (kbd "M-TAB") 'company-clang)
  (flycheck-mode))

(add-hook 'c-mode-hook 'my-c-hook)



(defun my-c++-hook ()
  (c-set-style "ellemtel")
  (setq c-basic-offset 8)
  (company-mode)
  (local-set-key (kbd "M-TAB") 'company-clang)
  (flycheck-mode))

(add-hook 'c++-mode-hook 'my-c++-hook)



(elpy-enable)
(setenv "PYTHONIOENCODING" "UTF-8")

;; Use flycheck instead of flymake
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))



(defun my-slide/next ()
  (interactive)
  (goto-line 0)
  (narrow-to-page 1))

(defun my-slide/prev ()
  (interactive)
  (goto-line 0)
  (narrow-to-page -1)
  (goto-line 0))

(defun my-slide/start ()
  (interactive)
  (let ((text-scale-mode-step (/ (window-body-width) 81.0)))
    (text-scale-increase 1))
  (widen)
  (narrow-to-page)
  (local-set-key (kbd "<f6>") #'my-slide/next)
  (local-set-key (kbd "<f5>") #'my-slide/prev)
  (local-set-key (kbd "C-<f6>") #'my-slide/stop))

(defun my-slide/stop ()
  (interactive)
  (text-scale-increase 0)
  (widen)
  (local-unset-key (kbd "<f6>"))
  (local-unset-key (kbd "<f5>"))
  (local-unset-key (kbd "C-<f6>")))



(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-M-x") 'execute-extended-command)

(global-set-key (kbd "<f2>") 'dired-jump)
(global-set-key (kbd "C-<f2>") 'dired-jump-other-window)

(global-set-key (kbd "<f10>") 'hippie-expand)
(global-set-key (kbd "C-c o") 'ff-find-other-file)

(global-set-key (kbd "<f7>") 'er/expand-region)

(global-set-key (kbd "<f8>") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<f8>") 'mc/mark-previous-like-this)

(global-set-key (kbd "<f9>") 'avy-goto-char)

(global-set-key (kbd "<f1>") 'ido-find-file)
(global-set-key (kbd "C-<f1>") 'ido-switch-buffer)

(global-set-key (kbd "<f12>") 'magit-status)

(global-set-key (kbd "<f6>") 'my-slide/start)
