;; Authors: Kyle Meyer <kyle@kyleam.com>
;;          William Casarin <jb55@jb55.com>
;;
;; original thread @ notmuch mailing list: id:87d16jtsdj.fsf@kyleam.com


(defun notmuch-github-pr-number ()
  "Return the PR number for this message."
  (let ((subject (notmuch-show-get-subject)))
    (or (and (string-match "(#\\([0-9]+\\))$" subject 0)
             (match-string-no-properties 1 subject))
        (user-error "Could not find PR number"))))

;; This function could be anything that figures out the project based
;; on the current notmuch message.  Or, if you use projectile and
;; don't mind getting queried each time, it could just read a project
;; from `projectile-relevant-known-projects'.
(defun notmuch-repo-from-message ()
  "Return the repository that this message is associated with."
  (let ((subject (notmuch-show-get-subject))
        (repo))
    (or (and subject
             (or (and (string-match "\\[\\([^\]]+\\)" subject 0)
                      (setq repo (match-string-no-properties 1 subject))
                      repo)))
        (user-error "Could not determine repo"))))

(defun notmuch-repo-dir-from-message ()
  (let ((repo (notmuch-repo-from-message)))
    (concat "~/dev/github/" repo)))

(defun notmuch-review-pr ()
  (interactive)
  (let* ((pr (notmuch-github-pr-number))
         (repo (notmuch-repo-from-message))
         (body (read-string "Enter message: "))
         (actions '(("approve" . "approve")
                    ("reject" . "reject")
                    ("comment" . "comment")))
         (action (completing-read "Action: " actions))
         (action (cdr (assoc action actions))))
    (call-process "git-pr-event" nil nil nil repo pr body action)))

(defun notmuch-visit-pr-in-magit (&optional dont-fetch)
  "Show the Magit log for this message's PR.
If DONT-FETCH is non-nil, do not fetch first."
  (interactive "P")
  (require 'magit)
  (let* ((pr (notmuch-github-pr-number))
         (repo (notmuch-repo-dir-from-message))
         (default-directory repo))
    ;; "origin" is hard-coded below, but it could of course be
    ;; anything.  You could also have an alist that maps repo ->
    ;; remote.
    ;;
    ;; This assumes that you've added
    ;;
    ;;    fetch = +refs/pull/*/head:refs/pull/origin/*
    ;;    fetch = +refs/pull/*/merge:refs/merge/origin/*
    ;;
    ;; to origin's in ".git/config".  You could drop that assumption
    ;; passing a more explicit refspec to the fetch call.
    (unless dont-fetch
      (magit-run-git "fetch" "origin"))
    (magit-log (list (concat "refs/merge/origin/" pr "^..refs/pull/origin/" pr))
               (list "-p" "--date=local" "--reverse"))))
