module Contacts
  class ContactType
    def sanitizer(arg = nil, &block)
      @sanitizer = arg || block
    end

    def sanitize(value)
      case @sanitizer
      when Regexp
        value_of_matching_regexp(value, [@sanitizer])
      when Proc
        @sanitizer.call(value)
      when Array
        value_of_matching_regexp(value, @sanitizer)
      when nil
        value
      else
        raise "Unknown type of sanitizer: #{@sanitizer.inspect}"
      end
    end

    def formatter(arg = nil, &block)
      @formatter = arg || block
    end

    def format(value)
      case @formatter
      when String
        @formatter % value
      when Proc
        @formatter.call(value)
      when nil
        value
      else
        raise "Unknown type of formatter: #{@formatter.inspect}"
      end
    end

  private

    def value_of_matching_regexp(value, regexps)
      if regexps.find{ |regexp| regexp === value }
        match = $1 || $&
        block_given? ? yield(match) : match
      end
    end
  end

  def self.contact_types
    @@contact_types ||= {}
  end

  def self.included(base)
    base.send :serialize, :contacts, Hash
    base.send :validate, :contacts_must_be_valid
  end

  def self.contact(name, &block)
    contact_type = ContactType.new
    contact_type.instance_eval(&block) if block
    contact_types[name.to_sym] = contact_type
    class_eval %Q{
      def #{name}=(value)
        set_contact(#{name.inspect}, value)
      end
      def #{name}
        get_contact(#{name.inspect})
      end
      def #{name}_link
        format_contact(#{name.inspect})
      end
    }, __FILE__, __LINE__
  end

private

  def set_contact(name, value)
    contacts_will_change!
    self.contacts ||= {}
    if contact_type = Contacts.contact_types[name]
      contacts[name] = contact_type.sanitize(value) || value
    else
      raise "Unknown contact type: #{name.inspect}"
    end
  end

  def get_contact(name)
    contacts && contacts[name]
  end

  def format_contact(name)
    value = get_contact(name)
    if contact_type = Contacts.contact_types[name]
      contact_type.format(value) if value.present?
    else
      raise "Unknown contact type: #{name.inspect}"
    end
  end

  def contacts_must_be_valid
    contacts.each do |name, value|
      if value.present?
        if contact_type = Contacts.contact_types[name]
          errors.add(name) unless contact_type.sanitize(value).present?
        end
      end
    end
  end
end
