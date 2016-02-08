lessc := "$(CURDIR)/node_modules/.bin/lessc" --npm-import --clean-css="--s0 --advanced --compatibility=ie8" --autoprefix="last 2 versions"

output_dir := ../priv
assets := $(addprefix $(output_dir)/,app.css)

# Public targets
.PHONY:: all clean
all: $(assets)

clean:
	$(RM) $(assets)

# Build targets
$(output_dir)/%.css: styles/%.less node_modules Makefile | $(output_dir)
	$(lessc) $< > $@

$(output_dir):
	mkdir -p $(output_dir)

# Internal targets
node_modules: package.json
	npm install
	@touch $@
