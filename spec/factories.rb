FactoryGirl.define do
  factory :user, aliases: [:author] do
    sequence(:first_name)  { |n| "Vorname#{n+1}" }
    sequence(:last_name)  { |n| "Nachname#{n+1}" }
    sequence(:email) { |n| "v.nachname#{n+1}@example.com"}
    task_area "Unfug"
    introduction "Ein weiterer generischer Mitarbeiter."
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end
  
  factory :category do
    sequence(:name) { |n| "Kategorie #{n+1}" }
  end

  factory :post do
    sequence(:title) { |n| "Titel#{n}" }
    sequence(:content) { |n| "Lorem ipsum#{n}" }
    sequence(:teaser) { |n| "Lorem#{n}" }
    category
    author
  end
end