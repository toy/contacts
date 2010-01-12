require 'contacts/contact_type'
module Contacts
  contact :facebook do
    username_regexp = '[0-9]{1,25}'
    literal_username_regexp = '[a-zA-Z.]{1,25}'
    sanitizer [
      %r{^(?:http://)?(?:www\.)?facebook\.com/profile.php\?id=(#{username_regexp})},
      %r{^(?:http://)?(?:www\.)?facebook\.com/group.php\?gid=(#{username_regexp})},
      %r{^(#{username_regexp})$},
      %r{^(#{literal_username_regexp})$}
    ]
    formatter do |value|
      if value[%r{^\d+$}]
        "http://facebook.com/profile.php?id=#{value}"
      else
        "http://facebook.com/#{value}"
      end
    end
  end

  contact :flickr do
    username_regexp = '[\\-a-zA-Z0-9_@]{1,50}'
    sanitizer [
      %r{^(?:http://)?(?:www\.)?flickr\.com/(?:photos|people)/(#{username_regexp})},
      %r{^(#{username_regexp})$}
    ]
    formatter 'http://flickr.com/photos/%s'
  end

  contact :gtalk do
    sanitizer do |value|
      username_regexp = '[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)*'
      if result = value[%r{^(#{username_regexp})(?:@gmail\.com)?$}, 1]
        "#{result}@gmail.com" if result && 6..30 === result.length
      elsif result = value[%r{^#{username_regexp}@[a-z0-9]+(\.[a-z0-9]+)+$}]
        "#{result}" if result
      end
    end
    formatter 'gtalk:chat?jid=%s'
  end

  contact :homepage do
    sanitizer do |value|
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
    sanitizer %r{^\d+$}
    formatter 'http://icq.com/%s'
  end

  contact :lastfm do
    username_regexp = '[a-zA-Z][_a-zA-Z0-9\\-]{1,20}'
    sanitizer [
      %r{^(?:http://)?(?:www\.)?last\.fm/user/(#{username_regexp})},
      %r{^(#{username_regexp})$}
    ]
    formatter 'http://last.fm/user/%s'
  end

  contact :livejournal do
    sanitizer do |value|
      username_regexp = '[a-zA-Z0-9_\\-]{1,20}'
      result = value_of_matching_regexp(value, [
        %r{^(?:http://)?(?:users|community)\.livejournal\.com/(#{username_regexp})},
        %r{^(?:http://)?(#{username_regexp})\.livejournal\.com},
        %r{^(#{username_regexp})$}
      ])
      result.gsub('_', '-') if result && result != 'www'
    end
    formatter 'http://%s.livejournal.com/'
  end

  contact :lookatme do
    username_regexp = '[a-zA-Z0-9_\\-]{3,20}'
    sanitizer [
      %r{^(?:http://)?(?:www\.)?lookatme\.ru/users/(#{username_regexp})},
      %r{^(#{username_regexp})$}
    ]
    formatter 'http://lookatme.ru/users/%s'
  end

  contact :moikrug do
    sanitizer do |value|
      username_regexp = '[a-zA-Z0-9][a-zA-Z0-9_\\-]{1,20}'
      result = value_of_matching_regexp(value, [
        %r{^(?:http://)?(#{username_regexp})\.moikrug\.ru},
        %r{^(#{username_regexp})$}
      ])
      result.gsub('_', '-') if result && result != 'www'
    end
    formatter 'http://%s.moikrug.ru/'
  end

  contact :myspace do
    username_regexp = '[a-zA-Z0-9_\\-]{1,25}'
    sanitizer [
      %r{^(?:http://)?(?:www\.)?myspace\.com/(#{username_regexp})},
      %r{^(#{username_regexp})$}
    ]
    formatter 'http://myspace.com/%s'
  end

  contact :phone do
    formatter 'callto://%s/'
  end

  contact :skype do
    sanitizer %r{^[a-z][a-z0-9_,.\-]{5,31}$}i
    formatter 'skype:%s?userinfo'
  end

  contact :twitter do
    username_regexp = '[a-zA-Z0-9_\\-]{1,25}'
    sanitizer [
      %r{^(?:http://)?(?:www\.)?twitter\.com/(#{username_regexp})},
      %r{^(#{username_regexp})$}
    ]
    formatter 'http://twitter.com/%s'
  end

  contact :youtube do
    username_regexp = '[a-zA-Z0-9_\\-]{1,20}'
    sanitizer [
      %r{^(?:http://)?(?:www\.)?youtube\.com/user/(#{username_regexp})},
      %r{^(#{username_regexp})$}
    ]
    formatter 'http://youtube.com/user/%s'
  end

  contact :vkontakte do
    username_regexp = '[0-9]{1,25}'
    sanitizer [
      %r{^(?:http://)?(?:www\.)?vkontakte\.ru/id(#{username_regexp})},
      %r{^(#{username_regexp})$}
    ]
    formatter 'http://vkontakte.ru/id%s'
  end
end
