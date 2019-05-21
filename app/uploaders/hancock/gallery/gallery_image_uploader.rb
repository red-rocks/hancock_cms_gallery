if defined?(Shrine)
  class Hancock::Gallery::GalleryImageUploader < Shrine
  
    # include ::HancockShrine::UploaderBase
    include ::HancockShrine::Uploadable

  end
end