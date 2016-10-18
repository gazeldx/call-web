require 'rails_helper'

describe "Companies", :type => :feature do
  def should_show_widgets
    expect(page).to have_css('.main-content .page-content .page-header h1', text: I18n.t('company.management'))
    expect(page).to have_css('a.btn.btn-sm.btn-success.pull-right', text: I18n.t('company.new'))
    expect(page).to have_css('table.table.table-striped.table-bordered.table-hover thead tr th', text: I18n.t('company.name'))
    expect(page).to have_content(I18n.t('company.license'))
  end

  before do
    visit '/'
  end

  describe "no company" do
    before do
      Company.delete_all

      click_link I18n.t('company.management')
    end

    it "list none company if no company" do
      should_show_widgets

      expect(page).to have_css('.col-sm-6 .dataTables_info', :text => I18n.t('will_paginate.page_entries_info.single_page_html.zero'))
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap")
    end
  end

  describe "many companies" do
    before do
      Company.make!(33)
      Company.make!(name: 'Apple Corp')
      click_link I18n.t('company.management')
    end

    it "list companies" do
      should_show_widgets

      expect(page).to have_css('table.table.table-striped.table-bordered.table-hover tbody tr td', :text => "Apple Corp")
    end

    it "pagination works on first page" do
      expect(page).to have_css('.row .col-sm-6 .dataTables_info', :text => "1 - #{WillPaginate.per_page}，共34")
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap ul.pagination li.active a[@href='#']", :text => "1")
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap ul.pagination li a", :text => "#{((34 - 1)/WillPaginate.per_page) + 1}")
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap ul.pagination li.prev.disabled a[@href='#']")
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap ul.pagination li.next a[@href='/companies?page=2']")
    end

    it "pagination works on second page" do
      #Question: How to stub a var like WillPaginate.per_page?
      click_link 2
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap ul.pagination li a", :text => "1")
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap ul.pagination li.active a[@href='#']", :text => "2")
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap ul.pagination li.prev a[@href='/companies?page=1']")
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap ul.pagination li.next")
    end

    it "pagination works on last page" do
      click_link ((34 - 1)/WillPaginate.per_page) + 1
      expect(page).to have_css(".row .col-sm-6 .dataTables_paginate.paging_bootstrap ul.pagination li.next.disabled a[@href='#']")
    end
  end
end
