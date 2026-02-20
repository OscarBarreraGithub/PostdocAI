FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        biber \
        ghostscript \
        latexmk \
        make \
        texlive-bibtex-extra \
        texlive-fonts-recommended \
        texlive-lang-english \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-latex-recommended \
        texlive-science \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
