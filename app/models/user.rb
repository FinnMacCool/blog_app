class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :task_area, :introduction, :password, :password_confirmation
  has_secure_password
  
  before_save :create_remember_token
    
  has_many :posts, foreign_key: "author_id"
  
  validates :first_name, presence: true, length: { maximum: 20 }
  validates :last_name, presence: true, length: { maximum: 40 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :task_area, presence: true, length: { maximum: 40 }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  
  default_scope order: 'users.last_name'
  
  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
