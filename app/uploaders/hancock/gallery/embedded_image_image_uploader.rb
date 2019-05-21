if defined?(Shrine)
  class Hancock::Gallery::EmbeddedImageImageUploader < Shrine
  
    # include ::HancockShrine::UploaderBase
    include ::HancockShrine::Uploadable

  end
end