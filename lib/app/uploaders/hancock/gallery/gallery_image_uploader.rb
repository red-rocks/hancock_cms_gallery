# if defined?(Shrine)
#   class Hancock::Gallery::GalleryImageUploader < Shrine
if defined?(HancockShrine)
  class Hancock::Gallery::GalleryImageUploader < HancockShrine::Uploader
  
    # include ::HancockShrine::UploaderBase
    include ::HancockShrine::Uploadable

  end
end