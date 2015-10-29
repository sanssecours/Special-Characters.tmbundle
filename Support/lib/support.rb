# encoding: UTF-8
# rubocop:  disable Style/AsciiComments

# -- Imports -------------------------------------------------------------------

require 'fileutils'
require 'yaml'

require ENV['TM_SUPPORT_PATH'] + '/lib/escape'

# -- Classes -------------------------------------------------------------------

# This class represents the current configuration for +REPLACEMENT+.
class CONFIGURATION
  CONFIG_DIR = "#{Dir.home}/Library/Application Support/Special Characters"
  CONFIG_FILE_USER = File.join(CONFIG_DIR, 'config.yaml')
  CONFIG_FILE = "#{ENV['TM_BUNDLE_SUPPORT']}/config/config.yaml"

  TM_MATE = ENV['TM_MATE']

  # Return the hash for the current configuration.
  #
  # = Output
  #
  # This function returns a hash containing the data for the current character
  # mapping.
  def self.character_map
    YAML.load_file(location)['character_map']
  end

  # Open the configuration file in TextMate.
  #
  # The original configuration is copied to the location +CONFIG_FILE_USER+ for
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

  # Get the location of the configuration file.
  #
  # If the user defined configuration file exists – +self.edit+ was invoked at
  # least once – then this function returns the location of the user
  # configuration file. Otherwise the function returns the location of the
  # original configuration file, that is part of this bundle.
  #
  # = Output
  #
  # The function returns a string containing the location of the configuration
  # file.
  def self.location
    (File.exist? CONFIG_FILE_USER) ? CONFIG_FILE_USER : CONFIG_FILE
  end
end

# This class represents a mapping table for strings.
class REPLACEMENT
  CIRCULAR_MAPPING = CONFIGURATION.character_map

  MAP = Hash[CIRCULAR_MAPPING.keys.map do |key|
    mappings = key + CIRCULAR_MAPPING[key] + key
    (mappings.length - 1).times.map { |index| mappings[index..index + 1].chars }
  end.flatten.each_slice(2).to_a]

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
  def self.[](character)
    MAP[character]
  end
end

# This class adds extra functionality for manipulating strings.
class String
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
  #  doctest: Determine the character at a certain position of a string.
  #
  #  >> text = 'Das Island Manöver'
  #  >> text.char_before(1)
  #  => "D"
  #  >> text.char_before(16)
  #  => "ö"
  #  >> text.char_before(0)
  #  => nil
  def char_before(position)
    byteslice(0, position).chars[-1]
  end

  # Replace the character before the one at byte position +position+.
  #
  # This function replaces the character before the character at byte index
  # +position+ with a certain character. It replaces the character with the one
  # that the mapping +REPLACEMENT+ returns, if we use the character that should
  # be replaced as key. The method does not change the original string value.
  #
  # = Arguments
  #
  # [position] The index of the character in bytes of the character after the
  #            one this function replaces.
  #
  # = Examples
  #
  #  doctest: Replace the character at a certain position of a string.
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
  def replace_character(position)
    character = REPLACEMENT[char_before(position)]
    (character.nil?) ? self : (byteslice(0, position).chars[0..-2].join +
                               character + byteslice(position..-1))
  end
end
