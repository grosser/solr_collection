require 'will_paginate/collection'

class SolrCollection
  def initialize(subject, options={})
    @data = {:facets=>nil, :spellcheck=>nil}.merge(options)
    @subject = WillPaginate::Collection.new(
      options.delete(:page) || 1,
      options.delete(:per_page) || 24,
      options.delete(:total_entries) || subject.size
    )
    @subject.replace(subject)
  end

  private
  
  def method_missing(method, *args, &block)
    method = method.to_sym
    if @data.key? method
      @data[method]
    else
      @subject.send(method, *args, &block)
    end
  end
end