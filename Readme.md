 - Wrap acts_as_solr results to behave like WillPaginate (use same helpers!)  
 - Make arrays behave like solr results (e.g. mock an empty result when solr is down or throws errors)

Usage
=====
 - As Rails plugin  `  rails plugin install git://github.com/grosser/solr_collection.git  `
 - As gem `  sudo gem install solr_collection  `

Example:
    options = {:limit=>10, :offset=>100, :facets=>{....}, .... }
    results = MyModel.find_by_solr("abc", options) rescue []
    results = SolrCollection.new(results, options.slice(:limit, :offset))

    do_something if results.facets
    do_something if results.total_entries > results.size # more pages ?
    will_paginate(results)

Other features:
    #facet fields can be nil or [] or {} -> use has_facet_fields? to check
    puts results.facets['facet_fields']['category_id_facet'] if results.has_facet_fields?
    puts results.facet_field('category_id_facet')

Author
======
[Michael Grosser](http://grosser.it)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...