require 'will_paginate/collection'

#Proxy that delegates all calls to contained subject
# except solr related methods in MAPPED_FIELDS
class SolrCollection
  MAPPED_FIELDS = [:facets, :spellcheck, :total_entries]

  def initialize(solr_result, options={})
    options = options.dup

    #solr result has results in an array called results
    results = if solr_result.respond_to?(:results)
      solr_result.results
    else
      solr_result
    end

    #get fields from solr_result or set them to nil
    @solr_data = {}
    MAPPED_FIELDS.each do |field|
      @solr_data[field] = if options[field]
        options[field]
      elsif solr_result.respond_to?(field)
        solr_result.send(field)
      else
        nil
      end
    end

    # always set a total
    @solr_data[:total_entries] ||= (results.respond_to?(:total) ? results.total : results.size)

    #build will_paginate collection from given options
    options = fill_page_and_per_page(options)

    @subject = WillPaginate::Collection.new(
      options[:page],
      options[:per_page],
      @solr_data[:total_entries]
    )
    @subject.replace(results.to_ary)
  end

  def has_facet_fields?
    # can be a array, when empty reults where returned
    !!(facets and facets['facet_fields'] and not facets['facet_fields'].empty?)
  end

  def facet_field(field)
    if has_facet_fields? and value = facets['facet_fields'][field]
      value.empty? ? nil : value
    end
  end

  def respond_to?(method)
    @solr_data.key?(method) or @subject.respond_to?(method) or super
  end

  private

  def fill_page_and_per_page(options)
    options[:per_page] ||= options[:limit] || 10
    if options[:page].to_s.empty?
      options[:page] = if options[:offset]
        (options[:offset] / options[:per_page]) + 1
      else
        1
      end
    end
    options
  end
  
  def method_missing(method, *args, &block)
    method = method.to_sym
    if @solr_data.key? method
      @solr_data[method]
    else
      @subject.send(method, *args, &block)
    end
  end
end