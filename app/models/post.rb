class Post < ActiveRecord::Base
  attr_accessible :title, :content, :teaser, :category_id, :tag_names
  
  belongs_to :author, class_name: "User"
  belongs_to :category
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  
  validates :title, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :content, presence: true
  validates :teaser, presence: true, length: { maximum: 500 }
  validates :author_id, presence: true
  validates :category_id, presence: true
  
  default_scope order: 'posts.created_at DESC'
  
  attr_accessor :tag_names
  after_save :assign_tags
  
  def tag_names
    @tag_names || tags.map(&:name).join(' ')
  end
  
  private
  
  def assign_tags
    if @tag_names
      self.tags = @tag_names.split(/\s+/).map do |name|
        Tag.find_or_create_by_name(name)
      end
    end
  end
end
