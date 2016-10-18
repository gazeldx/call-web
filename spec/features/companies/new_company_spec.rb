require 'rails_helper'

describe "New Company", :type => :feature do
  def fill_in_and_passed
    fill_in 'company[name]', :with => 'ZTE Corp'
    fill_in 'company[license]', :with => 12
    click_button I18n.t('submit')

    expect(page).to have_content I18n.t('company.created')
    expect(page).to have_content 'ZTE Corp'
  end

  before do
    visit companies_path
    click_link I18n.t('company.new')
  end

  it "show new company page" do
    expect(page).to have_css(".breadcrumbs ul.breadcrumb li a[href='/companies']", text: I18n.t('company.management'))
    expect(page).to have_css(".breadcrumbs ul.breadcrumb li.active", text: I18n.t('company.new'))

    expect(page).to have_css(".form-group label", text: I18n.t('company.name'))
    expect(page).to have_css(".form-group label span.text-danger", text: '*')
    expect(page).to have_field('company[name]')

    expect(page).to have_css(".form-group label", text: I18n.t('company.license'))
    expect(page).to have_field 'company[license]'
    expect(page).to have_button I18n.t('submit')
  end

  it "create a company when submitted" do
    fill_in_and_passed
  end

  it "show error message when input invalid" do
    fill_in 'company[name]', :with => 'z'
    fill_in 'company[license]', :with => 'f'
    click_button I18n.t('submit')

    expect(page).to have_content I18n.t('errors.messages.too_short')[0..3]
    expect(page).to have_content I18n.t('errors.messages.not_a_number')[0..7]

    fill_in_and_passed
  end
end
