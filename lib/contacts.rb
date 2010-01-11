module Contacts
  ENTRIES = {
    # sort entries please!
    :facebook => {:set => proc do |value|
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
    end, :get => proc do |value|
      m = /^\d+$/.match(value)
      if m
        'http://facebook.com/profile.php?id=%s' % value
      else
        'http://facebook.com/' + value
      end
    end
    },

    :flickr => {:set => proc do |value|
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
    end, :get => 'http://flickr.com/photos/%s'}

    :gtalk => {:set => proc do |value|
      username_regexp = '[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)*'
      if result = value[Regexp.new("^(#{username_regexp})(?:@gmail\\.com)?$"), 1]
        "#{result}@gmail.com" if result && 6..30 === result.length
      elsif result = value[Regexp.new("^#{username_regexp}@[a-z0-9]+(\\.[a-z0-9]+)+$")]
        "#{result}" if result
      end
    end, :get => 'gtalk:chat?jid=%s'},

    :homepage => proc do |value|
      unless value.blank?
        url = URI.parse(value) rescue nil
        unless url.blank?
          url = URI.parse('http://' + value) if url.scheme.blank?
          if url.is_a?(URI::HTTP) && !url.host.blank? && !url.host['.'].blank?
            url.normalize.to_s
          end
        end
      end
    end,

    :icq => {:set => /^\d+$/, :get => 'http://icq.com/%s'},

    :lastfm => {:set => proc do |value|
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
    end, :get => 'http://last.fm/user/%s'},

    :livejournal => {:set => proc do |value|
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
    end, :get => 'http://%s.livejournal.com/'},

    :lookatme => {:set => proc do |value|
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
    end, :get => 'http://lookatme.ru/users/%s'},

    :moikrug => {:set => proc do |value|
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
    end, :get => 'http://%s.moikrug.ru/'},

    :myspace => {:set => proc do |value|
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
    end, :get => 'http://myspace.com/%s'},

    :phone => {:set => /.+/, :get => 'callto://%s/'},

    :skype => {:set => /^[a-z][a-z0-9_,.\-]{5,31}$/i, :get => 'skype:%s?userinfo'},

    :twitter => {:set => proc do |value|
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
    end, :get => 'http://twitter.com/%s'},

    :youtube => {:set => proc do |value|
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
    end, :get => 'http://youtube.com/user/%s'},

    :vkontakte => {:set => proc do |value|
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
    end, :get => 'http://vkontakte.ru/id%s'},

    :wikipedia => {
      :set => proc do |value|
        value.gsub("http://", '')
      end, :get => proc do |value|
        "http://#{value}".gsub(/.+\/wiki\//, '')
      end
    },
  }

  def self.included(base)
    base.send :serialize, :contacts, Hash
    base.send :attr_accessible, *Contacts::ENTRIES.keys
  end

  ENTRIES.keys.each do |name|
    class_eval %Q{
      def #{name}
        contacts && contacts[#{name.inspect}]
      end
      def #{name}_link
        get_contacts_data(#{name.inspect})
      end
      def #{name}=(value)
        set_contacts_data(#{name.inspect}, value)
      end
    }, __FILE__, __LINE__
  end

  def has_contacts?
    ENTRIES.keys.any? do |contact_name|
      get_contacts_data(contact_name).present?
    end
  end

private

  def get_contacts_data(name)
    options = ENTRIES[name]
    raise "Unknown contact #{name.inspect}" unless options

    get = options.is_a?(Hash) ? options[:get] : nil

    if contacts
      if contacts[name].blank? || get.blank?
        contacts[name]
      elsif get.is_a? String
        get % contacts[name]
      else
        raise "Unknown type of getter for contact type #{name.inspect}: #{set.inspect}"
      end
    end
  end

  def set_contacts_data(name, value)
    contacts_will_change!
    options = ENTRIES[name]
    raise "Unknown contact #{name.inspect}" unless options

    set = options.is_a?(Hash) ? options[:set] : options

    self.contacts ||= {}
    if value.nil?
      contacts[name] = nil
    elsif set.is_a? Regexp
      contacts[name] = value.strip[set]
    elsif set.is_a? Proc
      contacts[name] = set.call(value.strip)
    else
      raise "Unknown type of setter for contact type #{name.inspect}: #{set.inspect}"
    end
    self[name.to_sym] = contacts[name] # If we have #{name} field in dataqbase, it will store
  end
end
