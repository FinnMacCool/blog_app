# Coding: UTF-8
require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "login page" do
    before { visit login_path }

    it { should have_h1('Login') }
    it { should have_title('Login') }
  end
  
  describe "login" do
    before { visit login_path }

    describe "with invalid information" do
      before { click_button "Login" }

      it { should have_title('Login') }
      it { should have_error_message('E-Mail-Adresse und/oder Passwort falsch') }
      
      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { log_in user }

      it { should have_h1('WWBlog') }
      it { should have_link('Neuer Eintrag',  href: new_post_path) }
      it { should have_link('Profil',         href: user_path(user)) }
      it { should have_link('Logout',         href: logout_path) }
    
      describe "followed by logout" do
        before { click_link "Logout" }
        it { should_not have_link('Neuer Eintrag',  href: new_post_path) }
        it { should_not have_link('Profil',         href: user_path(user)) }
        it { should_not have_link('Logout',         href: logout_path) }
      end
    end
  end
  
  describe "authorization" do

    describe "for non-logged-in users" do
      let(:user) { FactoryGirl.create(:user) }
      
      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "E-Mail-Adresse", with: user.email
          fill_in "Passwort",       with: user.password
          click_button "Login"
        end

        describe "after logging in" do

          it "should render the desired protected page" do
            page.should have_title('Profil bearbeiten')
          end
          
          describe "when logging in again" do
            before do
              visit login_path
              fill_in "E-Mail-Adresse", with: user.email
              fill_in "Passwort",       with: user.password
              click_button "Login"
            end

            it "should render the default (home) page" do
              page.should have_h1('WWBlog') 
            end
          end
        end
      end
      
      describe "in the Categories controller" do
        let(:category) { FactoryGirl.create(:category) }
        
        describe "visiting the new page" do
          before { visit new_category_path }
          it { should have_title('Login') }
        end
        
        describe "submitting to the create action" do
          before { post categories_path }
          specify { response.should redirect_to(login_path) }
        end
        
        describe "visiting the edit page" do
          before { visit edit_category_path(category) }
          it { should have_title('Login') }
        end

        describe "submitting to the update action" do
          before { put category_path(category) }
          specify { response.should redirect_to(login_path) }
        end

        describe "submitting to the destroy action" do
          before { delete category_path(category) }
          specify { response.should redirect_to(login_path) }          
        end
      end
      
      describe "in the Posts controller" do
        let(:post1) { FactoryGirl.create(:post) }
        
        describe "visiting the new page" do
          before { visit new_post_path }
          it { should have_title('Login') }
        end

        describe "submitting to the create action" do
          before { post posts_path }
          specify { response.should redirect_to(login_path) }
        end
        
        describe "visiting the edit page" do
          before { visit edit_post_path(post1) }
          it { should have_title('Login') }
        end

        describe "submitting to the update action" do
          before { put post_path(post1) }
          specify { response.should redirect_to(login_path) }
        end

        describe "submitting to the destroy action" do
          before { delete post_path(post1) }
          specify { response.should redirect_to(login_path) }
        end
      end

      describe "in the Users controller" do
        
        describe "visiting the new page" do
          before { visit new_user_path }
          it { should have_title('Login') }
        end

        describe "submitting to the create action" do
          before { post users_path }
          specify { response.should redirect_to(login_path) }
        end

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Login') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(login_path) }
        end

        describe "submitting to the destroy action" do
          before { delete user_path(user) }
          specify { response.should redirect_to(login_path) }
        end
      end
    end
    
    describe "for wrong (non-admin) users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      
      before { log_in wrong_user }
      
      describe "in the Posts controller" do
        let!(:post1) { FactoryGirl.create(:post, author_id: user.id) }
        
        describe "visiting the edit page" do
          before { visit edit_post_path(post1) }
          it { should_not have_title('Eintrag bearbeiten') }
        end
        
        describe "submitting to the update action" do
          before { put post_path(post1) }
          specify { response.should redirect_to(root_path) }
        end
        
        describe "submitting to the destroy action" do
          it { expect { delete post_path(post1) }.to_not change(Post, :count) }
        end
      end
      
      describe "in the Users controller" do
        
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should_not have_title(full_title('Profil bearbeiten')) }
        end
  
        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(root_path) }
        end
      end
    end
    
    describe "for non-admin users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { log_in non_admin }
      
      describe "in the Categories controller" do
        let(:category) { FactoryGirl.create(:category) }
        
        describe "visiting the new page" do
          before { visit new_category_path }
          it { should have_h1('WWBlog') }
        end
        
        describe "submitting to the create action" do
          before { post categories_path }
          specify { response.should redirect_to(root_path) }
        end
        
        describe "visiting the edit page" do
          before { visit edit_category_path(category) }
          it { should have_h1('WWBlog') }
        end

        describe "submitting to the update action" do
          before { put category_path(category) }
          specify { response.should redirect_to(root_path) }
        end

        describe "submitting to the destroy action" do
          before { delete category_path(category) }
          specify { response.should redirect_to(root_path) }          
        end
      end
      
      describe "in the Users controller" do
        
        describe "visiting the new page" do
          before { visit new_user_path }
          it { should have_h1('WWBlog') }
        end

        describe "submitting to the create action" do
          before { post users_path }
          specify { response.should redirect_to(root_path) }
        end
        
        describe "submitting to the destroy action" do
          before { delete user_path(user) }
          specify { response.should redirect_to(root_path) }        
        end
      end
    end
  end
end