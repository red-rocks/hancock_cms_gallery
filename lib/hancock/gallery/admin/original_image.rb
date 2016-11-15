module Hancock::Gallery
  module Admin
    module OriginalImage
      def self.config(nav_label = nil, _visible = false, fields = {})
        if nav_label.is_a?(Hash)
          nav_label, _visible, fields = nav_label[:nav_label], (nav_label[:visible].nil? ? false : nav_label[:visible]), nav_label
        elsif nav_label.is_a?(Array)
          nav_label, _visible, fields = nil, false, nav_label
        end
        if nav_label.is_a?(Boolean)
          if _visible.is_a?(Hash)
            nav_label, _visible, fields = _visible[:nav_label], nav_label, _visible
          end
          nav_label, _visible, fields = fields[:nav_label], nav_label, fields
        end

        Proc.new {
          navigation_label(!nav_label.blank? ? nav_label : I18n.t('hancock.gallery'))
          visible _visible

          field :originable
          field :original

          Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)

          if block_given?
            yield self
          end
        }
      end
    end
  end
end
