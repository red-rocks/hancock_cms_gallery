if defined?(Paperclip)

  module Paperclip
    class Attachment

      def inline_data
        if File.exists?(self.path)
          Paperclip.io_adapters.for(self).read.force_encoding("UTF-8").html_safe rescue ""
        end
      end

      def inline_svg
        inline_data if svg?
      end

      def svg?
        !!(content_type =~ /svg/)
      end

    end
  end

end
