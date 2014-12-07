This provides a news search system that supports chronological and topical summarization views. 
Starting from a given seed news collection, the system intelligently crawls the web to expand extracted keywords/story. 
The expanded set is then indexed and served in a search system.  

code/Apache Solr/conf 
	Contains the SOLR configuration files used for indexing. Main files are solrconfig.xml, schema.xml and stopwords.txt

code/Apache Nutch/conf
	Contains the Nutch Configuration files used for crawling. Main files are regex-urlfilter.txt and schema-solr4.xml

code/RubyonRails Web App/Wargs
	Contains the code for the web app
