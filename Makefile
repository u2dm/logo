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

	perl -0777 -i -pe 'if (/viewBox="([-\d.]+) ([-\d.]+) ([-\d.]+) ([-\d.]+)"/){my($$x,$$y,$$w,$$h)=($$1,$$2,$$3,$$4);my $$s=$$w>$$h?$$w:$$h;my $$nx=$$x-($$s-$$w)/2;my $$ny=$$y-($$s-$$h)/2;s/viewBox="[^"]*"/sprintf("viewBox=\"%s %s %s %s\"",$$nx,$$ny,$$s,$$s)/e;s/width="[^"]*"/sprintf("width=\"%spt\"",$$s)/e;s/height="[^"]*"/sprintf("height=\"%spt\"",$$s)/e;}' \
		$(DIST_DIR)/logo.svg

	perl -0777 -pe 's/(<svg\b[^>]*>)/$$1\n  <rect x="-100%" y="-100%" width="300%" height="300%" fill="#ffffff"\/>/' \
		$(DIST_DIR)/logo.svg > $(DIST_DIR)/logo-white.svg

	perl -0777 -pe 's/(<g\b)([^>]*\bid="page1")/$$1 fill="#ffffff"$$2/' \
		$(DIST_DIR)/logo.svg > $(DIST_DIR)/logo-dark.svg

png: svg
	rsvg-convert \
		--width 1024 \
		--output $(DIST_DIR)/logo.png \
		$(DIST_DIR)/logo.svg

	rsvg-convert \
		--width 1024 \
		--background-color white \
		--output $(DIST_DIR)/logo-white.png \
		$(DIST_DIR)/logo.svg

	rsvg-convert \
		--width 1024 \
		--output $(DIST_DIR)/logo-dark.png \
		$(DIST_DIR)/logo-dark.svg

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(DIST_DIR)/logo.svg
	rm -f $(DIST_DIR)/logo.png
	rm -f $(DIST_DIR)/logo-white.svg
	rm -f $(DIST_DIR)/logo-white.png
	rm -f $(DIST_DIR)/logo-dark.svg
	rm -f $(DIST_DIR)/logo-dark.png

podman:
	mkdir -p $(DIST_DIR)
	podman build --no-cache -t matrix-logo .
	podman run --rm \
		-v "$(CURDIR)/$(DIST_DIR):/app/$(DIST_DIR):Z" \
		matrix-logo
