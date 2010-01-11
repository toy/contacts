module Contacts
  class ContactType
    attr_reader :cleaner
    def clean(arg = nil, &block)
      @cleaner = arg || block
    end
    attr_reader :formatter
    def format(arg = nil, &block)
      @formatter = arg || block
    end
  end

  def self.contact_types
    @@contact_types ||= {}
  end

  def self.contact(name, &block)
    contact_type = ContactType.new
    contact_type.instance_eval(&block) if block
    contact_types[name.to_sym] = contact_type
    Contacts.class_eval %Q{
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
end
