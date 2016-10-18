require 'rails_helper'

feature "Home page", :type => :feature do
  background do
    visit root_path
  end

  scenario "show home page" do
    expect(page).to have_content 'is Dashboard'
  end

  # TODO: How to test yield field?
  scenario "ApplicationHelper#title" do
    # expect(page).to have_selector("title:contains(#{I18n.t('site.name')})")
  end
end