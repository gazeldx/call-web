require 'rails_helper'

RSpec.describe ApplicationHelper, :type => :helper do

  describe "#translate_text" do
    it "return i18n translated text if parameter exists in zh.yml" do
      expect(helper.translate_text("company.new")).to eq("新建企业")
    end

    it "return original text if parameter not exists in zh.yml" do
      expect(helper.translate_text("company.what")).to eq("company.what")
    end
  end

  # TODO: content_for need be covered in feature.
  describe "#titled" do
    it "return proper i18n text if action name is 'index'" do
      controller.stubs(:action_name).returns('index')
      controller.stubs(:controller_path).returns('companies')
      # puts controller_path.inspect
      # puts action_name.inspect
      # http://stackoverflow.com/questions/8014038/rails-3-rspec-2-testing-content-for
      # rendered.should contain('foo')
      # expect(view.content_for(:title)).to eq("企业管理")
    end
  end

  # TODO: This should be covered in feature
  describe "#notice_or_error" do
    # it "return notice info if flash[:notice] exists" do
    #   controller.stubs(:flash[:notice]).returns('hello')
    #   puts flash[:notice]
    #   # expect(helper.translate_text("company.new")).to eq("新建企业")
    # end
  end

  describe "#edit?" do
    it "return true if action name is 'edit'" do
      controller.stubs(:action_name).returns('edit')
      expect(helper.edit?).to be true
    end

    it "return true if action name is 'edit'" do
      controller.stubs(:action_name).returns('new')
      expect(helper.edit?).to be false
    end
  end

  describe "#input_text" do
    before do
      controller.stubs(:action_name).returns('edit')
      controller.stubs(:controller_path).returns('companies')
    end

    describe "for input" do
      it "return input type='text'" do
        expect(helper.input_text(:license)).to match /input.*type="text"/
      end

      it "have default value if action name is 'edit'" do
        @company = Company.make!(:license => 15)
        expect(helper.input_text(:license)).to match /input.*type="text".* value="15"/
      end
    end

    it "has i18n text in label under div" do
      expect(helper.input_text(:license)).to match /<div class="form-group"><label class="col-sm-3 control-label no-padding-right" for="company.license">.*座席数.*<\/label>/
    end

    describe "for required option" do
      it "contain a red * before label text if required option exists" do
        ['', true].each do |value|
          expect(helper.input_text(:license, required: value)).to match /<span class="text-danger">\*<\/span>座席数<\/label>/
          expect(helper.input_text(:foo, required: true)).to match /title="必填项"/
        end
      end

      it "not contain a red * before label text if required option not (exists or true or blank string)" do
        expect(helper.input_text(:license)).not_to match /\*/
        expect(helper.input_text(:bar)).not_to match /title="必填项"/
        [false, 'true', nil].each do |value|
          expect(helper.input_text(:license, required: value)).not_to match /\*/
          expect(helper.input_text(:license, required: value)).not_to match /title="必填项"/
        end
      end

      it "not show default title if title option exist" do
        expect(helper.input_text(:license, required: '', title: 'foo')).not_to match /title="必填项"/
        expect(helper.input_text(:license, required: '', 'data-original-title' => 'foo')).not_to match /title="必填项"/
      end
    end

    describe "for digital option" do
      it "show tooltip if digital option exists" do
        ['', true, 'foo'].each do |value|
          expect(helper.input_text(:foo, digits: value)).to match /<input .* data-original-title="请输入数字" data-rel="tooltip".*\/>/
          expect(helper.input_text(:bar, digits: value)).not_to match /digits/
        end
      end

      it "not show tooltip if digital option not exist" do
        expect(helper.input_text(:license)).not_to match /data-rel/
      end
    end

    describe "for class option" do
      it "have default class if class option not exist" do
        expect(helper.input_text(:foo)).to match /<div.* class="col-sm-5".*<\/div>/
      end

      it "use customized class option" do
        expect(helper.input_text(:bar, class: 'hello-class class2')).to match /<div.* class="hello-class class2".*<\/div>/
      end
    end
  end

  describe "#submit_form" do
    it "show a submit button and reset button" do
      expect(helper.submit_form).to match(/<div class="clearfix form-actions"><div class="col-md-offset-3 col-md-9"><button class="btn btn-info" type="submit"><i class="icon-ok bigger-110"><\/i> 提 交<\/button>&nbsp; &nbsp; &nbsp; &nbsp;<button class="btn" type="reset"><i class="icon-undo bigger-110"><\/i> 重 置<\/button><\/div><\/div>/)
    end
  end

  describe "#labeled" do
    before do
      controller.stubs(:action_name).returns('edit')
      controller.stubs(:controller_path).returns('companies')
    end

    it "auto generate a label for column" do
      expect(helper.labeled(:active)).to match(/<label class="col-sm-3 control-label no-padding-right" for="company_active">状态<\/label>/)
    end
  end

  describe "#odd_even" do
    it "return 'odd' if number is odd" do
      expect(helper.odd_even(1)).to eq('odd')
      expect(helper.odd_even(129)).to eq('odd')
      expect(helper.odd_even(84)).not_to eq('odd')
    end

    it "return 'even' if number is even" do
      expect(helper.odd_even(2)).to eq('even')
      expect(helper.odd_even(74)).to eq('even')
      expect(helper.odd_even(25)).not_to eq('even')
    end
  end

  describe "private#controller_action_i18_text" do
    before do
      controller.stubs(:controller_path).returns('companies')
    end

    it "return singularized controller_path with original action" do
      controller.stubs(:action_name).returns('edit')
      expect(helper.send(:controller_action_i18_text)).to eq('company.edit')

      controller.stubs(:action_name).returns('new')
      expect(helper.send(:controller_action_i18_text)).to eq('company.new')

      controller.stubs(:action_name).returns('foo')
      expect(helper.send(:controller_action_i18_text)).to eq('company.foo')

      controller.stubs(:action_name).returns('update')
      expect(helper.send(:controller_action_i18_text)).not_to eq('company.update')
    end

    it "return singularized controller_path with 'new' if action name is create" do
      controller.stubs(:action_name).returns('create')
      expect(helper.send(:controller_action_i18_text)).to eq('company.new')
    end

    it "return singularized controller_path with 'edit' if action name is update" do
      controller.stubs(:action_name).returns('update')
      expect(helper.send(:controller_action_i18_text)).to eq('company.edit')
    end
  end

  describe "private#index_i18_text" do
    before do
      controller.stubs(:controller_path).returns('companies')
      controller.stubs(:action_name).returns('index')
    end

    it "return singularized controller_path with .management" do
      expect(helper.send(:index_i18_text)).to eq('company.management')
    end
  end


end