if defined?(Shrine)
  class Hancock::Gallery::ImageImageUploader < Shrine
  
    # include ::HancockShrine::UploaderBase
    include ::HancockShrine::Uploadable

  end
end