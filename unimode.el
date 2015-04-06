(defvar component-type
  '(alist :key-type symbol
          :value-type (choice string
                              symbol
                              (repeat (choice string symbol)))))

(defcustom unimode-components
  `((scala . (propertize "≋"
                         'face '(:inverse-video nil :foreground "#bd1902")))
    (emacs . "E")
    (lisp . "λ")
    (emacs-lisp . '(emacs lisp))
    (common-lisp . '("C" lisp))
    (java . "☕️")
    (r . "ℝ")
    (c . "🔫")
    (c++ . '(c "➕"))
    (javascript . (propertize " ᴊꜱ"
                              'face '(:inverse-video nil
                                      :foreground "#333331"
                                      :background "#f1db50")))
    (clojure . "λ⃝")
    (haskell .
     (concat (propertize "λ"
                         'face '(:inverse-video nil :foreground "#666666"))
             (propertize "="
                         'face '(:inverse-video nil :foreground "#9a9a9a"))))
    (idris . "🐲") ;; or λΠ
    (json . "⓿")
    (rust . "⚙")
    (perl . "🐪")
    (python . "🐍")
    (apl . "⍲")
    (coq . "🐓")
    (ml . "?")
    (sml . '("S" ml))
    (ocaml . '("OCa" ml))
    (shen . '("⊢" lisp))
    (ruby . "💎")
    (help . "ℹ")
    (xml . "<>")
    (purescript . "<≣>")
    (php . "💩")
    (kilns . "👾")

    (interactive . "⬇")
    (repl . "🔃")
    (shell . "🐚")
    (inspector . "🔎")
    (helm . "⎈")
    (prover . "∎")
    (package . "📦"))
  ""
  :type component-type
  :group :unimode)

(defcustom unimode-labels
  '(("lisp-mode" . ((emacs-lisp-mode          . (emacs-lisp))
                    (lisp-interaction-mode    . (emacs-lisp interactive))
                    (lisp-mode                . (common-lisp))))
    ("ielm"      . ((inferior-emacs-lisp-mode . (emacs-lisp repl))))
    ("comint"    . ((comint-mode              . (repl))))
    (js2-mode    . ((js2-mode                 . (javascript))))
    ;; seems to trample the major mode of anything with helm minor mode.
    ;; ("helm"      .  (helm-mode                . (helm)))
    ("slime"     . ((repl-mode                . (common-lisp repl))
                    (slime-inspector-mode     . (common-lisp inspector))))
    ("clojure-mode" . ((clojure-mode          . (clojure))))
    ("eshell-mode"  eshell-mode              '(emacs shell))
    ("shell"        shell-mode               '(shell))
    ("haskell-mode" haskell-mode             '(haskell))
    ("haskell-process" interactive-haskell-mode '(haskell interactive))
    ("idris-mode"   idris-mode               '(idris))
    ("idris-repl"      . ((idris-repl-mode    . (idris repl))))
    ("idris-ipkg-mode" . ((idris-ipkg-mode    . (idris package))))
    ("idris-prover"    . ((idris-prover-script-mode . (idris prover))))
    (ibuffer           . ((ibuffer-mode       . "𝄛")))
    ("perl-mode"       . ((perl-mode          . (perl))))
    ("ruby-mode"       . ((ruby-mode          . (ruby))))
    (scala-mode2       . ((scala-mode         . (scala))))
    ;; NB: SBT is really distinct from the Scala REPL, really want (scala build)
    ;;     ... whatever build might be
    (sbt-mode          . ((sbt-mode           . (scala repl))))
    ("help-mode"       . ((help-mode          . (help))))
    ("nxml-mode"       . ((nxml-mode          . (xml))))
    ("purescript-mode" . ((purescript-mode    . (purescript))))
    ("kilns-mode"      . ((kilns-mode         . (kilns)))))
  ""
  :type `(alist :key-type symbol
                :value-type (alist :key-type symbol
                                   :value-type ,component-type)))

;;; stolen from http://whattheemacsd.com/appearance.el-01.html
(defmacro rename-modeline (package-name mode new-name)
  `(eval-after-load ,package-name
     '(defadvice ,mode (after rename-modeline activate)
        (if (eq major-mode ,mode)
            (setq mode-name ,new-name)
          (diminish ,mode ,new-name)))))

(defun unimode-expand-var (type tag)
  (intern (concat "unimode-"
                  (if type (concat (symbol-name type) "-") "")
                  (symbol-name tag))))

(defun unimode-resolve-symbol (tag)
  ;; Would be nice if it could also be a function that returned a
  ;; list/string/symbol, then we could have slime do CL/Scheme/Clojure/R/JS/etc.
  ;; correctly.
  (let ((val (cdr (assoc tag unimode-components))))
    (typecase val
      (list (apply #'concat (map #'resolve-mode-symbol val)))
      (string val)
      (symbol (resolve-mode-symbol val)))))

(defmacro unimode-label (package mode tags)
  (let ((var (unimode-expand-var nil mode)))
    `(progn
       (defcustom ,var
         '(package ,tags))
       (apply (lambda (package tags) (rename-modeline package ,mode tags))
              ,var))))

(provide 'unimode)
