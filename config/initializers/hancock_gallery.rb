Hancock.rails_admin_configure do |config|
  config.action_visible_for :nested_set, 'Hancock::Gallery::Gallery'
  config.action_visible_for :nested_set, 'Hancock::Gallery::Image'

  if defined?(RailsAdminComments)
    config.action_visible_for :comments, 'Hancock::Gallery::Gallery'
    config.action_visible_for :comments, 'Hancock::Gallery::Image'

    config.action_visible_for :model_comments, 'Hancock::Gallery::Gallery'
    config.action_visible_for :model_comments, 'Hancock::Gallery::Image'
  end

  if defined?(RailsAdminMultipleFileUpload)
    if true or Hancock::Catalog.active_record?
      config.action_visible_for :multiple_file_upload, 'Hancock::Gallery::Gallery'
      config.action_visible_for :multiple_file_upload_collection, 'Hancock::Gallery::Image'
    end
  end
end

if defined?(RailsAdmin)
  RailsAdmin.config do |config|
    config.excluded_models ||= []
    config.excluded_models << [
      'Hancock::Gallery::EmbeddedImage'
    ]
    config.excluded_models.flatten!
  end
end
