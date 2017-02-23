if defined?(Paperclip)

  module Paperclip
    class Attachment

      def inline_svg
        Paperclip.io_adapters.for(self).read.force_encoding("UTF-8").html_safe
      end

      def svg?
        !!(content_type =~ /svg/)
      end

    end
  end

end
