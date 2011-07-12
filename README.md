# hl-sentence

Highlight sentences in Emacs with a custom face.  Very nice.


# Customizing the Face

Highlighting is based on the `hl-sentence-face` which you can
customize to make the face look the way you want.  I use this
primarily in LaTeX mode where I enable `variable-pitch-mode`.  So I
customize my `variable-pitch` face foreground to be `gray60` and then
make `hl-sentence-face` be `black`.  Works nicely.

# Credit

This was taken mostly from 
[http://www.emacswiki.org/emacs/SentenceHighlight]()

I believe Aaron Hawley is responsible.  I just took it and made it a
single file and to properly enable and disable the minor-mode.

