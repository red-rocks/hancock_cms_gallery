module Hancock::Gallery
  module Models
    module OriginalImage
      extend ActiveSupport::Concern

      include Hancock::Model
      include Hancock::Gallery.orm_specific('OriginalImage')

      included do

        belongs_to :originable, polymorphic: true

        def self.admin_can_default_actions
          [:show, :read].freeze
        end
        def self.manager_can_default_actions
          [:show, :read].freeze
        end
        def self.admin_cannot_actions
          [:new, :create, :edit, :update].freeze
        end
        def self.manager_cannot_actions
          [:new, :create, :edit, :update].freeze
        end

      end

    end
  end
end
