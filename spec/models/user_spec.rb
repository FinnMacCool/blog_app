require 'spec_helper'

describe User do
  
  before do
    @user = User.new(first_name: "Hans", last_name: "Wurst", email: "hw@example.com", task_area: "Unfug",
                     introduction: "Ein Platzhalter.", password: "foobar", password_confirmation: "foobar")
  end
  
  subject { @user }
  
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:email) }
  it { should respond_to(:task_area) }
  it { should respond_to(:introduction) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:posts) }
  
  it { should be_valid }
  it { should_not be_admin }
  
  describe "accessible attributes" do
    it "should not allow access to admin" do
      expect do
        User.new(admin: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when first name is not present" do
    before { @user.first_name = " " }
    it { should_not be_valid }
  end
  
  describe "when first name is too long" do
    before { @user.first_name = "a" * 21 }
    it { should_not be_valid }
  end

  describe "when last name is not present" do
    before { @user.last_name = " " }
    it { should_not be_valid }
  end
  
  describe "when last name is too long" do
    before { @user.last_name = "a" * 41 }
    it { should_not be_valid }
  end
  
  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end
  
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end      
    end
  end
  
  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end
  
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end
  
  describe "when task area is not present" do
    before { @user.task_area = " " }
    it { should_not be_valid }
  end
  
  describe "when task area name is too long" do
    before { @user.task_area = "a" * 41 }
    it { should_not be_valid }
  end
  
  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end
  
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end
  
  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end
  
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
  
  describe "post associations" do

    before { @user.save }
    let!(:older_post) do 
      FactoryGirl.create(:post, title: "post 1", author: @user, created_at: 1.day.ago)
    end
    let!(:newer_post) do
      FactoryGirl.create(:post, title: "post 2", author: @user, created_at: 1.hour.ago)
    end

    it "should have the right posts in the right order" do
      @user.posts.should == [newer_post, older_post]
    end
    
    it "should not destroy associated posts" do
      posts = @user.posts
      @user.destroy
      posts.each do |post|
        Post.find_by_id(post.id).should_not be_nil
        Post.find_by_id(post.id).author.should be_nil
        Post.find_by_id(post.id).author_id.should be_nil
      end
    end
  end
  
  describe "order" do
    before do
      @user.save
    end 
      let!(:user_with_preceding_last_name) do
        FactoryGirl.create(:user, first_name: "Hans", last_name: "Meiser", email: "hm@example.com", task_area: "Unfug",
                           introduction: "Ein Platzhalter.", password: "foobar", password_confirmation: "foobar")
      end
    
    it "user_with_preceding_last_name should come first" do
      User.all.index(user_with_preceding_last_name).should < User.all.index(@user)
    end
  end 
end