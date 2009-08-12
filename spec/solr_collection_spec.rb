require 'spec/spec_helper'

describe SolrCollection do
  it "behaves like an array" do
    s = SolrCollection.new([1,2,3])
    s.size.should == 3
    s[1].should == 2
  end

  it "stores additional params as methods" do
    s = SolrCollection.new([1,2,3], :facets=>1)
    s.facets.should == 1
  end

  it "behaves like a will_paginate collection" do
    s = SolrCollection.new([1,2,3], :page=>1, :per_page=>2, :total_entries=>20)
    s.total_pages.should == 10
  end

  it "knows page" do
    SolrCollection.new([1,2,3]).current_page.should == 1
  end

  it "knows per_page" do
    SolrCollection.new([1,2,3]).per_page.should == 24
  end

  it "knows total_entries" do
    SolrCollection.new([1,2,3]).total_entries.should == 3
  end

  it "can overwrite page" do
    SolrCollection.new([1,2,3], :page=>3).current_page.should == 3
  end

  it "can overwrite per_page" do
    SolrCollection.new([1,2,3], :per_page=>3).per_page.should == 3
  end

  it "can overwrite total_entries" do
    SolrCollection.new([1,2,3], :total_entries=>33).total_entries.should == 33
  end

  it "knows factes" do
    SolrCollection.new([]).facets.should == nil
  end

  it "knows spellcheck" do
    SolrCollection.new([]).spellcheck.should == nil
  end

  it "does not know non-solr-method" do
    lambda{ SolrCollection.new([]).fooo }.should raise_error
  end
end