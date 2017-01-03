module Hancock::Gallery
  module Models
    module OriginalImage
      extend ActiveSupport::Concern

      include Hancock::Model
      include Hancock::Gallery::Paperclipable
      include Hancock::Gallery.orm_specific('OriginalImage')

      included do
        if Hancock.rails4?
          belongs_to :originable, polymorphic: true
        else
          belongs_to :originable, polymorphic: true, optional: true
        end       

        def original_as_base64(content_type = nil)
          _original = self.original
          if _original
            _data = Base64.encode64(_original.data)
            _content_type = content_type
          else
            _data = ''
            _content_type = content_type || 'jpg'
          end
          "data:#{_content_type};base64,#{_data}"
        end
        def original_as_image(content_type = nil)
          "<img src='#{original_as_base64(content_type)}'>".html_safe
        end

        # def self.admin_can_default_actions
        #   [:show, :read].freeze
        # end
        # def self.manager_can_default_actions
        #   [:show, :read].freeze
        # end
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
