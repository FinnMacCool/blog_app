# Coding: UTF-8
require 'spec_helper'

describe "User pages" do

  subject { page }
  
  describe "index" do

    let!(:user) { FactoryGirl.create(:user) }

    before(:each) { visit users_path }

    it { should have_title('Liste der User') }
    it { should have_h1('Liste der User') }

    describe "listing" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it "should list each user" do
        User.all.each do |user|
          page.should have_selector('li', text: full_name(user))
        end
      end
    end
    
    describe "delete links" do

      it { should_not have_link('löschen') }
      
      describe "as a normal user" do
        before do
          log_in user
          visit users_path
        end

        it { should_not have_link('löschen') }
        
      end

      describe "as admin" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          log_in admin
          visit users_path
        end

        it { should have_link('löschen', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('löschen') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('löschen', href: user_path(admin)) }
        
        describe "submitting a DELETE request to the Users#destroy action for the admin himself" do
          it { expect { delete user_path(admin) }.to_not change(User, :count) }
        end
      end
    end
    
    describe "new user link" do
      
      it { should_not have_link("Neuer User", href: new_user_path) }
      
      describe "as a normal user" do

        let(:user) { FactoryGirl.create(:user) }

        before do
          log_in user
          visit users_path
        end

        it { should_not have_link("Neuer User", href: new_user_path) }
        
      end
      
      describe "as admin" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          log_in admin
          visit users_path
        end
        
        it { should have_link("Neuer User", href: new_user_path)}
      end
    end
  end
  
  describe "profile page" do
    let!(:user) { FactoryGirl.create(:user) }

    before do
      visit user_path(user)
    end

    it { should have_selector('h1',    text: full_name(user)) }
    it { should have_selector('title', text: full_name(user)) }
    
    describe "user stats" do
      
      it { should have_selector('div', text: user.email) }
      it { should have_selector('div', text: user.task_area) }
      it { should have_selector('div', text: user.introduction) }
      it { should_not have_link('Profil bearbeiten', href: edit_user_path(user)) }
      
      describe "for the user himself" do
        before do
          log_in user
          visit user_path(user)
        end
        
        it { should have_link('Profil bearbeiten', href: edit_user_path(user)) }
      end
      
      describe "for other users" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          log_in other_user
          visit user_path(user)
        end

        it { should_not have_link('Profil bearbeiten', href: edit_user_path(user)) }
      end
      
      describe "for admins" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          log_in admin
          visit user_path(user)
        end

        it { should have_link('Profil bearbeiten', href: edit_user_path(user)) }
      end
    end
  end

  describe "new user page" do
    let(:admin) { FactoryGirl.create(:admin) }
    before do
      log_in admin
      visit new_user_path
    end

    it { should have_h1('Neuen User erstellen') }
    it { should have_title(full_title('Neuen User erstellen')) }
  end
  
  describe "new user" do
    let(:admin) { FactoryGirl.create(:admin) }
    before do
      log_in admin
      visit new_user_path
    end

    let(:submit) { "User erstellen" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
      
      describe "after submission" do
        before { click_button submit }

        it { should have_title('Neuen User erstellen') }
        it { should have_h1('Neuen User erstellen') }
        it { should have_content('Fehler') }
        it { should have_content("Kein Passwort angegeben") }
        it { should have_content("Kein Vorname angegeben") }
        it { should have_content('Kein Nachname angegeben') }
        it { should have_content("Keine E-Mail-Adresse angegeben") }
        it { should have_content('Ungültige E-Mail-Adresse') }
        it { should have_content("Kein Aufgabenbereich angegeben") }
        it { should have_content("Passwort ist zu kurz (mind. 6 Zeichen)") }
        it { should have_content("Passwort muss bestätigt werden") }
      end
    end

    describe "with valid information" do
      before { fill_in_valid_signup_data }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('hw@example.com') }

        it { should have_title(full_name(user)) }
        it { should have_welcome_message('Neuer User wurde erstellt.') }
      end
    end
  end
  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      log_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_h1("Profil bearbeiten") }
      it { should have_title("Profil bearbeiten") }
    end

    describe "with invalid information" do
      before { click_button "Änderungen speichern" }

      it { should have_content('Fehler') }
    end
    
    describe "with valid information" do
      let(:new_last_name)  { "Neuer Nachname" }
      let(:new_email) { "new@example.com" }
      let(:new_task_area) { "Blödsinn" }
      let(:new_introduction) { "Bla" }
      before do
        fill_in "Vorname",                      with: user.first_name
        fill_in "Nachname",                     with: new_last_name
        fill_in "E-Mail-Adresse",               with: new_email
        fill_in "Aufgabenbereich",              with: new_task_area
        fill_in "Vorstellungstext (optional)",  with: new_introduction
        fill_in "Passwort",                     with: user.password
        fill_in "Passwort bestätigen",          with: user.password
        click_button "Änderungen speichern"
      end

      it { should have_title(new_last_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Logout', href: logout_path) }
      specify { user.reload.last_name.should  == new_last_name }
      specify { user.reload.email.should == new_email }
      specify { user.reload.task_area.should == new_task_area }
      specify { user.reload.introduction.should == new_introduction }
    end
  end
end