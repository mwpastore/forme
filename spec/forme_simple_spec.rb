require File.join(File.dirname(File.expand_path(__FILE__)), 'spec_helper.rb')

describe "Forme plain forms" do
  before do
    @f = Forme::Form.new
  end

  specify "should create a simple input tags" do
    @f.input(:text).should == '<input type="text"/>'
    @f.input(:radio).should == '<input type="radio"/>'
  end

  specify "should create other tags" do
    @f.input(:textarea).should == '<textarea></textarea>'
    @f.input(:fieldset).should == '<fieldset></fieldset>'
  end

  specify "should use html attributes specified in options" do
    @f.input(:textarea, :value=>'foo', :name=>'bar').should == '<textarea name="bar">foo</textarea>'
    @f.input(:text, :value=>'foo', :name=>'bar').should == '<input name="bar" type="text" value="foo"/>'
  end

  specify "should automatically create a label if a :label option is used" do
    @f.input(:text, :label=>'Foo', :value=>'foo').should == '<label>Foo: <input type="text" value="foo"/></label>'
  end

  specify "#open should return an opening tag" do
    @f.open(:action=>'foo', :method=>'post').should == '<form action="foo" method="post">'
  end

  specify "#close should return a closing tag" do
    @f.close.should == '</form>'
  end
end

describe "Forme object forms" do

  specify "should handle a simple case" do
    obj = Class.new{def forme_input(f, field, opts) Forme::Input.new(f, :text, :name=>"obj[#{field}]", :id=>"obj_#{field}", :value=>"#{field}_foo") end}.new 
    Forme::Form.new(obj).input(:field).should ==  '<input id="obj_field" name="obj[field]" type="text" value="field_foo"/>'
  end

  specify "should handle more complex case with multiple different types and opts" do
    obj = Class.new do 
      def self.name() "Foo" end

      attr_reader :x, :y

      def initialize(x, y)
        @x, @y = x, y
      end
      def forme_input(form, field, opts={})
        t = opts[:type]
        t ||= (field == :x ? :textarea : :text)
        s = field.to_s
        Forme::Input.new(form, t, {:label=>s.upcase, :name=>"foo[#{s}]", :id=>"foo_#{s}", :value=>send(field)}.merge!(opts))
      end
    end.new('&foo', 3)
    f = Forme::Form.new(obj)
    f.input(:x).should == '<label>X: <textarea id="foo_x" name="foo[x]">&amp;foo</textarea></label>'
    f.input(:y, :brain=>'no').should == '<label>Y: <input brain="no" id="foo_y" name="foo[y]" type="text" value="3"/></label>'
  end
end