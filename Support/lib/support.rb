# encoding: UTF-8
# rubocop:  disable Style/AsciiComments

# -- Imports -------------------------------------------------------------------

require 'yaml'

# -- Classes -------------------------------------------------------------------

# This class represents a mapping table for strings.
class REPLACEMENT
  CIRCULAR_MAPPING = YAML.load_file(
    "#{ENV['TM_BUNDLE_SUPPORT']}/config/config.yaml")['character_map']

  MAP = Hash[CIRCULAR_MAPPING.keys.map do |key|
    mappings = key + CIRCULAR_MAPPING[key] + key
    (mappings.length - 1).times.map { |index| mappings[index..index + 1].chars }
  end.flatten.each_slice(2).to_a]

  # Map a certain single character string to another single character string.
  #
  # [character] A string that specifies the source of the mapping.
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
