require 'will_paginate/collection'

#Proxy that delegates all calls to contained subject
# except solr related methods in MAPPED_FIELDS
class SolrCollection
  SOLR_FIELDS = [:facets, :spellcheck]

  def initialize(collection, options={})
    options = options.dup

    # get fields from solr result-set or set them to nil
    @solr_data = {}
    SOLR_FIELDS.each do |field|
      @solr_data[field] = if options[field]
        options[field]
      elsif collection.respond_to?(field)
        collection.send(field)
      else
        nil
      end
    end

    # copy or generate pagination information
    options[:page] ||= (collection.respond_to?(:current_page) ? collection.current_page : nil)
    options[:per_page] ||= (collection.respond_to?(:per_page) ? collection.per_page : nil)
    options[:total_entries] ||= if collection.respond_to?(:total)
      collection.total
    elsif collection.respond_to?(:total_entries)
      collection.total_entries
    else
      collection.size
    end
    options = fill_page_and_per_page(options)

    # build paginate-able object
    @subject = WillPaginate::Collection.new(
      options[:page],
      options[:per_page],
      options[:total_entries]
    )

    # solr result-set has results in an array called results
    results = (collection.respond_to?(:results) ? collection.results : collection)
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
  
  def to_a
    @subject.to_a
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
      @solr_data[method] or (@subject.send(method, *args, &block) rescue nil)
    else
      @subject.send(method, *args, &block)
    end
  end
end