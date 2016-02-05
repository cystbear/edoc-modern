lessc := $(CURDIR)/node_modules/.bin/lessc

output_dir := ../priv/
assets := $(addprefix $(output_dir),app.css)

.PHONY:: all clean
all: $(assets)

clean:
	$(RM) $(assets)

node_modules: package.json
	npm install
	@touch $@

$(output_dir)/%.css: styles/%.less
	$(lessc) -M $< $@ > styles/$*.less.d
	$(lessc) $< > $@

-include styles/app.less.d

