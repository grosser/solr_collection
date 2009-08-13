require 'spec/spec_helper'

describe SolrCollection do
  it "behaves like an array" do
    s = SolrCollection.new([1,2,3])
    s.size.should == 3
    s[1].should == 2
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
    it "does not know page" do
      lambda{ SolrCollection.new([1,2,3]).page }.should raise_error
    end

    it "knows current_page" do
      SolrCollection.new([1,2,3]).current_page.should == 1
    end

    it "knows per_page" do
      SolrCollection.new([1,2,3]).per_page.should == 10
    end

     it "can set page" do
      SolrCollection.new([1,2,3], :page=>3).current_page.should == 3
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

  describe "solr fields" do
    it "knows factes" do
      SolrCollection.new([]).facets.should == nil
    end

    it "knows spellcheck" do
      SolrCollection.new([]).spellcheck.should == nil
    end

    it "does not know non-solr-method" do
      lambda{ SolrCollection.new([]).fooo }.should raise_error
    end

    it "uses results as subject" do
      a = []
      def a.results; [1,2,3];end
      SolrCollection.new(a)[2].should == 3
    end

    it "knows total_entries" do
      SolrCollection.new([1,2,3]).total_entries.should == 3
    end

    it "can get total_entries from an array" do
      a = [1,2,3]
      SolrCollection.new(a, :per_page=>2).total_pages.should == 2
    end

    it "can get total_entries from a solr resultset" do
      a = []
      def a.total; 22;end
      SolrCollection.new(a).total_entries.should == 22
    end

    it "does not overwrite total from solr resultset with given total_entries" do
      a = []
      def a.total; 22;end
      SolrCollection.new(a, :total_entries=>33).total_entries.should == 22
    end
  end
end