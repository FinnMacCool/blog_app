# Coding: UTF-8
ActiveAdmin.register Category do

  batch_action :flag do |selection|
    Category.find(selection).each { |c| c.flag! }
    redirect_to collection_path, :notice => "Categories flagged!"
  end
    
  index do
    selectable_column
    column :id
    column "Name", :name
    column "Erstellt", :created_at, sortable: :created_at do |category|
      category.created_at.strftime("%d.%m.%y, %H:%M")
    end
    column "Letzte Änderung", :updated_at, sortable: :updated_at do |category|
      category.updated_at.strftime("%d.%m.%y, %H:%M")
    end
    default_actions
  end
end
