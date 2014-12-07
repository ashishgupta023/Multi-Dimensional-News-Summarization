class GuardianInterface 
	 include HTTParty
  base_uri 'http://content.guardianapis.com'


 def query(options = {})
    self.class.get("http://content.guardianapis.com/search" , :query => options)
  end
#debug_output
end
