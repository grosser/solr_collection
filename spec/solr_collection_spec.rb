require 'spec/spec_helper'

describe SolrCollection do
  it "behaves like an array when built from solr result" do
    a = []
    def a.results; [1, 2, 3];end
    SolrCollection.new(a)[2].should == 3
  end

  it "behaves like an array when built from array" do
    a = [1, 2, 3]
    SolrCollection.new(a)[2].should == 3
  end

  it "behaves like a will_paginate collection" do
    s = SolrCollection.new([1,2,3], :page=>1, :per_page=>2, :total_entries=>20)
    s.total_pages.should == 10
  end
  
  it "does not modify options" do
    a = {:per_page=>2, :offset=>2}
    SolrCollection.new([1], a).current_page.should == 2
    a.should == {:per_page=>2, :offset=>2}
  end

  describe "pages" do
    it "does not know non-will-paginate methods" do
      lambda{ SolrCollection.new([1,2,3], :page => 3).page }.should raise_error
    end

    it "can set page" do
      SolrCollection.new([1,2,3], :page=>3).current_page.should == 3
    end

    it "knows current_page" do
      SolrCollection.new([1,2,3]).current_page.should == 1
    end

    it "knows default per_page" do
      SolrCollection.new([1,2,3]).per_page.should == 10
    end

    it "can set per_page" do
      SolrCollection.new([1,2,3], :per_page=>3).per_page.should == 3
    end
  end

  describe "limit and offset" do
    it "uses per_page when per_page and limit are given" do
      SolrCollection.new([1], :per_page=>2, :limit=>20, :offset=>10).current_page.should == 6
    end

    it "understands limit/offset" do
      SolrCollection.new([1], :limit=>2, :offset=>10).current_page.should == 6
    end

    it "understands per_page/offset" do
      SolrCollection.new([1], :per_page=>2, :offset=>2).current_page.should == 2
    end
  end

  describe "facets" do
    it "knows factes" do
      SolrCollection.new([]).facets.should == nil
    end

    it "can set facets via options" do
      SolrCollection.new([], :facets => [1]).facets.should == [1]
    end

    it "can set facets via collection" do
      a = []
      def a.facets; [1]; end
      SolrCollection.new(a).facets.should == [1]
    end

    it "prefers facets from options" do
      a = []
      def a.facets; [1]; end
      SolrCollection.new([], :facets => [2]).facets.should == [2]
    end
  end

  it "knows spellcheck" do
    SolrCollection.new([]).spellcheck.should == nil
  end

  it "does not know non-solr-method" do
    lambda{ SolrCollection.new([]).fooo }.should raise_error
  end

  describe "total_entries" do
    it "can get total_entries from a solr result" do
      a = []
      def a.total; 22;end
      SolrCollection.new(a).total_entries.should == 22
    end

    it "can get total_entries from array" do
      a = [1,2,3]
      SolrCollection.new(a).total_entries.should == 3
    end

    it "can get total_entries from self" do
      a = SolrCollection.new([1,2,3])
      SolrCollection.new(a).total_entries.should == 3
    end

    it "prefers total_entries from options" do
      a = []
      def a.total; 22;end
      SolrCollection.new(a, :total_entries=>33).total_entries.should == 33
    end
  end

  describe :has_facet_fields do
    it "is false when facets are nil" do
      SolrCollection.new([]).has_facet_fields?.should == false
    end

    it "is false when facet_fieldss are an empty array" do
      a = []
      def a.facets; {'facet_fields'=>[]}; end
      SolrCollection.new(a).has_facet_fields?.should == false
    end

    it "is true when it is a filled hash" do
      a = []
      def a.facets; {'facet_fields'=>{'x'=>'y'}}; end
      SolrCollection.new(a).has_facet_fields?.should == true
    end
  end

  describe :facet_field do
    it "gets info from facet_fields" do
      SolrCollection.new([], :facets => {'facet_fields' => {'x' => {'xx' => 1}}}).facet_field('x').should == {'xx' => 1}
    end

    it "returns nil when field is empty" do
      SolrCollection.new([], :facets => {'facet_fields' => {'x' => []}}).facet_field('x').should == nil
    end

    it "returns nil when field is not found" do
      SolrCollection.new([], :facets => {'facet_fields' => []}).facet_field('x').should == nil
    end

    it "returns nil when facets are empty" do
      SolrCollection.new([]).facet_field('x').should == nil
    end
  end
end