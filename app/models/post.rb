class Post < ActiveRecord::Base
  acts_as_ordered_taggable
  attr_accessible :title, :content, :teaser, :category_id, :tag_names
  
  belongs_to :author, class_name: "User"
  belongs_to :category
  
  validates :title, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :content, presence: true
  validates :teaser, presence: true, length: { maximum: 500 }
  validates :author_id, presence: true
  validates :category_id, presence: true
  
  default_scope order: 'posts.created_at DESC'
  
  attr_accessor :tag_names
  before_save :assign_tags
  
  def tag_names
    @tag_names || tag_list.join(' ')
  end
  
  def self.search(search_tags)
    unless search_tags.blank?
      self.tagged_with(search_tags.split(/\s+/), any: true)
    else
      self
    end
  end
  
  private
  
  def assign_tags
    if @tag_names
      self.tag_list = @tag_names.split(/\s+/)
    end
  end
end
