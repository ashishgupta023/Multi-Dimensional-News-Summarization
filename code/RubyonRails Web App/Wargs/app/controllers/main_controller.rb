require 'active_support/all'

class MainController < ApplicationController
  def index

    #Sample query on solr web index
    solr = SolrInterface.new
    options = { "q" => "ebola", "wt" => "json", "indent" => "true" }
    result  = solr.query(options,"collection1")
    @queryResult = JSON.parse(result)

    #To get the pages from the seed corpus
    solrSeed = SolrInterface.new
    options = { "q" => "-section_cat:\"paid death\"", "wt" => "json", "indent" => "true" , "rows" => 10}
    solrSeedresult  = solrSeed.query(options,"seed")
    @solrSeedResult = JSON.parse(solrSeedresult)


    solrSeedResultSize = @solrSeedResult['response']['docs'].size
    j = 0 
    #while j < solrSeedResultSize do
      #Call alchemy to get keywords
      begin 
        content = @solrSeedResult['response']['docs'][j]['full_text']
      	alchemy = AlchemyInterface.new
      	@aResult = alchemy.query(content)

        #Concatenate keywords to generate or query
        i = 0
        guardianQuery = ""
        size = @aResult['keywords'].size 
        while i < 3 do
          guardianQuery = guardianQuery + " " +@aResult['keywords'][i]['text']
          i = i +1
        end

        #Call guardian to get seed URL's to crawl

      	guardian = GuardianInterface.new
      	guardianOptions = { "q" => guardianQuery , "order-by" => "relevance", "api-key" => "kqmru9b9dba3qb4w6bhe3fnd" , "from-date" => "2006-09-01" , "to-date" => "2007-03-30"  } 
      	@gResult = guardian.query(guardianOptions)


        #Write Seed URL's to Nutch Seed file
        begin
          file = File.open("C:\\apache-nutch-1.9\\dmoz\\urls", "a")
          file.write(@gResult['response']['results'][0]['webUrl']+ "\n") 
          rescue IOError => e
            print "file write failed"
            #some error occur, dir not writable etc.
          ensure
          file.close unless file == nil
        end
      rescue
        print "skipping"
      end
      j = j + 1
    #end
  end

  def endMemo 

    solr = SolrInterface.new
    options = { "q" => "endmemo 2012", "wt" => "json", "indent" => "true" , "rows" => 1 }
    result  = solr.query(options,"collection1")
    @queryResult = JSON.parse(result)
    keywords =  @queryResult['response']['docs'][0]['content'].gsub("-","").gsub(/[:()0-9]/ , "").gsub("\'s" , "").gsub("endmemo.com" , "").gsub("Terms of Use" , "").gsub("","")
    @keyword_array = keywords.split(",");

    k = 1

    while k <   @keyword_array.size - 1 do
      guardian = GuardianInterface.new
      guardianOptions = { "q" => @keyword_array[k] , "order-by" => "relevance", "api-key" => "kqmru9b9dba3qb4w6bhe3fnd" , "from-date" => "2012-01-01"   } 
      @gResult = guardian.query(guardianOptions)
      if  !@gResult.nil?
      begin
            file = File.open("C:\\apache-nutch-1.9\\dmoz\\urls", "a")
            if @gResult['response']['results'].size > 0
              file.write(@gResult['response']['results'][0]['webUrl']+ "\n") 
            end
            rescue IOError => e
              print "file write failed"
              #some error occur, dir not writable etc.
            ensure
            file.close unless file == nil
      end
    end
      k = k + 1
    end

  end

  def wargs
     #Sample query on solr web index
    solr = SolrInterface.new
    if params[:searchItem].nil? 
      @queryResult = nil
    else
      options = { "q" =>  params[:searchItem], "wt" => "json", "indent" => "true" ,"hl" => "true" , "hl.fragsize" => "500"  }
      if params[:searchItem].split(" ").length > 1
        defType="edismax"
        qf="title^2 content^1"
        options = { "q" =>  params[:searchItem],:defType => defType, :qf => qf ,"wt" => "json", "indent" => "true" ,"hl" => "true" , "hl.fragsize" => "500"  }
      end
      result  = solr.query(options,"collection1")
      @queryResult = JSON.parse(result)
        j =0 
        @bestSpell = nil
        while j < @queryResult['spellcheck']['suggestions'].size do 
          if  @queryResult['spellcheck']['suggestions'][j] == "collation"
              @bestSpell = @queryResult['spellcheck']['suggestions'][j+1][1]
              break
          end
          j = j + 1
        end
        begin
          if !@bestSpell.nil?
            @spellCorrected = {"status" => true , "previousQuery" => params[:searchItem] }
            options = { "q" =>  @bestSpell, "wt" => "json", "indent" => "true" ,"hl" => "true" , "hl.fragsize" => "500"  }
            if @bestSpell.split(" ").length > 1
              defType="edismax"
              qf="title^2 content^1"
              options = { "q" =>  @bestSpell,:defType => defType, :qf => qf ,"wt" => "json", "indent" => "true" ,"hl" => "true" , "hl.fragsize" => "500"  }
            end
            result  = solr.query(options,"collection1")
            @queryResult = JSON.parse(result)
          end
        rescue 
        end
      



    end
  end


  def search
    solr = SolrInterface.new
    if params[:searchItem].nil? 
      @queryResult = nil
    else
      options = { "q" =>  params[:searchItem], "wt" => "json", "indent" => "true" ,"hl" => "true" , "hl.fragsize" => "500"  }
      if params[:searchItem].split(" ").length > 1
        defType="edismax"
        qf="title^2 content^1"
        options = { "q" =>  params[:searchItem],:defType => defType, :qf => qf ,"wt" => "json", "indent" => "true" ,"hl" => "true" , "hl.fragsize" => "500"  }
      end
      result  = solr.query(options,"collection1")
      @queryResult = JSON.parse(result)
      j =0 
      @bestSpell = nil
      while j < @queryResult['spellcheck']['suggestions'].size do 
        if  @queryResult['spellcheck']['suggestions'][j] == "collation"
            @bestSpell = @queryResult['spellcheck']['suggestions'][j+1][1]
            break
        end
        j = j + 1
      end
      begin
        if !@bestSpell.nil?
          @spellCorrected = {"status" => true , "previousQuery" => params[:searchItem] }
          options = { "q" =>  @bestSpell, "wt" => "json", "indent" => "true" ,"hl" => "true" , "hl.fragsize" => "500"  }
            if @bestSpell.split(" ").length > 1
              defType="edismax"
              qf="title^2 content^1"
              options = { "q" =>  @bestSpell,:defType => defType, :qf => qf ,"wt" => "json", "indent" => "true" ,"hl" => "true" , "hl.fragsize" => "500"  }
            end          
            result  = solr.query(options,"collection1")
            @queryResult = JSON.parse(result)
        end
      rescue 
      end
      if params[:insight] == "events"
        @moreLikeThisRes = Hash.new
        k = 0
        while k < @queryResult['response']['docs'].size do
          id_now=@queryResult['response']['docs'][k]['id']
          #"mlt.mindf"=>"10","mlt.mintf"=>"5",
          mltQuery_options = { "q" =>  "\{!term f=id\}"+id_now, "wt" => "json" ,"mlt.match.offset" => 11,"mlt"=>"true","mlt.fl"=>"content","fl"=>"id,score,title", "mlt.interestingTerms" => "detail"}
          mlt_result  = solr.query(mltQuery_options,"collection1")
          mlt_result = JSON.parse(mlt_result)

          @moreLikeThisRes[id_now] =  mlt_result['moreLikeThis'][id_now]['docs']

          k = k + 1
        end
      end
      
      

      @insight=params[:insight]
      docs_event = @queryResult['response']['docs']
      @docs_withDates = Array.new
      docs_event.each { |x| if x['updatedDate'].nil? then  else x['updatedDate']=Date.parse(x['updatedDate']);  @docs_withDates << x end }
      @docs_withDates = @docs_withDates.sort { |x,y| y['updatedDate'] <=> x['updatedDate'] }
      @docs_withDates.each { |x|
          date=x['updatedDate']
          today=DateTime.now.to_date
          x['months']= (today.year * 12 + today.month) - (date.year * 12 + date.month)
          x['toShow_FormatedDate']= date.strftime("%B %d, %Y")
          
          days_diff=today - date
          months_diff = (today.year * 12 + today.month) - (date.year * 12 + date.month)

         if(days_diff == 0) ## today
          then
            x['toShow_timeLapsed']="today"
          elsif(months_diff > 0 && months_diff < 12) ## month in this year
              x['toShow_timeLapsed']=months_diff.to_s + " month"
              if(months_diff) > 1
                x['toShow_timeLapsed']+="s"
              end
              x['toShow_timeLapsed']+=" ago"
          elsif(days_diff > 365) ## some prev year
              x['toShow_timeLapsed']=(today.year - date.year).to_s + " year"
              if(today.year - date.year) > 1 
                x['toShow_timeLapsed']+="s"
              end
              x['toShow_timeLapsed']+=" ago" 
          else ## this month
            x['toShow_timeLapsed']=(today.day - date.day).to_s + " day"
            if(today.day - date.day) > 1
              x['toShow_timeLapsed']+="s"
            end                          
            x['toShow_timeLapsed']+=" ago"        
          end
      }


    end


  end

end
