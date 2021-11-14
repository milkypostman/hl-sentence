# hl-sentence

Highlight sentences in Emacs with a custom face.  Very nice.

![preview](https://github.com/milkypostman/screenshots/raw/master/hl-sentence.png)

# Customizing the Face

Highlighting is based on the `hl-sentence` face which you can
customize to make the face look the way you want.  I use this
primarily in LaTeX mode where I enable `variable-pitch-mode`.  So I
customize my `variable-pitch` face foreground to be `gray60` and then
make `hl-sentence` be `black`.  Works nicely.

# Customising its begin/end of sentence seeking functions

When checking for the begin or ending of sentence the dispatcher functions (`hl-sentence-begin-pos` and `hl-sentence-end-pos` expect some hash tables that contain functions to run based on major mode.

The hash tables are `hl-sentence-begin-mode-dispatcher` and `hl-sentence-end-mode-dispatcher` currently they only include functions for org-mode.

If you want to add a function you can use:
```(puthash modename function hl-sentence-begin-mode-dispatcher)```
or
```(puthash modename function hl-sentence-end-mode-dispatcher)```

# Credit

This was taken mostly from
<http://www.emacswiki.org/emacs/SentenceHighlight>

I believe Aaron Hawley is responsible.  I just took it and made it a
single file and to properly enable and disable the minor-mode.

