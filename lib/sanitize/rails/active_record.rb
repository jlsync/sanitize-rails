module Sanitize::Rails

  # Adds the +sanitizes+ method to ActiveRecord children classes
  #
  module ActiveRecord
    # Generates before_save/before_create filters that implement
    # sanitization on the given fields, in the given callback
    # point.
    #
    # Usage:
    #
    #   sanitizes :some_field, :some_other_field #, :on => :save
    #
    # Valid callback points are :save and :create, callbacks are installed "before_"
    # by default. Generated callbacks are named with the "sanitize_" prefix follwed
    # by the field names separated by an underscore.
    #
    def sanitizes(*fields)
      options   = fields.extract_options!
      callback  = Engine.callback_for(options)
      sanitizer = Engine.method_for(fields)

      define_method(sanitizer) do                  # # Unrolled version
        fields.each do |field|                     #
          value = send(field)
          unless value.blank?                      # def sanitize_fieldA_fieldB
            sanitized = Engine.clean(value)        #   self.fieldA = Engine.clean(self.fieldA) unless fieldA.blank?
            send("#{field}=", sanitized)           #   self.fieldB = Engine.clean(self.fieldB) unless fieldB.blank?
          end                                      # end
        end                                        #
      end                                          # end

      protected sanitizer                          # protected :sanitize_fieldA_fieldB
      send callback, sanitizer                     # before_save :sanitize_fieldA_fieldB
    end
  end

end
