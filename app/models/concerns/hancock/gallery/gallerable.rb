module Hancock::Gallery::Gallerable
  extend ActiveSupport::Concern

  module ClassMethods
    def hancock_gallerable_field(name = :hancock_gallerable, opts = {})
      class_name = opts.delete(:class_name)
      class_name ||= "Hancock::Gallery::Gallery"

      belongs_to name, polymorphic: true

      class_eval <<-EVAL
        before_save do
          self.#{name}_id = nil   if self.#{name}_type.nil?
          self.#{name}_type = nil if self.#{name}_id.nil?
          self
        end
      EVAL

    end
  end

end
