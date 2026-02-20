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

# --- PPTX targets ---

.PHONY: demo-pptx render-equation

demo-pptx:
	python3 pptx/demo_presentation.py

render-equation:
	@echo "Usage: make -C setup render-equation EQN='E = mc^2' OUT=equation.png"
	@test -n "$(EQN)" || { echo "ERROR: Set EQN='your LaTeX equation'"; exit 1; }
	@test -n "$(OUT)" || { echo "ERROR: Set OUT=output.png"; exit 1; }
	python3 pptx/render_equation.py "$(EQN)" "$(OUT)"
