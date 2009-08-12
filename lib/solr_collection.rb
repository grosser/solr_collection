require 'will_paginate/collection'

class SolrCollection
  def initialize(subject, options={})
    @data = options

    [:facets, :spellcheck, {:total=>:total_entries}].each do |fields|
      if fields.is_a? Hash
        solr_field = fields.keys.first
        collection_field = fields.values.first
      else
        solr_field = collection_field = fields
      end

      if not @data[collection_field]
        @data[collection_field] = if subject.respond_to?(solr_field)
          subject.send(solr_field)
        else
          nil
        end
      end
    end

    subject = subject.results if subject.respond_to?(:results) #solr collection have results in an array called results

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