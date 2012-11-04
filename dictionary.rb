#!/usr/bin/env ruby -wKU

require 'optparse'

class Dictionary

  DICTIONARY_PATH = '/usr/share/dict/web2'

  def initialize
    @constraints = []
  end

  def filter(&block)
    @constraints << block
  end

  def search
    # File.foreach(DICTIONARY_PATH).select(&self).map{ |w| w.downcase }.sort.uniq
    File.foreach(DICTIONARY_PATH).select(&self).map(&:downcase).sort.uniq
  end

  def to_proc
    lambda { |e| @constraints.all? { |fn| fn.call(e) } }
  end

end

options = {}
OptionParser.new do |opts|
  appname = File.basename($0, File.extname($0))
  opts.banner = "Syntax: #{ appname } [options] letters"

  opts.on( '-e', '--ends_with CHARS',   'Ends with characters'      ) { |o| options[ :ends_with   ] = o }
  opts.on( '-l', '--word_length L',     'Length of words to return' ) { |o| options[ :length      ] = o }
  opts.on( '-s', '--starts_with CHARS', 'Starts with characters'    ) { |o| options[ :starts_with ] = o }

  opts.on( '--starts_with_one_of CHARS', Array, 'Starts with one of the characters in A,B,C' ) { |o| options[ :starts_with_one_of ] = o }
  opts.on( '--ends_with_one_of CHARS',   Array, 'Ends with one of the characters in A,B,C'   ) { |o| options[ :ends_with_one_of   ] = o }

  options[:help] = opts.to_s
end.parse!

abort(options[:help]) unless ( ARGV.any? )

dictionary = Dictionary.new
dictionary.filter { |w| w[ Regexp.new( Regexp.union( ARGV ) ) ] }
dictionary.filter { |w| w[0] == options[:starts_with]                  } if ( options[ :starts_with        ] )
dictionary.filter { |w| w[-1] == options[:ends_with]                   } if ( options[ :ends_with          ] )
dictionary.filter { |w| w[/^[#{ options[:starts_with_one_of].join }]/] } if ( options[ :starts_with_one_of ] )
dictionary.filter { |w| w[/[#{ options[:ends_with_one_of].join }]$/]   } if ( options[ :ends_with_one_of   ] )
dictionary.filter { |w| w.strip.length == options[:length].to_i        } if ( options[ :length             ] )

puts dictionary.search