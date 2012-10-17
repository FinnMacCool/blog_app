# Coding: UTF-8
require 'spec_helper'

describe "Category pages" do
  
  subject { page }
  
  describe "index page" do
    before { visit categories_path }
    
    it { should have_h1("Liste der Kategorien") }
    it { should have_title("Liste der Kategorien") }
    
    describe "listing" do

      before(:all) { 30.times { FactoryGirl.create(:category) } }
      after(:all)  { Category.delete_all }

      it "should list each category" do
        Category.all.each do |category|
          page.should have_selector('li', text: "#{category.name} (#{category.posts.count})")
        end
      end
    
      describe "delete and rename links" do
  
        it { should_not have_link('löschen') }
        it { should_not have_link('umbenennen') }
        
        describe "as a normal user" do
          let(:user) { FactoryGirl.create(:user) }
          before do
            log_in user
            visit categories_path
          end
          
          it { should_not have_link('löschen') }
          it { should_not have_link('umbenennen') }
        end
  
        describe "as an admin user" do
          let(:admin) { FactoryGirl.create(:admin) }
          before do
            log_in admin
            visit categories_path
          end
  
          it "should have links for each category" do
            Category.all.each do |category|
              page.should have_link('löschen', href: category_path(category))
              page.should have_link('umbenennen', href: edit_category_path(category))
            end
          end
          
          it "should be able to delete a category" do
            expect { click_link('löschen') }.to change(Category, :count).by(-1)
          end
        end
      end
    end
    
    describe "new category link" do
      
      it { should_not have_link("Neue Kategorie", href: new_category_path) }
      
      describe "as a normal user" do

        let(:user) { FactoryGirl.create(:user) }

        before do
          log_in user
          visit categories_path
        end

        it { should_not have_link("Neue Kategorie", href: new_category_path) }
        
      end
      
      describe "as admin" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          log_in admin
          visit categories_path
        end
        
        it { should have_link("Neue Kategorie", href: new_category_path)}
      end
    end
  end
  
  describe "show page" do
    let!(:category) { FactoryGirl.create(:category) }
    let!(:p1) { FactoryGirl.create(:post, category: category) }
    let!(:p2) { FactoryGirl.create(:post, category: category) }

    before { visit category_path(category) }

    it { should have_selector('h1',    text: "#{category.name} (#{category.posts.count})") }
    it { should have_selector('title', text: category.name) }

    describe "posts" do
      it { should have_content(p1.title) }
      it { should have_content(p2.title) }
      it { should have_content(p1.teaser) }
      it { should have_content(p2.teaser) }
    end
    
    describe "delete and rename links" do
  
      it { should_not have_link('löschen') }
      it { should_not have_link('umbenennen') }
      
      describe "as a normal user" do
        let(:user) { FactoryGirl.create(:user) }
        before do
          log_in user
          visit category_path(category)
        end
        
        it { should_not have_link('löschen') }
        it { should_not have_link('umbenennen') }
      end
  
      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          log_in admin
          visit category_path(category)
        end
  
        it { should have_link('löschen', href: category_path(category)) }
        it { should have_link('umbenennen', href: edit_category_path(category)) }
        
        it "should be able to delete a category" do
          expect { click_link('löschen') }.to change(Category, :count).by(-1)
        end
      end
    end
    
    describe "pagination" do

      before(:all) { 18.times { FactoryGirl.create(:post, category: category) } }
      after(:all) do
        Post.delete_all
        User.delete_all
        Category.delete_all
      end

      it { should have_selector('div.pagination') }
    end   
  end
  
  describe "new category page" do
    let(:admin) { FactoryGirl.create(:admin) }
    before do
      log_in admin
      visit new_category_path
    end

    it { should have_h1('Neue Kategorie erstellen') }
    it { should have_title(full_title('Neue Kategorie erstellen')) }
  end
  
  describe "new category" do
    let(:admin) { FactoryGirl.create(:admin) }
    before do
      log_in admin
      visit new_category_path
    end

    let(:submit) { "Kategorie erstellen" }

    describe "with invalid information" do
      it "should not create a category" do
        expect { click_button submit }.not_to change(Category, :count)
      end
      
      describe "after submission" do
        before { click_button submit }

        it { should have_title('Neue Kategorie erstellen') }
        it { should have_h1('Neue Kategorie erstellen') }
        it { should have_content('Fehler') }
        it { should have_content("Kein Name angegeben") }
      end
    end

    describe "with valid information" do
      before { fill_in "Name",  with: "Eine Kategorie" }

      it "should create a category" do
        expect { click_button submit }.to change(Category, :count).by(1)
      end
      
      describe "after saving the category" do
        before { click_button submit }
        let(:category) { Category.find_by_name('Eine Kategorie') }

        it { should have_title(category.name) }
        it { should have_welcome_message("Kategorie #{category.name} wurde erstellt.") }
      end
    end
  end
  
  describe "edit" do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:category) { FactoryGirl.create(:category) }
    
    before do
      log_in admin
      visit edit_category_path(category)
    end

    describe "page" do
      it { should have_h1("Kategorie umbenennen") }
      it { should have_title("Kategorie umbenennen") }
    end

    describe "with invalid information" do
      before do
        fill_in "Name", with: ""
        click_button "Namen ändern"
      end

      it { should have_content('Fehler') }
    end
    
    describe "with valid information" do
      let(:new_name) { "Neuer Name" }
      
      before do
        visit edit_category_path(category)
        fill_in "Name", with: new_name
        click_button "Namen ändern"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      specify { category.reload.name.should  == new_name }
    end
  end
end