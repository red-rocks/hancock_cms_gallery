module Hancock::Gallery::Gallerable
  extend ActiveSupport::Concern

  module ClassMethods
    def hancock_gallerable_field(name = :galleries, opts = {})
      class_name = opts.delete(:class_name)
      class_name ||= "Hancock::Gallery::Gallery"

      has_many name, as: :hancock_gallerable, class_name: class_name
    end
  end

end
