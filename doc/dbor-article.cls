% SPDX-License-Identifier: CC-BY-4.0
% DBOR specification - Dense Binary Object Representation
% Copyright (C) 2020 Daniel Lutz <dlu-ch@users.noreply.github.com>

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dbor-article}[2020/06/25 dbor-article]

\LoadClass[a4paper, 10pt, headings=small, headsepline, numbers=noenddot]{scrartcl}

\usepackage[top=30mm, bottom=25mm, left=40mm, right=25mm]{geometry}
\usepackage{scrtime}

\usepackage[fleqn]{amsmath}
\usepackage[T1]{fontenc}
\usepackage[osf]{mathpazo}  % use Palatino (similar: TeX Gyre Pagella)
\linespread{1.05}\selectfont  % Palatino needs more interline-spacing (here: 5%)
\usepackage{dsfont}  % Type 1 font for \mathds{}
\usepackage{bm}  % bold fonts in math mode
\usepackage{pxfonts}
\usepackage[scaled=0.9]{beramono}  % use Bera Mono (similar: Bitstream Vera Mono) as typewriter font (has bold variant)

\usepackage{xcolor}
\usepackage{array}
\usepackage{booktabs}
\usepackage{graphicx}
\usepackage{footnote}
\usepackage{float}
\usepackage{caption}
\usepackage{ragged2e}
\usepackage[shortlabels]{enumitem}

\makesavenoteenv{tabular}  % package 'footnote'

% footnotes (package 'scrartcl')
\deffootnotemark{\textsuperscript{\thefootnotemark)}}
\deffootnote{0em}{0em}{\textsuperscript{\thefootnotemark)\ }}
\setlength{\skip\footins}{3.5ex}
\addtolength{\footnotesep}{.8ex}

% colours (package 'xcolor')
\definecolor{gray-std}{gray}{0.45}
\definecolor{red-std}{rgb}{0.75,0.00,0.00}
\definecolor{green-std}{rgb}{0.18,0.58,0.08}
\definecolor{blue-std}{rgb}{0.16,0.24,0.64}
\definecolor{blue-dark}{rgb}{0,0,0.42}
\definecolor{violet-std}{rgb}{0.48,0.24,0.64}

\let\mathbbm\mathds

\captionsetup{justification=raggedright,singlelinecheck=false}  % package 'caption'

% layout
\setlength{\parindent}{0em}
\setlength{\mathindent}{2em}
\setlength{\columnsep}{2em}

\raggedbottom
\raggedfootnote

\addtokomafont{pagehead}{\small\itshape}
\addtokomafont{sectioning}{\rmfamily}

% section numbers in the left margin (needs 'scrartcl')
\renewcommand\sectionlinesformat[4]{\makebox[0pt][r]{#3}#4}

\newcommand{\PageSideStyle}{\normalfont\rmfamily\tiny}
\newcommand{\PageSideText}{\texttt{\jobname.tex}: \quad\TeX ed \today, \thistime}  % package 'scrtime'
\newlength{\PageSideSep}\PageSideSep15mm% horiz. space to text body

\newcommand{\@PageSideB@x}{%
    \rotatebox{90}{%
        \hb@xt@\z@{%
            \kern0.1\textheight\hb@xt@0.5\textheight{\PageSideStyle\selectfont\PageSideText\hfil}%
            \hss}%
        }}

\def\ps@lastsec{%
    \let\@mkboth\markboth
    \def\@oddhead{\vbox{\hsize=\textwidth
        \hb@xt@\textwidth{%
            {\headfont\@title}%
            {\headfont\hss\strut}\hskip3em%
            \hbox to0pt{\hss\pnumfont\thepage}%
        }%
        \if@hsl \vskip 1.5\p@ \hrule \fi}}%
    \def\@evenhead{}%
    \def\@oddfoot{%
        \vbox{%
            \setbox\z@\hbox{\@PageSideB@x}%
            \dimen@\wd\z@ \advance\dimen@\PageSideSep%
            \hb@xt@\z@{\hskip-\dimen@ \box\z@ \hss}}%
        \hss}%
    \if@twoside
        \def\@evenfoot{%
            \vbox{%
                \hb@xt@\z@{\hskip\PageSideSep\hskip\textwidth\@PageSideB@x\hss}}%
            \hss}%
    \else
        \let\@evenfoot\@empty
    \fi
    %
    \def\chaptermark##1{%
        \markright{%
            \ifnum \c@secnumdepth>\m@ne \chaptermarkformat \fi
            ##1}}%
    \def\sectionmark##1{%
        \markright{%
            \ifnum \c@secnumdepth>\z@ \sectionmarkformat \fi
            ##1}}%
    \def\subsectionmark##1{%
        \markright{%
            \ifnum \c@secnumdepth>\@ne \subsectionmarkformat \fi
            ##1}}%
    }
\def\chaptermarkformat{\thechapter.\;}
\def\sectionmarkformat{\thesection.\;}
\def\subsectionmarkformat{\thesubsection.\;}

\if@twoside\else
    \let\ps@plain\ps@lastsec
    \let\ps@headings\ps@lastsec
    \let\ps@myheadings\ps@lastsec
    \pagestyle{lastsec}
\fi

% load _after_ all packages that may affect footnotes
% https://tex.stackexchange.com/questions/16268/warning-with-footnotes-namehfootnote-xx-has-been-referenced-but-does-not-exi/16269#16269
\usepackage{hyperref}

\hypersetup{% package 'hyperref'
    bookmarksopen=true,
    linktocpage=true,
    colorlinks=true,
    urlcolor=blue-dark,
    citecolor=blue-dark,
    linkcolor=blue-dark,
    filecolor=blue-dark
}
