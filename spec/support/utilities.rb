# Coding: UTF-8

include ApplicationHelper
include UsersHelper
include PostsHelper

def log_in(user)
  visit login_path
  fill_in "E-Mail-Adresse",    with: user.email
  fill_in "Passwort", with: user.password
  click_button "Login"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

def fill_in_valid_signup_data
  fill_in "Vorname",                      with: "Hans"
  fill_in "Nachname",                     with: "Wurst"
  fill_in "E-Mail-Adresse",               with: "hw@example.com"
  fill_in "Aufgabenbereich",              with: "Unfug"
  fill_in "Vorstellungstext (optional)",  with: "Ein weiterer generischer Mitarbeiter."
  fill_in "Passwort",                     with: "foobar"
  fill_in "Passwort bestätigen",          with: "foobar"
end

def fill_in_valid_post_data
  fill_in "Titel",        with: "Ein Titel"
  fill_in "Text",         with: "Lorem ipsum"
  fill_in "Teaser-Text",  with: "Lorem"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_welcome_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-success', text: message)
  end
end

RSpec::Matchers.define :have_title do |title|
  match do |page|
    page.should have_selector('title', text: title)
  end
end

RSpec::Matchers.define :have_h1 do |h1|
  match do |page|
    page.should have_selector('h1', text: h1)
  end
end