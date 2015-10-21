# ------------------------------------------------------------------------------
# This make script tests the functionality of certain bundle items.
# ------------------------------------------------------------------------------

RUBY_FILES = Support/lib/*.rb

export TM_BUNDLE_SUPPORT = $(CURDIR)/Support

# -- Rules ---------------------------------------------------------------------

all: check_style
	rubydoctest $(RUBY_FILES)

check_style:
	rubocop $(RUBY_FILES)
