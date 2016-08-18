if defined?(Paperclip)
  Paperclip.options[:content_type_mappings] ||= {}
  Paperclip.options[:content_type_mappings].merge!({svg: "image/svg+xml"})
end
