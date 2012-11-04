# Coding: UTF-8
ActiveAdmin.register Post do

  batch_action :flag do |selection|
    Post.find(selection).each { |p| p.flag! }
    redirect_to collection_path, :notice => "Posts flagged!"
  end
    
  index do
    selectable_column
    column :id
    column "Titel", :title
    column "Text", :content
    column "Teaser-Text", :teaser
    column "Erstellt", :created_at, sortable: :created_at do |post|
      post.created_at.strftime("%d.%m.%y, %H:%M")
    end
    column "Letzte Änderung", :updated_at, sortable: :updated_at do |post|
      post.updated_at.strftime("%d.%m.%y, %H:%M")
    end
    default_actions
  end
end
