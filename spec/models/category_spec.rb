require 'spec_helper'

describe Category do
  
  before do
    @category = Category.new(name: "Kategorie B")
  end
  
  subject { @category }
  
  it { should respond_to(:name) }
  it { should respond_to(:posts) }
  
  it { should be_valid }
  
  describe "when name is blank" do
    before { @category.name = " " }
    it { should_not be_valid }
  end
  
  describe "when name is already taken" do
    before do
      category_with_same_name = @category.dup
      category_with_same_name.name = @category.name
      category_with_same_name.save
    end

    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @category.name = "a" * 31 }
    it { should_not be_valid }
  end
  
  describe "post associations" do

    before { @category.save }
    let!(:older_post) do 
      FactoryGirl.create(:post, title: "post 1", category: @category, created_at: 1.day.ago)
    end
    let!(:newer_post) do
      FactoryGirl.create(:post, title: "post 2", category: @category, created_at: 1.hour.ago)
    end
    
    it "should not destroy associated posts" do
      posts = @category.posts
      @category.destroy
      posts.each do |post|
        Post.find_by_id(post.id).should_not be_nil
        Post.find_by_id(post.id).category.should be_nil
        Post.find_by_id(post.id).category_id.should be_nil
      end
    end
  end
  
  describe "order" do
    before do
      @category.save
    end 
      let!(:category_with_preceding_name) do
        FactoryGirl.create(:category, name: "Kategorie A")
      end
    
    it "category_with_preceding_name should come first" do
      Category.all.index(category_with_preceding_name).should < Category.all.index(@category)
    end
  end 
end
