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

  module ClassMethods
    def has_contacts(*args)
      options = args.extract_options!
      args = args + Contacts.contact_types.keys if args.delete(:all)
      args.map(&:to_sym).uniq.each do |name|
        name = name.to_sym
        as = (options[:as] || name).to_sym
        class_eval %Q{
          def #{name}=(value)
            set_contact(#{name.inspect}, value, #{{:as => as}.inspect})
          end
          def #{name}
            get_contact(#{name.inspect}, #{{:as => as}.inspect})
          end
          def #{name}_link
            format_contact(#{name.inspect}, #{{:as => as}.inspect})
          end
          def #{name}?
            #{name}.present?
          end
        }, __FILE__, __LINE__
      end
      unless include?(InstanceMethods)
        serialize :contacts, Hash
        validate :contacts_must_be_valid
        include InstanceMethods
      end
    end
    alias_method :has_contact, :has_contacts
  end

  module InstanceMethods
  private
    def set_contact(name, value, options = {})
      contacts_will_change!
      self.contacts ||= {}
      if contact_type = Contacts.contact_types[options[:as]]
        contacts[name] = contact_type.sanitize(value) || value
      else
        raise "Unknown contact type: #{options[:as].inspect}"
      end
    end

    def get_contact(name, options = {})
      contacts && contacts[name]
    end

    def format_contact(name, options = {})
      value = get_contact(name, options)
      if contact_type = Contacts.contact_types[options[:as]]
        contact_type.format(value) if value.present?
      else
        raise "Unknown contact type: #{options[:as].inspect}"
      end
    end

    def contacts_must_be_valid
      if contacts
        contacts.each do |name, value|
          if value.present?
            if contact_type = Contacts.contact_types[name]
              errors.add(name) unless contact_type.sanitize(value).present?
            end
          end
        end
      end
    end
  end

  def self.contact_types
    @contact_types ||= {}
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def self.sorted
    @sorted = ''
    yield
  ensure
    @sorted = nil
  end

  def self.contact(name, &block)
    name = name.to_sym
    if @sorted
      RAILS_DEFAULT_LOGGER.warn "contact type #{name} is out of order" if name.to_s < @sorted
      @sorted = name.to_s
    end
    contact_type = ContactType.new
    contact_type.instance_eval(&block) if block
    if contact_types[name]
      RAILS_DEFAULT_LOGGER.warn "contact type #{name} already defined"
    end
    contact_types[name] = contact_type
  end
end
