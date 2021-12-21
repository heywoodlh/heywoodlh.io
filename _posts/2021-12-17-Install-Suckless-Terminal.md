---
title: 'Install Suckless Terminal (Nord Theme)'
layout: post
published: true
permalink: install-suckless-terminal-nord
tags: all, st, linux, suckless, terminal, minimal, nord
---

This post will be a super simple entry for self-documenting how I installed [Suckless Terminal](http://git.suckless.org/st) with Nord .

## Setup and Configuration:

Download the source: 

```
curl -LO 'https://dl.suckless.org/st/st-0.8.4.tar.gz'
tar xzf st-0.8.4.tar.gz
cd st-0.8.4
```

### Patches:

Nord Theme:

```
curl -LO 'https://st.suckless.org/patches/nordtheme/st-nordtheme-0.8.2.diff'

patch -Np1 -i st-nordtheme-0.8.2.diff
```

Scrollback:

```
curl -LO 'https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff'

patch -Np1 -i st-scrollback-0.8.4.diff
```

Hide Cursor:

```
curl -LO 'https://st.suckless.org/patches/hidecursor/st-hidecursor-0.8.3.diff'

patch -Np1 -i st-hidecursor-0.8.3.diff
```

Copy URL:

```
curl -LO 'https://st.suckless.org/patches/copyurl/st-copyurl-0.8.4.diff'

patch -Np1 -i st-copyurl-0.8.4.diff
```

Clipboard:

```
curl -LO 'https://st.suckless.org/patches/clipboard/st-clipboard-0.8.3.diff'

patch -Np1 -i st-clipboard-0.8.3.diff
```

Blinking Cursor:

```
curl -LO 'https://st.suckless.org/patches/blinking_cursor/st-blinking_cursor-20211116-2f6e597.diff'

patch -Np1 -i st-blinking_cursor-20211116-2f6e597.diff
```

Universal Scroll:

```
curl -LO 'https://st.suckless.org/patches/universcroll/st-universcroll-0.8.4.diff'

patch -Np1 -i st-universcroll-0.8.4.diff
```

Default Font Size:

```
curl -LO 'https://st.suckless.org/patches/defaultfontsize/st-defaultfontsize-20210225-4ef0cbd.diff'

patch -Np1 -i st-defaultfontsize-20210225-4ef0cbd.diff
```

Desktop Entry:

```
curl -LO 'https://st.suckless.org/patches/desktopentry/st-desktopentry-0.8.4.diff'

patch -Np1 -i st-desktopentry-0.8.4.diff
```

## Compile and Install:

```
sudo make install clean
```
