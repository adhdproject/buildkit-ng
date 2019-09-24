# -*- coding: binary -*-
require 'msf/core'

###
#
# This data type represents an author of a piece of code in either
# the framework, a module, a script, or something entirely unrelated.
#
###
class Msf::Module::Author

  # A hash of known author names
  Known =
    {
      'amaloteaux'       => 'alex_maloteaux' + 0x40.chr + 'metasploit.com',
      'anonymous'        => 'Unknown',
      'bannedit'         => 'bannedit' + 0x40.chr + 'metasploit.com',
      'Carlos Perez'     => 'carlos_perez' + 0x40.chr + 'darkoperator.com',
      'cazz'             => 'bmc' + 0x40.chr + 'shmoo.com',
      'CG'               => 'cg' + 0x40.chr + 'carnal0wnage.com',
      'ddz'              => 'ddz' + 0x40.chr + 'theta44.org',
      'egypt'            => 'egypt' + 0x40.chr + 'metasploit.com',
      'et'               => 'et' + 0x40.chr + 'metasploit.com',
      'Christian Mehlmauer' => 'FireFart' + 0x40.chr + 'gmail.com',
      'hdm'              => 'hdm' + 0x40.chr + 'metasploit.com',
      'I)ruid'           => 'druid' +  0x40.chr + 'caughq.org',
      'jcran'            => 'jcran' + 0x40.chr + 'metasploit.com',
      'jduck'            => 'jduck' + 0x40.chr + 'metasploit.com',
      'joev'             => 'joev' + 0x40.chr + 'metasploit.com',
      'juan vazquez'     => 'juan.vazquez' + 0x40.chr + 'metasploit.com',
      'kf'               => 'kf_list' + 0x40.chr + 'digitalmunition.com',
      'kris katterjohn'  => 'katterjohn' + 0x40.chr + 'gmail.com',
      'MC'               => 'mc' + 0x40.chr + 'metasploit.com',
      'Ben Campbell'     => 'eat_meatballs' + 0x40.chr + 'hotmail.co.uk',
      'msmith'           => 'msmith' + 0x40.chr + 'metasploit.com',
      'mubix'            => 'mubix' + 0x40.chr + 'hak5.org',
      'natron'           => 'natron' + 0x40.chr + 'metasploit.com',
      'optyx'            => 'optyx' + 0x40.chr + 'no$email.com',
      'patrick'          => 'patrick' + 0x40.chr + 'osisecurity.com.au',
      'pusscat'          => 'pusscat' + 0x40.chr + 'metasploit.com',
      'Ramon de C Valle' => 'rcvalle' + 0x40.chr + 'metasploit.com',
      'sf'               => 'stephen_fewer' + 0x40.chr + 'harmonysecurity.com',
      'sinn3r'           => 'sinn3r' + 0x40.chr + 'metasploit.com',
      'skape'            => 'mmiller' + 0x40.chr + 'hick.org',
      'skylined'         => 'skylined' + 0x40.chr + 'edup.tudelft.nl',
      'spoonm'           => 'spoonm' + 0x40.chr + 'no$email.com',
      'stinko'           => 'vinnie' + 0x40.chr + 'metasploit.com',
      'theLightCosine'   => 'theLightCosine' + 0x40.chr + 'metasploit.com',
      'todb'             => 'todb' + 0x40.chr + 'metasploit.com',
      'vlad902'          => 'vlad902' + 0x40.chr + 'gmail.com',
      'wvu'              => 'wvu' + 0x40.chr + 'metasploit.com'
    }

  #
  # Class method that translates a string to an instance of the Author class,
  # if it's of the right format, and returns the Author class instance
  #
  def self.from_s(str)
    instance = self.new

    # If the serialization fails...
    if (instance.from_s(str) == false)
      return nil
    end

    return instance
  end

  #
  # Transforms the supplied source into an array of authors
  #
  def self.transform(src)
    Rex::Transformer.transform(src, Array, [ self ], 'Author')
  end

  def initialize(name = nil, email = nil)
    self.name  = name
    self.email = email || Known[name]
  end

  #
  # Compares authors
  #
  def ==(tgt)
    return (tgt.to_s == to_s)
  end

  #
  # Serialize the author object to a string in form:
  #
  # name <email>
  #
  def to_s
    str = "#{name}"

    if (email and not email.empty?)
      str += " <#{email}>"
    end

    return str
  end

  #
  # Translate the author from the supplied string which may
  # have either just a name or also an email address
  #
  def from_s(str)


    # Supported formats:
    #   known_name
    #   user [at/@] host [dot/.] tld
    #   Name <user [at/@] host [dot/.] tld>


    if ((m = str.match(/^\s*([^<]+)<([^>]+)>\s*$/)))
      self.name  = m[1].sub(/<.*/, '')
      self.email = m[2].sub(/\s*\[at\]\s*/, '@').sub(/\s*\[dot\]\s*/, '.')
    else
      if (Known[str])
        self.email = Known[str]
        self.name  = str
      else
        self.email = str.sub(/\s*\[at\]\s*/, '@').sub(/\s*\[dot\]\s*/, '.').gsub(/^<|>$/, '')
        m = self.email.match(/([^@]+)@/)
        self.name = m ? m[1] : nil
        if !(self.email and self.email.index('@'))
          self.name  = self.email
          self.email = ''
        end
      end
    end

    self.name.strip! if self.name

    return true
  end

  #
  # Sets the name of the author and updates the email if it's a known author.
  #
  def name=(name)
    self.email = Known[name] if (Known[name])
    @name = name
  end

  attr_accessor :email
  attr_reader   :name
end
