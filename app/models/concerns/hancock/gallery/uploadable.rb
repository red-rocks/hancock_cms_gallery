module Hancock::Gallery::Uploadable
  extend ActiveSupport::Concern

  if defined?(Paperclip)
    include Hancock::Gallery::Paperclipable
  elsif defined?(Shrine)
    include Hancock::Gallery::Shrineable
  end

end
