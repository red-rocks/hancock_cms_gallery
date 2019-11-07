# if defined?(Shrine)
#   class Hancock::Gallery::ImageImageUploader < Shrine
if defined?(HancockShrine)
  class Hancock::Gallery::ImageImageUploader < HancockShrine::Uploader
  
    # include ::HancockShrine::UploaderBase
    include ::HancockShrine::Uploadable

  end
end