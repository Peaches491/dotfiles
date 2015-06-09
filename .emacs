(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify))
 '(vc-follow-symlinks t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq backup-directory-alist `(("." . "~/.saves")))

(setq column-number-mode t)

(show-paren-mode 1)

;; (add-hook 'after-init-hook #'global-flycheck-mode)

(setq-default show-trailing-whitespace t)

(setq auto-mode-alist (cons '("\\.launch$" . xml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.bashrc$" . shell-script-mode) auto-mode-alist))
(add-hook 'latex-mode-hook 'flyspell-mode)
(add-hook 'tex-mode-hook 'flyspell-mode)
(add-hook 'flyspell-mode-hook 'flyspell-buffer)

(global-set-key (kbd "<f7>") 'flyspell-buffer)

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.launch\\'" . nxml-mode))

(global-set-key (kbd "C-x |") 'split-window-horizontally)
(global-set-key (kbd "C-x _") 'split-window-vertically)
(global-set-key (kbd "C-x &") 'delete-window)

(global-set-key (kbd "C-S-e") 'ignore)

(global-font-lock-mode 1)

(require 'uniquify)
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)

