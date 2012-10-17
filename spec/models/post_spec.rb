require 'spec_helper'

describe Post do

  let(:user) { FactoryGirl.create(:user) }
  let(:category) { FactoryGirl.create(:category) }
  before { @post = user.posts.build(title: "Titel", content: "Lorem ipsum", 
                                    teaser: "Lorem", category_id: category.id) }

  subject { @post }
  
  it { should respond_to(:title) }
  it { should respond_to(:content) }
  it { should respond_to(:teaser) }
  it { should respond_to(:tag_names) }
  it { should respond_to(:author_id) }
  it { should respond_to(:author) }
  it { should respond_to(:category_id) }
  it { should respond_to(:category) }
  its(:author) { should == user }
  its(:category) { should == category }

  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to author_id" do
      expect do
        Post.new(author_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "when author_id is not present" do
    before { @post.author_id = nil }
    it { should_not be_valid }
  end

  describe "when title is blank" do
    before { @post.title = " " }
    it { should_not be_valid }
  end
  
  describe "when title is already taken" do
    before do
      post_with_same_title = @post.dup
      post_with_same_title.title = @post.title
      post_with_same_title.save
    end

    it { should_not be_valid }
  end

  describe "when title is too long" do
    before { @post.title = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when content is blank" do
    before { @post.content = " " }
    it { should_not be_valid }
  end

  describe "when teaser is blank" do
    before { @post.teaser = " " }
    it { should_not be_valid }
  end

  describe "when teaser is too long" do
    before { @post.teaser = "a" * 501 }
    it { should_not be_valid }
  end

  describe "when category_id is not present" do
    before { @post.category_id = nil }
    it { should_not be_valid }
  end
end
