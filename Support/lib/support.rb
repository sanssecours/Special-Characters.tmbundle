# encoding: UTF-8
# rubocop:  disable Style/AsciiComments

# -- Imports -------------------------------------------------------------------

require 'fileutils'
require 'yaml'

require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'

# -- Classes -------------------------------------------------------------------

# This class adds extra functionality for manipulating strings.
class String
  # Determine the list of single characters contained in this string.
  #
  # = Output
  #
  # This function returns an array containing single character strings.
  #
  # = Examples
  #
  #  doctest: Determine the characters contained in a string
  #  >> '❤️🌻🦄ö'.characters
  #  => ['❤️', '🌻', '🦄', 'ö']
  def characters
    scan(/.\p{M}?/)
  end

  # Determine the character before the character at byte position +position+.
  #
  # = Arguments
  #
  # [position] The index of the character in bytes of the character after the
  #            one this function returns.
  #
  # = Output
  #
  # This function returns the character before the one at byte position
  # +position+. If this character does not exist, then the function returns
  # +nil+.
  #
  # = Examples
  #
  #  doctest: Determine the character at a certain position of a string
  #
  #  >> text = 'Das Island Manöver'
  #  >> text.char_before(1)
  #  => "D"
  #  >> text.char_before(16)
  #  => "ö"
  #  >> text.char_before(0)
  #  => nil
  def char_before(position)
    byteslice(0, position).characters[-1]
  end

  # Replace the character before the one at byte position +position+.
  #
  # This function replaces the character before the character at byte index
  # +position+. If +reverse+ is +false+ the function uses the character that the
  # mapping REPLACEMENT.[] returns. Otherwise it uses the replacement character
  # returned by REPLACEMENT.previous().
  #
  # The method does not change the original string value.
  #
  # = Arguments
  #
  # [position] This is the byte index of the character (one position) after the
  #            character this function replaces.
  #
  # [reverse]  This option specifies if the character returned by
  #            REPLACEMENT.[] or REPLACEMENT.previous should be used as
  #            replacement.
  #
  # = Examples
  #
  #  doctest: Replace the character at a certain position of a string
  #
  #  >> 'Touché Amoré'.replace_character(4)
  #  => "Touχhé Amoré"
  #  >> 'aaa'.replace_character(1)
  #  => "αaa"
  #  >> 'hell_'.replace_character(5)
  #  => "hell_"
  #  >> text = 'haha'
  #  >> text.replace_character(2)
  #  => "hαha"
  #  >> text
  #  => "haha"
  #  >> 'test'.replace_character(2, true)
  #  => "t∉st"
  def replace_character(position, reverse = false)
    character = if reverse
                  REPLACEMENT.previous(char_before(position))
                else
                  REPLACEMENT[char_before(position)]
                end
    character.nil? ? self : (byteslice(0, position).characters[0..-2].join +
                             character + byteslice(position..-1))
  end
end

# This class represents the current configuration for REPLACEMENT.
class CONFIGURATION
  # This directory contains the user modified configuration file.
  CONFIG_DIR = "#{Dir.home}/Library/Application Support/Special Characters"
               .freeze
  # This path specifies the location of the user modified configuration file.
  CONFIG_FILE_USER = File.join(CONFIG_DIR, 'config.yaml')
  # This path stores the location of the default configuration file.
  CONFIG_FILE = "#{ENV['TM_BUNDLE_SUPPORT']}/config/config.yaml".freeze
  # This path contains the location of the +mate+ shell command.
  TM_MATE = ENV['TM_MATE']

  # Return the hash for the current configuration.
  #
  # = Output
  #
  # This function returns a hash containing the data for the current character
  # mapping.
  def self.character_map
    YAML.load_file(location)
  rescue RuntimeError => error
    TextMate.exit_show_tool_tip(error.message)
  end

  # Open the configuration file in TextMate.
  #
  # The original configuration is copied to the location CONFIG_FILE_USER for
  # this purpose. TextMate then opens the copy of the original configuration
  # file.
  def self.edit
    FileUtils.mkdir_p CONFIG_DIR unless Dir.exist? CONFIG_DIR
    FileUtils.copy(CONFIG_FILE,
                   CONFIG_FILE_USER) unless File.exist? CONFIG_FILE_USER
    `#{TM_MATE} #{e_sh CONFIG_FILE_USER}`
  rescue RuntimeError => error
    TextMate.exit_show_tool_tip(error.message)
  end

  # Return the location of the configuration file.
  #
  # If the user defined configuration file exists – CONFIGURATION.edit was
  # invoked at least once – then this function returns the location of the
  # user configuration file. Otherwise the function returns the location of the
  # original configuration file, that is part of this bundle.
  #
  # = Output
  #
  # The function returns a string containing the location of the configuration
  # file.
  def self.location
    File.exist?(CONFIG_FILE_USER) ? CONFIG_FILE_USER : CONFIG_FILE
  end
end

# This class represents a mapping table for single character strings.
#
# If there is a mapping for a certain character via REPLACEMENT.[], then there
# is also a mapping back accessible via REPLACEMENT.previous. This means the
# following condition holds:
#
#   REPLACEMENT.previous(REPLACEMENT[char]) == char
#
# .
class REPLACEMENT
  # This hash stores the mapping specified in the configuration.
  MAP_CONFIG = CONFIGURATION.character_map

  # This hash stores the forward character mapping.
  MAP = Hash[MAP_CONFIG.map do |mapping|
    mappings = mapping + mapping.characters[0]
    Array.new((mappings.characters.length - 1)) do |index|
      mappings.characters[index..index + 1]
    end
  end.flatten.each_slice(2).to_a]

  # This hash stored the backward character mapping.
  MAP_REVERSED = Hash[MAP.map { |key, value| [value, key] }]

  # Map a certain single character string to another single character string.
  #
  # = Arguments
  #
  # [character] A string that specifies the source of the mapping.
  #
  # = Output
  #
  # The function returns the character mapped to the input +character+ or +nil+
  # if there exists no mapping for +character+.
  #
  # = Examples
  #
  #  doctest: Determine the forward mapping for certain characters
  #
  #  >> REPLACEMENT['o']
  #  => 'ω'
  #  >> REPLACEMENT['ω']
  #  => '◦'
  #  >> REPLACEMENT['◦']
  #  => 'ₒ'
  #  >> REPLACEMENT['ₒ']
  #  => 'o'
  def self.[](character)
    MAP[character]
  end

  # Map a single character string (back) to another single character string.
  #
  # This function returns the reversed mapping of REPLACEMENT.[].
  #
  # = Examples
  #
  #  doctest: Determine the reverse mapping for certain characters
  #
  #  >> REPLACEMENT.previous('ω')
  #  => 'o'
  #  >> REPLACEMENT.previous(REPLACEMENT['v'])
  #  => 'v'
  def self.previous(character)
    MAP_REVERSED[character]
  end
end

# -- Function ------------------------------------------------------------------

# Replace the character before the caret with another character.
#
# The replacement character is taken from the circular mapping specified in
# +config.yaml+.
#
# = Arguments
#
# [reverse] If this argument is +true+, then the function will replace the
#           current character with the character before it in the mapping.
#           Otherwise the function will use the character after the current
#           character as replacement.
def convert_single_character(reverse = false)
  line_index = ENV['TM_LINE_INDEX'].to_i

  if line_index <= 0
    TextMate.exit_show_tool_tip 'No character on the left side of the caret!'
  else
    print STDIN.read.replace_character(line_index, reverse).to_s
  end
end
