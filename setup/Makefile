TEX_SOURCE := latex/main.tex
BUILD_DIR := build

.PHONY: pdf watch clean

pdf:
	mkdir -p $(BUILD_DIR)
	latexmk -pdf -interaction=nonstopmode -halt-on-error -output-directory=$(BUILD_DIR) $(TEX_SOURCE)

watch:
	mkdir -p $(BUILD_DIR)
	latexmk -pvc -pdf -interaction=nonstopmode -halt-on-error -output-directory=$(BUILD_DIR) $(TEX_SOURCE)

clean:
	latexmk -C -output-directory=$(BUILD_DIR) $(TEX_SOURCE) || true
	rm -rf $(BUILD_DIR)
