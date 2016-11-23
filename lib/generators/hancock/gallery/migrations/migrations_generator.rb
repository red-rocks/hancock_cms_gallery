require 'rails/generators'
require 'rails/generators/active_record'

module Hancock::Gallery
  class MigrationsGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    desc 'Hancock Gallery migration generator'
    def migration
      if Hancock.active_record?
        %w(gallery).each do |table_name|
          migration_template "migration_#{table_name}.rb", "db/migrate/hancock_gallery_create_#{table_name}.rb"
        end
      end
    end
  end
end
