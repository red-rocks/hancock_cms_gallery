module Hancock::Gallery::Uploadable
  extend ActiveSupport::Concern

  if defined?(Shrine)
    include Hancock::Gallery::Shrineable
  elsif defined?(Paperclip)
    include Hancock::Gallery::Paperclipable
  end

end
