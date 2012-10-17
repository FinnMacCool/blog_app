namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_categories
    make_posts
  end
end

def make_users
  admin = User.create!(first_name:            "The",
                       last_name:             "Admin",
                       email:                 "admin@example.org",
                       task_area:             "Administration",
                       introduction:          "Hail to the admin, baby!^^",
                       password:              "foobar",
                       password_confirmation: "foobar")
  admin.toggle!(:admin)
  19.times do |n|
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    email = "user#{n+1}@example.org"
    task_area = "Aufgabenbereich #{n+1}"
    introduction = "Generischer User Nr. #{n+1}"
    password  = "foobar"
    User.create!(first_name:            first_name,
                 last_name:             last_name,
                 email:                 email,
                 task_area:             task_area,
                 introduction:          introduction,
                 password:              password,
                 password_confirmation: password)
  end
end

def make_categories
  5.times do |n|
    name = "Kategorie #{n+1}"
    Category.create!(name: name)
  end
end

def make_posts
  users = User.all(limit: 6)
  5.times do |n|
    content = Faker::Lorem.paragraphs(10).join(" ")
    teaser = content.slice(0, 500)
    users.each do |user|
      title = "#{n+1}. Eintrag von User #{user.id - 1}"
      category_id = rand(Category.count) + 1
      tag_names = (n%2 == 0 ? "bla" : "blubb")
      user.posts.create!(title:       title,
                         content:     content,
                         teaser:      teaser,
                         category_id: category_id,
                         tag_names:   tag_names)
    end
  end
end