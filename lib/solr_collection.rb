require 'will_paginate/collection'

#Proxy that delegates all calls to contained subject
# except solr related methods in MAPPED_FIELDS
class SolrCollection
  MAPPED_FIELDS = [:facets, :spellcheck, {:total=>:total_entries}]

  def initialize(solr_result, options={})
    @data = options

    MAPPED_FIELDS.each do |fields|
      if fields.is_a? Hash
        solr_field = fields.keys.first
        collection_field = fields.values.first
      else
        solr_field = collection_field = fields
      end

      if not @data[collection_field]
        @data[collection_field] = if solr_result.respond_to?(solr_field)
          solr_result.send(solr_field)
        else
          nil
        end
      end
    end

    #solr result has results in an array called results
    results = if solr_result.respond_to?(:results)
      solr_result.results
    else
      solr_result
    end

    @subject = WillPaginate::Collection.new(
      options.delete(:page) || 1,
      options.delete(:per_page) || 24,
      options.delete(:total_entries) || results.size
    )
    @subject.replace(results)
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