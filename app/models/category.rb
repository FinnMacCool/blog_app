class Category < ActiveRecord::Base
  attr_accessible :name
  
  has_many :posts, dependent: :nullify
  
  validates :name, presence: true, uniqueness: true, length: { maximum: 30 }
  
  default_scope order: 'categories.name'
end
