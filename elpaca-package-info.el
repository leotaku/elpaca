;;; elpaca-package-info.el --- Display package info  -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Nicholas Vollmer

;; Author:  Nicholas Vollmer
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:
(require 'elpaca)
(defvar-local elpaca-package-info nil)
(defvar-local elpaca-package-info-source-index nil)

;;;###autoload
(defun elpaca-package-info (item)
  "Display package info for ITEM in a dedicated buffer."
  (interactive (list (intern (plist-get (elpaca-menu-item t) :package))))
  (with-current-buffer (get-buffer-create (format "*elpaca-package-info: %S*" item))
    (setq-local elpaca--package-info
                (mapcar #'cdr (cl-remove-if-not (lambda (it) (eq it item))
                                                (append (elpaca--custom-candidates)
                                                        (elpaca--menu-items))
                                                :key #'car))
                elpaca--source-index (or elpaca--source-index 0))
    (read-only-mode -1)
    (erase-buffer)
    (let* ((info (nth elpaca--source-index elpaca--package-info))
           (recipe (plist-get info :recipe)))
      (insert
       (string-join
        (list (propertize (plist-get recipe :package) 'face '(:height 2.0 :weight bold))
              (format "%-10s %s" (propertize "sources:" 'face '(:weight bold))
                      (string-join
                       (mapcar (lambda (it) (plist-get it :source))
                               elpaca--package-info)
                       ", "))
              (format "%-10s %s" (propertize "recipe:\n\n" 'face '(:weight bold))
                      (pp-to-string recipe))
              (when (elpaca--on-disk-p item)
                (format "%-10s %S" (propertize "dependencies:" 'face '(:weight bold))
                        (elpaca-dependencies item)))
              (when (elpaca--on-disk-p item)
                (format "%-10s %S" (propertize "dependents:" 'face '(:weight bold))
                        (elpaca-dependents item))))
        "\n"))
      (special-mode)
      (pop-to-buffer (current-buffer)))))

;;(elpaca-package-info 'helm)

(provide 'elpaca-package-info)
;;; elpaca-package-info.el ends here

