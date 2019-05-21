module Hancock::Gallery::Paperclipable
  extend ActiveSupport::Concern

  # include Hancock::Gallery::AutoCrop

  module ClassMethods
    def hancock_cms_attached_file(name, opts = {})
      if Hancock.active_record?
        include Hancock::Gallery::ActiveRecordPaperclip
        hancock_cms_active_record_attached_file(name, opts)

      elsif Hancock.mongoid?
        include Hancock::Gallery::MongoidPaperclip
        hancock_cms_mongoid_attached_file(name, opts)
      end
    end
  end

end
