# ------------------------------------------------------------------------------
# This make script tests the functionality of certain bundle items.
# ------------------------------------------------------------------------------

RUBY_FILES = Support/lib/*.rb

# -- Rules ---------------------------------------------------------------------

all: check_style
	rubydoctest $(RUBY_FILES)

check_style:
	rubocop $(RUBY_FILES)
