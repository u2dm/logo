FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    make \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-recommended \
    dvisvgm \
    librsvg2-bin \
    inkscape && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

CMD ["make", "all"]
