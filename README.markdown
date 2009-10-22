SolrCollection is a wrapper for acts_as_solr results sets that behaves/feels like will_paginate collection

 - no need to separate results from facets / spellcheck information
 - all pages can use the same pagination helpers
 - simple to mock an empty result when solr is down or throws errors

Usage
=====
 - As Rails plugin  `  script/plugin install git://github.com/grosser/solr_collection.git  `
 - As gem `  sudo gem install solr_collection  `

Example:
    options = {:limit=>10, :offset=>100, :facets=>{....}, .... }
    results = MyModel.find_by_solr("abc", options) rescue []
    results = SolrCollection.new(results, options)

    do_something if results.facets
    something_else if results.total_entries > results.size #more pages ?
    will_paginate(results)

Other features:
    #facet fields can be nil or [] or {} -> use has_facet_fields? to check
    puts results.facets['facet_fields']['categories'] if results.has_facet_fields?

Author
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...