# if defined?(Shrine)
#   class Hancock::Gallery::EmbeddedImageImageUploader < Shrine
if defined?(HancockShrine)
  class Hancock::Gallery::EmbeddedImageImageUploader < HancockShrine::Uploader
  
    # include ::HancockShrine::UploaderBase
    include ::HancockShrine::Uploadable

  end
end