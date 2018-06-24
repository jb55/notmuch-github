
# notmuch-github

A bunch of helpers for working with notmuch and GitHub

## Tagging

Here are some ways to tag github pull request emails

```bash
notmuch tag +github from:github.com and tag:inbox

notmuch tag +pr '"You can view, comment on, or merge this pull request online at"' and tag:github and not tag:pr and tag:inbox and not tag:issue

# tag all messages in the thread that have a pr tag
notmuch tag +pr $(notmuch search --output=threads tag:pr and tag:inbox)

# this seems to be a semi reliable way to find github merge emails
notmuch tag +merged Merged and event from:notifications@github.com and not tag:merged and tag:inbox and tag:pr

# tag the entire pr thread as merged
notmuch tag +merged $(notmuch search --output=threads tag:merged and tag:inbox)
```

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
