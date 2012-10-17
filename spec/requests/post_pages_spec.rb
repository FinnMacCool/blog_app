# Coding: UTF-8
require 'spec_helper'

describe "Post pages" do
  
  subject { page }
  
  describe "index page" do
    before { visit root_path }
    
    it { should have_h1("WWBlog") }
    
    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:post) } }
      after(:all)  do
        Post.delete_all
        User.delete_all
        Category.delete_all
      end

      it { should have_selector('div.pagination') }

      it "should list each post correctly" do
        Post.paginate(page: 1, per_page: 5).each do |post|
          page.should have_link(post.title, href: post_path(post))
          page.should have_link(post.author.first_name, href: user_path(post.author))
          page.should have_link(post.category.name, href: category_path(post.category))
          page.should have_selector('h3', text: "verfasst")
          page.should have_selector('h3', text: "von")
          page.should have_selector('h3', text: "am")
          page.should have_selector('h3', text: "in")
          page.should have_selector('div', text: full_name(post.author))
          page.should have_selector('li', text: post.teaser)
          page.should have_link("[Mehr]", href: post_path(post))
        end
      end
    end        
  end
  
  describe "show page" do
    let(:user) { FactoryGirl.create(:user) }
    let(:post1) { FactoryGirl.create(:post, author: user) }
    
    before { visit post_path(post1) }
    
    it { should have_selector('h2', text: post1.title) }
    it { should have_title(post1.title) }
    
    describe "post info" do
      
      it { should have_link(post1.author.first_name, href: user_path(post1.author)) }
      it { should have_link(post1.category.name, href: category_path(post1.category)) }
      it { should have_selector('div', text: full_name(post1.author)) }
      it { should have_selector('div', text: post1.content) }
      
      it { should_not have_link('Bearbeiten', href: edit_post_path(post1)) }
      it { should_not have_link('Löschen', href: post_path(post1)) }
      
      describe "for author" do
        before do
          log_in user
          visit post_path(post1)
        end
        
        it { should have_link('Bearbeiten', href: edit_post_path(post1)) }
        it { should have_link('Löschen', href: post_path(post1)) }
      end
      
      describe "for admins" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          log_in admin
          visit post_path(post1)
        end
        
        it { should have_link('Bearbeiten', href: edit_post_path(post1)) }
        it { should have_link('Löschen', href: post_path(post1)) }
      end
      
      describe "for other users" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          log_in other_user
          visit post_path(post1)
        end
        
        it { should_not have_link('Bearbeiten', href: edit_post_path(post1)) }
        it { should_not have_link('Löschen', href: post_path(post1)) }
      end
    end
    
    describe "after user destruction" do
      before do
        user.destroy
        visit post_path(post1)
      end
            
      it { should_not have_selector('h3', text: "von") }
    end
    
    describe "after category destruction" do
      before do
        post1.category.destroy
        visit post_path(post1)
      end
            
      it { should_not have_selector('h3', text: "in") }
    end
  end
  
  describe "new post page" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      log_in user
      visit new_post_path
    end
    
    it { should have_h1('Neuen Eintrag erstellen') }
    it { should have_title('Neuen Eintrag erstellen') }
  end
  
  describe "new post" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      log_in user
      visit new_post_path
    end
    
    let(:submit) { "Eintrag erstellen" }
    
    describe "with missing category"  do
      it "should not create a post" do
        expect { click_button submit }.not_to change(Post, :count)
      end
      
      describe "after submission" do
        before { click_button submit }
  
        it { should have_title('Neuen Eintrag erstellen') }
        it { should have_h1('Neuen Eintrag erstellen') }
        it { should have_content('Fehler') }
        it { should have_content("Keine Kategorie vorhanden. Bitte wenden Sie sich an den zuständigen Admin.") }
      end
    end
    
    describe "without missing category" do
    let!(:category) { FactoryGirl.create(:category) }
    
    before do
      log_in user
      visit new_post_path
    end
      
      describe "with invalid information" do
        it "should not create a post" do
          expect { click_button submit }.not_to change(Post, :count)
        end
        
        describe "after submission" do
          before { click_button submit }
  
          it { should have_title('Neuen Eintrag erstellen') }
          it { should have_h1('Neuen Eintrag erstellen') }
          it { should have_content('Fehler') }
          it { should have_content("Kein Titel angegeben") }
          it { should have_content("Text fehlt") }
          it { should have_content('Teaser-Text fehlt') }
        end
      end
  
      describe "with valid information" do
        before { fill_in_valid_post_data }
  
        it "should create a post" do
          expect { click_button submit }.to change(Post, :count).by(1)
        end
        
        describe "after saving the post" do
          before { click_button submit }
          let(:post1) { Post.find_by_title("Ein Titel") }
  
          it { should_not have_content('Fehler') }
          it { should have_title(post1.title) }
          it { should have_welcome_message('Eintrag wurde erstellt.') }
        end
      end
    end
  end
  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    let(:post1) { FactoryGirl.create(:post, author: user) }
    
    before do
      log_in user
      visit edit_post_path(post1)
    end

    describe "page" do
      it { should have_h1("Eintrag bearbeiten") }
      it { should have_title("Eintrag bearbeiten") }
    end

    describe "with invalid information" do
      before do
        fill_in "Teaser-Text",  with: ""
        click_button "Änderungen speichern"
      end

      it { should have_content('Fehler') }
    end
    
    describe "with valid information" do
      let!(:new_category) { FactoryGirl.create(:category) }
      let(:new_title)  { "Neuer Titel" }
      let(:new_content) { "Neuer Text" }
      let(:new_teaser) { "Neuer Teaser-Text" }
      let(:new_tag_names) { "bla blubb" }
      
      before do
        visit edit_post_path(post1)
        select new_category.name,                   from: "Kategorie"
        fill_in "Titel",                            with: new_title
        fill_in "Text",                             with: new_content
        fill_in "Teaser-Text",                      with: new_teaser
        fill_in "Tags (durch Leerzeichen trennen)", with: new_tag_names
        click_button "Änderungen speichern"
      end

      it { should have_title(new_title) }
      it { should have_selector('div.alert.alert-success') }
      specify { post1.reload.category_id.should  == new_category.id }
      specify { post1.reload.title.should == new_title }
      specify { post1.reload.content.should == new_content }
      specify { post1.reload.teaser.should == new_teaser }
      specify { post1.reload.tag_names.should == new_tag_names }
    end
  end
end