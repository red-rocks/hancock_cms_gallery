class HancockGalleryCreateGallery < ActiveRecord::Migration
  def change
    ########### c #################
    create_table :hancock_gallery_images do |t|
      t.integer :gallery_id

      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth

      # t.integer :hancock_gallery_imagable_id
      # t.string :hancock_gallery_imagable_type
      t.references :hancock_gallery_imagable, polymorphic: true, index: {name: :index_hancock_gallery_images_on_imagable}

      t.boolean :enabled, default: true, null: false

      if Hancock::Gallery.config.localize
        t.column :name_translations, 'hstore', default: {}
      else
        t.string :name, null: false
      end

      t.attachment :image
      t.timestamps
    end

    add_index :hancock_gallery_images, [:enabled, :lft]
    add_index :hancock_gallery_images, [:gallery_id]
    # add_index :hancock_gallery_images, [:hancock_gallery_imagable_id, :hancock_gallery_imagable_type]



    ########### Galleries #################
    create_table :hancock_gallery_gallery do |t|
      t.boolean :enabled, default: true, null: false

      if Hancock::Gallery.config.localize
        t.column :name_translations, 'hstore', default: {}
      else
        t.string :name, null: false
      end

      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth

      t.string :slug, null: false
      t.attachment :image
      t.timestamps
    end

    add_index :hancock_gallery_galleries, :slug, unique: true
    add_index :hancock_gallery_galleries, [:enabled, :lft]

  end
end
