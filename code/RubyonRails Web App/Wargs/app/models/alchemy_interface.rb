class AlchemyInterface 
	 include HTTParty
  base_uri 'http://access.alchemyapi.com'

        #870deb56ae88fd857a17c320cd1ebe80ff9e550f
        #325ab01c033f5b7f587f3636f7eea31fc0f6dd45 - mine 
 def query(options = {} , content)
    self.class.post("http://access.alchemyapi.com/calls/text/TextGetRankedKeywords" , 
    		:headers => { 'Content-Type' => 'application/x-www-form-urlencoded' },
    		:body => { :apikey => '325ab01c033f5b7f587f3636f7eea31fc0f6dd45' , 
    					:outputMode => 'json',
    					:keywordExtractMode => 'strict',
              :maxRetrieve => '5',
    					:text =>  content

 } 
    	)
  end
#debug_output
end


      