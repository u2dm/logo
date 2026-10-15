BUILD_DIR := build
DIST_DIR := dist
SOURCE := src/logo.tex

.PHONY: all svg png clean podman

all: svg png

svg:
	mkdir -p $(BUILD_DIR) $(DIST_DIR)

	latex \
		-interaction=nonstopmode \
		-halt-on-error \
		-output-directory=$(BUILD_DIR) \
		$(SOURCE)

	dvisvgm \
		--no-fonts \
		--bbox=min \
		--exact-bbox \
		-o $(BUILD_DIR)/logo.raw.svg \
		$(BUILD_DIR)/logo.dvi

	inkscape $(BUILD_DIR)/logo.raw.svg \
		--actions="select-all:all;clone-unlink-recursively;export-area-drawing;export-margin:4;export-filename:$(DIST_DIR)/logo.svg;export-do"

	perl -i src/square-viewbox.pl $(DIST_DIR)/logo.svg

	cp $(DIST_DIR)/logo.svg $(DIST_DIR)/logo-white.svg

	perl src/white-fill.pl $(DIST_DIR)/logo.svg > $(DIST_DIR)/logo-dark.svg

	perl src/app-icon.pl $(DIST_DIR)/logo.svg > $(DIST_DIR)/logo-app.svg

png: svg
	rsvg-convert \
		--width 1024 \
		--output $(DIST_DIR)/logo.png \
		$(DIST_DIR)/logo.svg

	cp $(DIST_DIR)/logo.png $(DIST_DIR)/logo-white.png

	rsvg-convert \
		--width 1024 \
		--output $(DIST_DIR)/logo-dark.png \
		$(DIST_DIR)/logo-dark.svg

	rsvg-convert \
		--width 1024 \
		--output $(DIST_DIR)/logo-app.png \
		$(DIST_DIR)/logo-app.svg

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(DIST_DIR)/logo.svg
	rm -f $(DIST_DIR)/logo.png
	rm -f $(DIST_DIR)/logo-white.svg
	rm -f $(DIST_DIR)/logo-white.png
	rm -f $(DIST_DIR)/logo-dark.svg
	rm -f $(DIST_DIR)/logo-dark.png
	rm -f $(DIST_DIR)/logo-app.svg
	rm -f $(DIST_DIR)/logo-app.png

podman:
	mkdir -p $(DIST_DIR)
	podman build --no-cache -t matrix-logo .
	podman run --rm \
		-v "$(CURDIR)/$(DIST_DIR):/app/$(DIST_DIR):Z" \
		matrix-logo
