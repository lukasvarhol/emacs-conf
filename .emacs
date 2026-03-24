;; emacs config file

;; Get Melpa package manager
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             t)

(package-initialize)

;; Auto-generated config settings will be saved here:
(setq custom-file "~/.emacs.custom.el")

;; Basic config
(add-to-list 'default-frame-alist `(font . "Iosevka-15"))
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode)

(load-file custom-file)

(setq ring-bell-function 'ignore)

;; Built-in diagnostics UI
(add-hook 'prog-mode-hook #'flymake-mode)

;; VHDL
(setq vhdl-modify-date-on-saving nil)

(setq vhdl-ext-feature-list
      '(font-lock
        xref
        capf
        hierarchy
        eglot
        flycheck
        beautify
        navigation
        template
        compilation
        imenu
        which-func
        hideshow
        ports))

(require 'vhdl-ext)
(vhdl-ext-mode-setup)
(vhdl-ext-eglot-set-server 've-rust-hdl)

;; Start Eglot automatically
(add-hook 'java-mode-hook #'eglot-ensure)
(add-hook 'c-mode-hook #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)
(add-hook 'python-mode-hook #'eglot-ensure)
(add-hook 'cmake-mode-hook #'eglot-ensure)
(add-hook 'vhdl-mode-hook #'eglot-ensure)
(add-hook 'verilog-mode-hook #'eglot-ensure)

(add-to-list 'auto-mode-alist '("\\.sv\\'" . verilog-mode))
(add-to-list 'auto-mode-alist '("\\.svh\\'" . verilog-mode))
(add-to-list 'auto-mode-alist '("\\.v\\'" . verilog-mode))
(add-to-list 'auto-mode-alist '("\\.vh\\'" . verilog-mode))
(add-to-list 'auto-mode-alist '("\\.vhd\\'" . vhdl-mode))
(add-to-list 'auto-mode-alist '("\\.vhdl\\'" . vhdl-mode))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(java-mode . ("jdtls")))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode cuda-mode) . ("clangd")))
  (add-to-list 'eglot-server-programs
               '(python-mode . ("basedpyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(cmake-mode . ("cmake-language-server")))
  (add-to-list 'eglot-server-programs
               '(verilog-mode . ("verible-verilog-ls.exe"))))

(setq eglot-send-changes-idle-time 0.2)

;; Error-line colors
(custom-set-faces
 '(flymake-error ((t (:underline (:style wave :color "red")))))
 '(flymake-warning ((t (:underline (:style wave :color "yellow")))))
 '(flymake-note ((t (:underline (:style wave :color "forest green"))))))

;;; function to create a new python project
(defun my-find-python-command ()
  (or (executable-find "py")
      (executable-find "python3")
      (error "Could not find python or python3 in PATH")))

(defun my-python-project-init ()
  "Initialize Python project and open venv shell in split window."
  (interactive)
  (let* ((project-dir (file-name-as-directory
                       (read-directory-name "Project directory: ")))
         (default-directory project-dir)
         (python-cmd (my-find-python-command))
         (venv-dir (expand-file-name ".venv" project-dir))
         (venv-python
          (expand-file-name
           (if (eq system-type 'windows-nt)
               "Scripts/python.exe"
             "bin/python")
           venv-dir))
         (activate-script
          (if (eq system-type 'windows-nt)
              ".venv\\Scripts\\activate"
            "source .venv/bin/activate"))
         (config-file (expand-file-name "pyrightconfig.json" project-dir)))

    ;; Create venv
    (message "Creating virtual environment...")
    (call-process python-cmd nil "*python-init*" t "-m" "venv" ".venv")

    ;; Install basedpyright
    (message "Installing basedpyright...")
    (call-process venv-python nil "*python-init*" t
                  "-m" "pip" "install" "-U" "pip" "basedpyright")

    ;; Create config file
    (unless (file-exists-p config-file)
      (with-temp-file config-file
        (insert
         "{\n"
         "  \"venvPath\": \".\",\n"
         "  \"venv\": \".venv\",\n"
         "  \"typeCheckingMode\": \"basic\"\n"
         "}\n")))

    (split-window-below)
    (other-window 1)

    ;; Open shell
    (let ((default-directory project-dir))
      (shell (generate-new-buffer-name "*venv-shell*"))

      ;; Activate venv automatically
      (comint-send-string (get-buffer-process (current-buffer))
                          (concat activate-script "\n")))

    (message "Python project ready!")))
