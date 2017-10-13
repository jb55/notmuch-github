
# notmuch-github

A bunch of helpers for working with notmuch and GitHub


## notmuch-visit-pr-in-magit

View PR commits in magit from a GitHub pull request email. Requires a somewhat
special setup that could be more customizable

### Crud

* "origin" is hard-coded
* Assumes that you've added

        fetch = +refs/pull/*/head:refs/pull/origin/*
        fetch = +refs/pull/*/merge:refs/merge/origin/*

to origin's in ".git/config".  We could drop that assumption
passing a more explicit refspec to the fetch call.

## notmuch-review-pr

approve/reject/comment on a PR when viewing a GitHub PR email

### Crud

* Relys on [this](./git-pr-event) cruddy script that needs to be replaced with elisp
