# Coding: UTF-8
ActiveAdmin.register User do

  batch_action :flag do |selection|
    User.find(selection).each { |u| u.flag! }
    redirect_to collection_path, :notice => "Users flagged!"
  end
    
  index do
    selectable_column
    column :id
    column "Vorname", :first_name
    column "Nachname", :last_name
    column "E-Mail-Adresse", :email
    column "Aufgabenbereich", :task_area
    column "Vorstellungstext", :introduction
    column "Erstellt", :created_at, sortable: :created_at do |user|
      user.created_at.strftime("%d.%m.%y, %H:%M")
    end
    column "Letzte Änderung", :updated_at, sortable: :updated_at do |user|
      user.updated_at.strftime("%d.%m.%y, %H:%M")
    end
    default_actions
  end
end
