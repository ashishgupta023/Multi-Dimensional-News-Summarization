class SolrInterface 
	 include HTTParty
  base_uri 'http://localhost:8983'


 def query(options = {} , collection)
    self.class.get("http://localhost:8983/solr/"+collection+"/select" , :query => options)
  end


debug_output
end
