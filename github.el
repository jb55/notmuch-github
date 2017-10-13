(defun km/notmuch-github-pr-number ()
  "Return the PR number for this message."
  (let (pr)
    (with-current-notmuch-show-message
     (goto-char (point-min))
     (if (re-search-forward "https://github\\.com/.*/pull/\\([0-9]+\\)" nil t)
         (setq pr (match-string-no-properties 1))
       (user-error "Could not find PR number")))
    pr))

;; This function could be anything that figures out the project based
;; on the current notmuch message.  Or, if you use projectile and
;; don't mind getting queried each time, it could just read a project
;; from `projectile-relevant-known-projects'.
(defun km/notmuch-repo-from-message ()
  "Return the repository that this message is associated with."
  (let ((subject (notmuch-show-get-subject))
        (repo))
    (or (and subject
             (or (and (string-match "\\([^\]]+\\)" subject 1)
                      (setq repo (match-string-no-properties 1 subject))
                      (concat "~/dev/github/" repo))))
        (user-error "Could not determine repo"))))

(defun km/notmuch-visit-pr-in-magit (&optional dont-fetch)
  "Show the Magit log for this message's PR.
If DONT-FETCH is non-nil, do not fetch first."
  (interactive "P")
  (let* ((pr (km/notmuch-github-pr-number))
         (repo (km/notmuch-repo-from-message))
         (default-directory repo))
    ;; "origin" is hard-coded below, but it could of course be
    ;; anything.  You could also have an alist that maps repo ->
    ;; remote.
    ;;
    ;; This assumes that you've added
    ;;
    ;;    fetch = +refs/pull/*/head:refs/pull/origin/*
    ;;
    ;; to origin's in ".git/config".  You could drop that assumption
    ;; passing a more explicit refspec to the fetch call.
    (unless dont-fetch
      (magit-call-git "fetch" "origin"))
    (magit-log (list (concat "refs/merge/origin/" pr "^..refs/pull/origin/" pr))
               (list "-p"))))
