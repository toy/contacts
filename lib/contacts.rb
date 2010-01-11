require 'contacts/contact_type'
module Contacts
  contact :facebook do
    set do |value|
      username_regexp = '[0-9]{1,25}'
      literal_username_regexp = '[a-zA-Z.]{1,25}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(?:www\\.)?facebook\\.com/profile.php\\?id=(#{username_regexp})"),
        Regexp.new("^(?:http:\\/\\/)?(?:www\\.)?facebook\\.com/group.php\\?gid=(#{username_regexp})"),
        Regexp.new("^(#{username_regexp})$"),
        Regexp.new("^(#{literal_username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result
    end
    get do |value|
      m = /^\d+$/.match(value)
      if m
        'http://facebook.com/profile.php?id=%s' % value
      else
        'http://facebook.com/' + value
      end
    end
  end

  contact :flickr do
    set do |value|
      username_regexp = '[\\-a-zA-Z0-9_@]{1,50}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(?:www\\.)?flickr\\.com/(?:photos|people)/(#{username_regexp})"),
        Regexp.new("^(#{username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result
    end
    get 'http://flickr.com/photos/%s'
  end

  contact :gtalk do
    set do |value|
      username_regexp = '[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)*'
      if result = value[Regexp.new("^(#{username_regexp})(?:@gmail\\.com)?$"), 1]
        "#{result}@gmail.com" if result && 6..30 === result.length
      elsif result = value[Regexp.new("^#{username_regexp}@[a-z0-9]+(\\.[a-z0-9]+)+$")]
        "#{result}" if result
      end
    end
    get 'gtalk:chat?jid=%s'
  end

  contact :homepage do
    set do |value|
      unless value.blank?
        url = URI.parse(value) rescue nil
        unless url.blank?
          url = URI.parse('http://' + value) if url.scheme.blank?
          if url.is_a?(URI::HTTP) && !url.host.blank? && !url.host['.'].blank?
            url.normalize.to_s
          end
        end
      end
    end
  end

  contact :icq do
    set /^\d+$/
    get 'http://icq.com/%s'
  end

  contact :lastfm do
    set do |value|
      username_regexp = '[a-zA-Z][_a-zA-Z0-9\\-]{1,20}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(?:www\\.)?last\\.fm/user/(#{username_regexp})"),
        Regexp.new("^(#{username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result
    end
    get 'http://last.fm/user/%s'
  end

  contact :livejournal do
    set do |value|
      username_regexp = '[a-zA-Z0-9_\\-]{1,20}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(?:users|community)\\.livejournal\\.com\\/(#{username_regexp})"),
        Regexp.new("^(?:http:\\/\\/)?(#{username_regexp})\\.livejournal\\.com"),
        Regexp.new("^(#{username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result.gsub('_', '-') if result && result != 'www'
    end
    get 'http://%s.livejournal.com/'
  end

  contact :lookatme do
    set do |value|
      username_regexp = '[a-zA-Z0-9_\\-]{3,20}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(?:www\\.)?lookatme\\.ru/users/(#{username_regexp})"),
        Regexp.new("^(#{username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result
    end
    get 'http://lookatme.ru/users/%s'
  end

  contact :moikrug do
    set do |value|
      username_regexp = '[a-zA-Z0-9][a-zA-Z0-9_\\-]{1,20}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(#{username_regexp})\\.moikrug\\.ru"),
        Regexp.new("^(#{username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result.gsub('_', '-') if result && result != 'www'
    end
    get 'http://%s.moikrug.ru/'
  end

  contact :myspace do
    set do |value|
      username_regexp = '[a-zA-Z0-9_\\-]{1,25}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(?:www\\.)?myspace\\.com/(#{username_regexp})"),
        Regexp.new("^(#{username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result
    end
    get 'http://myspace.com/%s'
  end

  contact :phone do
    set /.+/
    get 'callto://%s/'
  end

  contact :skype do
    set /^[a-z][a-z0-9_,.\-]{5,31}$/i
    get 'skype:%s?userinfo'
  end

  contact :twitter do
    set do |value|
      username_regexp = '[a-zA-Z0-9_\\-]{1,25}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(?:www\\.)?twitter\\.com/(#{username_regexp})"),
        Regexp.new("^(#{username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result
    end
    get 'http://twitter.com/%s'
  end

  contact :youtube do
    set do |value|
      username_regexp = '[a-zA-Z0-9_\\-]{1,20}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(?:www\\.)?youtube\\.com/user/(#{username_regexp})"),
        Regexp.new("^(#{username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result
    end
    get 'http://youtube.com/user/%s'
  end

  contact :vkontakte do
    set do |value|
      username_regexp = '[0-9]{1,25}'
      regexps = [
        Regexp.new("^(?:http:\\/\\/)?(?:www\\.)?vkontakte\\.ru/id(#{username_regexp})"),
        Regexp.new("^(#{username_regexp})$")
      ]
      result = nil
      regexps.each do |regexp|
        result = value[regexp, 1]
        break if result
      end
      result
    end
    get 'http://vkontakte.ru/id%s'
  end

  contact :wikipedia do
    set do |value|
      value.gsub("http://", '')
    end
    get do |value|
      "http://#{value}".gsub(/.+\/wiki\//, '')
    end
  end

  def self.included(base)
    base.send :serialize, :contacts, Hash
    base.send :attr_accessible, *contact_types.keys
  end

  def has_contacts?
    contact_types.keys.any? do |contact_name|
      get_contacts_data(contact_name).present?
    end
  end

private

  def get_contacts_data(name)
    contact_type = Contacts.contact_types[name]
    raise "Unknown contact type #{name.inspect}" unless contact_type

    if contacts
      value = contacts[name]
      getter = contact_type.getter
      if value.blank? || getter.blank?
        value
      else
        case getter
        when String
          getter % value
        when Proc
          getter.call(value)
        else
          raise "Unknown type of getter for contact type #{name.inspect}: #{get.inspect}"
        end
      end
    end
  end

  def set_contacts_data(name, value)
    contact_type = Contacts.contact_types[name]
    raise "Unknown contact type #{name.inspect}" unless contact_type

    contacts_will_change!
    self.contacts ||= {}

    value = value.strip
    setter = contact_type.setter

    case setter
    when Regexp
      contacts[name] = value[setter]
    when Proc
      contacts[name] = setter.call(value)
    when nil
      contacts[name] = value
    else
      raise "Unknown type of setter for contact type #{name.inspect}: #{setter.inspect}"
    end
  end
end
