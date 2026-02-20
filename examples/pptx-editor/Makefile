.PHONY: demo-pptx render-equation

demo-pptx:
	python3 demo_presentation.py

render-equation:
	@echo "Usage: make -C examples/pptx-editor render-equation EQN='E = mc^2' OUT=equation.png"
	@test -n "$(EQN)" || { echo "ERROR: Set EQN='your LaTeX equation'"; exit 1; }
	@test -n "$(OUT)" || { echo "ERROR: Set OUT=output.png"; exit 1; }
	python3 render_equation.py "$(EQN)" "$(OUT)"
