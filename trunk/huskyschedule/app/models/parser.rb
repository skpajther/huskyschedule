class Parser < ActiveRecord::Base
  
  def self.get_html_array(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    return response.body.split("\n")
  end
  
  #remove &nbps; and &amp;
  def self.clean_text(text)
    split = text.split("&nbsp;")
    result = ""
    for s in split
      result += " " + s
    end
    split = result.split("&amp;")
    if(!split.nil?)
      result = split[0]
      1.upto(split.length-1) { |i| result += "&" + split[i] }
    end
    return result.strip
  end
    
#################################################################################################
#parser for list of categories
#################################################################################################
  def self.time_schedule_parser(url)
    contents = get_html_array(url)
    quarter = -1
    year = -1
    
    #get quarter, year
    i=0
    while(i < contents.length)
      matches = contents[i].match(/^<H1>University of Washington Time Schedule<BR>([^\s]+)\s+Quarter\s+([0-9]+)<\/H1>$/i)
      if(!matches.nil?)
        quarter = Quarter.quarter_constant(matches[1])
        year = matches[2].to_i
        break
      else
        i+=1
      end
    end
    
    sql = ActiveRecord::Base.connection();
    
    #clear entire db
#    sql.execute("DELETE FROM courses")
#    sql.execute("DELETE FROM labs")
#    sql.execute("DELETE FROM quiz_sections")
#    sql.execute("DELETE FROM categories")
#    sql.execute("DELETE FROM teachers")
    
    courses = Category.find_by_sql("SELECT * FROM courses WHERE quarter_id = #{quarter} AND year = #{year}")
    #Clear out all the data for the current schedule
    for c in courses
      sql.execute("DELETE FROM labs WHERE parent_id = #{c.id}")
      sql.execute("DELETE FROM quiz_sections WHERE parent_id = #{c.id}")
      sql.execute("DELETE FROM courses WHERE id = #{c.id}")
    end
    
  
#    #Undergraduate Interdisciplinary Programs
#    college = Category.create(:name=>"Undergraduate Interdisciplinary Programs")
#    category = Category.create(:name=>"University Academy", :abbrev=>"ACADEM", :parent_id=>college.id, :url=>"academ.html")
#    category = Category.create(:name=>"Program on the Environment", :abbrev=>"ENVIR", :parent_id=>college.id, :url=>"envst.html")
#    category = Category.create(:name=>"Quantitative Science (Fisheries and Forest Resources)", :abbrev=>"Q SCI", :parent_id=>college.id, :url=>"quantsci.html")
#    
#    #Arts & Sciences
#    college = Category.create(:name=>"College of Arts and Science")
#    top_category = Category.create(:name=>"American Ethnic Studies", :parent_id=>college.id)
#    Category.create(:name=>"Afro-American Studies", :parent_id=>top_category.id, :abbrev=>"AFRAM", :url=>"afamst.html")
#    Category.create(:name=>"American Ethnic Studies", :parent_id=>top_category.id, :abbrev=>"AES", :url=>"aes.html")
#    Category.create(:name=>"Asian-American Studies", :parent_id=>top_category.id, :abbrev=>"AAS", :url=>"asamst.html")
#    Category.create(:name=>"Chicano Studies", :parent_id=>top_category.id, :abbrev=>"CHSTU", :url=>"chist.html")
#    Category.create(:name=>"American Indian Studies", :abbrev=>"AIS", :parent_id=>college.id, :url=>"ais.html")
#    top_category = Category.create(:name=>"Anthropology", :parent_id=>college.id)
#    Category.create(:name=>"Anthropology", :abbrev=>"ANTH", :parent_id=>top_category.id, :url=>"anthro.html")
#    Category.create(:name=>"Archaeology", :abbrev=>"ARCHY", :parent_id=>top_category.id, :url=>"archeo.html")
#    Category.create(:name=>"Biocultural Anthropology", :abbrev=>"BIO A", :parent_id=>top_category.id, :url=>"bioanth.html")
#    Category.create(:name=>"Applied Mathematics", :abbrev=>"AMATH", :parent_id=>college.id, :url=>"appmath.html")
#    Category.create(:name=>"Art", :abbrev=>"ART", :parent_id=>college.id, :url=>"art.html")
#    Category.create(:name=>"Art History", :abbrev=>"ART H", :parent_id=>college.id, :url=>"arthis.html")
#    top_category = Category.create(:name=>"Asian Languages and Literature", :parent_id=>college.id)
#    Category.create(:name=>"Altai", :parent_id=>top_category.id, :abbrev=>"ALTAI", :url=>"altai.html")
#    Category.create(:name=>"Asian Languages and Literature", :parent_id=>top_category.id, :abbrev=>"ASIAN", :url=>"asianll.html")
#    Category.create(:name=>"Bengali", :parent_id=>top_category.id, :abbrev=>"BENG", :url=>"beng.html")
#    Category.create(:name=>"Chinese", :parent_id=>top_category.id, :abbrev=>"CHIN", :url=>"chinese.html")
#    Category.create(:name=>"Hindi", :parent_id=>top_category.id, :abbrev=>"HINDI", :url=>"hindi.html")
#    Category.create(:name=>"Indian", :parent_id=>top_category.id, :abbrev=>"INDN", :url=>"indian.html")
#    Category.create(:name=>"Indonesian", :parent_id=>top_category.id, :abbrev=>"INDON", :url=>"indones.html")
#    Category.create(:name=>"Japanese", :parent_id=>top_category.id, :abbrev=>"JAPAN", :url=>"japanese.html")
#    Category.create(:name=>"Korean", :parent_id=>top_category.id, :abbrev=>"KOREAN", :url=>"korean.html")
#    Category.create(:name=>"Sanskrit", :parent_id=>top_category.id, :abbrev=>"SNKRT", :url=>"sanskrit.html")
#    Category.create(:name=>"Tagalog", :parent_id=>top_category.id, :abbrev=>"TAGLG", :url=>"asamst.html") #special
#    Category.create(:name=>"Tamil", :parent_id=>top_category.id, :abbrev=>"TAMIL", :url=>"tamil.html")
#    Category.create(:name=>"Thai", :parent_id=>top_category.id, :abbrev=>"THAI", :url=>"thai.html")
#    Category.create(:name=>"Tibetan", :parent_id=>top_category.id, :abbrev=>"TIB", :url=>"tibetan.html")
#    Category.create(:name=>"Urdu", :parent_id=>top_category.id, :abbrev=>"URDU", :url=>"urdu.html")
#    Category.create(:name=>"Vietnamese", :parent_id=>top_category.id, :abbrev=>"VIET", :url=>"viet.html")
#    Category.create(:name=>"Astronomy", :abbrev=>"ASTR", :url=>"astro.html", :parent_id=>college.id)
#    Category.create(:name=>"Astrobiology", :abbrev=>"ASTBIO", :url=>"astbio.html", :parent_id=>college.id)
#    Category.create(:name=>"Atmospheric Sciences", :abbrev=>"ATM S", :url=>"atmos.html", :parent_id=>college.id)
#    Category.create(:name=>"Biology", :abbrev=>"BIOL", :url=>"biology.html", :parent_id=>college.id)
#    Category.create(:name=>"Botany", :abbrev=>"BOT", :url=>"biology.html", :parent_id=>college.id) #special
#    Category.create(:name=>"Center for Statistics and Social Sciences", :abbrev=>"CS&SS", :url=>"cs&ss.html", :parent_id=>college.id)
#    Category.create(:name=>"Center for Studies in Demography and Ecology", :abbrev=>"CSDE", :url=>"csde.html", :parent_id=>college.id)
#    Category.create(:name=>"Center for the Humanities", :abbrev=>"HUM", :url=>"centhum.html", :parent_id=>college.id)
#    Category.create(:name=>"Chemistry", :abbrev=>"CHEM", :url=>"chem.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Classics", :parent_id=>college.id)
#    Category.create(:name=>"Classical Archaeology", :abbrev=>"CL AR", :url=>"clarch.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Classical Linguistics", :abbrev=>"CL LI", :url=>"cling.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Classics", :abbrev=>"CLAS", :url=>"clas.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Greek", :abbrev=>"GREEK", :url=>"greek.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Latin", :abbrev=>"LATIN", :url=>"latin.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Communication", :abbrev=>"COM", :url=>"com.html", :parent_id=>college.id)
#    Category.create(:name=>"Comparative History of Ideas", :abbrev=>"CHID", :url=>"chid.html", :parent_id=>college.id)
#    Category.create(:name=>"Comparative Literature", :abbrev=>"C LIT", :url=>"complit.html", :parent_id=>college.id)
#    Category.create(:name=>"Computer Science", :abbrev=>"CSE", :url=>"cse.html", :parent_id=>college.id) #special
#    Category.create(:name=>"Dance", :abbrev=>"DANCE", :url=>"dance.html", :parent_id=>college.id)
#    Category.create(:name=>"Digital Arts and Experimental Media", :abbrev=>"DXARTS", :url=>"dxarts.html", :parent_id=>college.id)
#    Category.create(:name=>"Drama", :abbrev=>"DRAMA", :url=>"drama.html", :parent_id=>college.id)
#    Category.create(:name=>"Earth and Space Sciences", :abbrev=>"ESS", :url=>"ess.html", :parent_id=>college.id)
#    Category.create(:name=>"Economics", :abbrev=>"ECON", :url=>"econ.html", :parent_id=>college.id)
#    Category.create(:name=>"Environmental Studies", :abbrev=>"ENVIR", :url=>"envst.html", :parent_id=>college.id) #special
#    Category.create(:name=>"General Interdisciplinary Studies", :abbrev=>"GIS", :url=>"gis.html", :parent_id=>college.id)
#    Category.create(:name=>"General Studies", :abbrev=>"GEN ST", :url=>"genst.html", :parent_id=>college.id)
#    Category.create(:name=>"Genetics", :abbrev=>"GENOME", :url=>"genome.html", :parent_id=>college.id) #special
#    Category.create(:name=>"Geography", :abbrev=>"GEOG", :url=>"geog.html", :parent_id=>college.id)
#    Category.create(:name=>"Geological Sciences", :abbrev=>"ESS", :url=>"ess.html", :parent_id=>college.id)
#    Category.create(:name=>"Geophysics", :abbrev=>"ESS", :url=>"ess.html", :parent_id=>college.id)
#    Category.create(:name=>"Germanics", :abbrev=>"GERMAN", :url=>"germ.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"History", :parent_id=>college.id)
#    Category.create(:name=>"Ancient and Medieval History", :abbrev=>"HSTAM", :url=>"ancmedh.html", :parent_id=>top_category.id)
#    Category.create(:name=>"History", :abbrev=>"HIST", :url=>"hist.html", :parent_id=>top_category.id)
#    Category.create(:name=>"History of Asia", :abbrev=>"HSTAS", :url=>"histasia.html", :parent_id=>top_category.id)
#    Category.create(:name=>"History of the Americas", :abbrev=>"HSTAA", :url=>"histam.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Modern European History", :abbrev=>"HSTEU", :url=>"modeuro.html", :parent_id=>top_category.id)
#    Category.create(:name=>"History and Philosophy of Science", :abbrev=>"HPS", :url=>"hps.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Honors", :abbrev=>"H A&S", :url=>"honors.html", :parent_id=>college.id)
#    Category.create(:name=>"Humanities -- Center for the Humanities", :abbrev=>"HUM", :url=>"centhum.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Jackson School of International Studies", :parent_id=>college.id)
#    Category.create(:name=>"European Studies", :abbrev=>"EURO", :url=>"euro.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies", :abbrev=>"SIS", :url=>"intl.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (African Studies)", :abbrev=>"SISAF", :url=>"intlafr.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (Asian Studies)", :abbrev=>"SISA", :url=>"intlasian.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (Canadian Studies)", :abbrev=>"SISCA", :url=>"intlcan.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (Comparative Religion)", :abbrev=>"RELIG", :url=>"religion.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (East Asian Studies)", :abbrev=>"SISEA", :url=>"intleas.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (Jewish Studies)", :abbrev=>"SISJE", :url=>"intljewish.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (Latin American Studies)", :abbrev=>"SISLA", :url=>"intllatam.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (Middle Eastern Studies)", :abbrev=>"SISME", :url=>"intlmide.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (Russian, East European, and Central Asian Studies)", :abbrev=>"SISRE", :url=>"russeeuca.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (South Asian Studies)", :abbrev=>"SISSA", :url=>"intlsoa.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Studies (Southeast Asian Studies)", :abbrev=>"SISSE", :url=>"intlsea.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Law, Societies, and Justice", :abbrev=>"LSJ", :url=>"lsj.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Linguistics", :parent_id=>college.id)
#    Category.create(:name=>"American Sign Language", :abbrev=>"ASL", :url=>"asl.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Frensh Linguistics", :abbrev=>"FRLING", :url=>"frling.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Linguistics", :abbrev=>"LING", :url=>"ling.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Romance Linguistics", :abbrev=>"ROLING", :url=>"romling.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Spanish Linguistics", :abbrev=>"SPLING", :url=>"spanlin.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Mathematics", :abbrev=>"MATH", :url=>"math.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Music", :parent_id=>college.id)
#    Category.create(:name=>"Music", :abbrev=>"MUSIC", :url=>"music.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Music - Applied", :abbrev=>"MUSAP", :url=>"appmus.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Music Education", :abbrev=>"MUSED", :url=>"mused.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Music Ensemble", :abbrev=>"MUSEN", :url=>"musensem.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Music History", :abbrev=>"MUHST", :url=>"mushist.html", :parent_id=>top_category.id)
#    top_category = Category.create(:name=>"Near Eastern Languages and Civilization", :parent_id=>college.id)
#    Category.create(:name=>"Akkadian", :abbrev=>"AKKAD", :url=>"akkad.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Arabic", :abbrev=>"ARAB", :url=>"arabic.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Aramaic", :abbrev=>"ARAMIC", :url=>"aramic.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Egyptian", :abbrev=>"EGYPT", :url=>"egypt.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Hebrew", :abbrev=>"HEBR", :url=>"hebrew.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Near Eastern Languages and Civilization", :abbrev=>"NEAR E", :url=>"neareast.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Persian", :abbrev=>"PRSAN", :url=>"persian.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Turkic", :abbrev=>"TKIC", :url=>"turkic.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Turkish", :abbrev=>"TKISH", :url=>"turkish.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Ugaritic", :abbrev=>"UGARIT", :url=>"ugarit.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Neurobiology", :abbrev=>"NBIO", :url=>"nbio.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Philosophy", :parent_id=>college.id)
#    Category.create(:name=>"History and Philosophy of Science", :abbrev=>"HPS", :url=>"hps.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Philosophy", :abbrev=>"PHIL", :url=>"phil.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Values in Society", :abbrev=>"VALUES", :url=>"values.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Physics", :abbrev=>"PHYS", :url=>"phys.html", :parent_id=>college.id)
#    Category.create(:name=>"Political Science", :abbrev=>"POL S", :url=>"polisci.html", :parent_id=>college.id)
#    Category.create(:name=>"Psychology", :abbrev=>"PSYCH", :url=>"psych.html", :parent_id=>college.id)
#    Category.create(:name=>"Quantitative Science", :abbrev=>"Q SCI", :url=>"quantsci.html", :parent_id=>college.id) #special
#    top_category = Category.create(:name=>"Romance Languages and Literature", :parent_id=>college.id)
#    Category.create(:name=>"French", :abbrev=>"FRENCH", :url=>"french.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Italian", :abbrev=>"ITAL", :url=>"italian.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Portugese", :abbrev=>"PORT", :url=>"port.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Romance Languages and Literature", :abbrev=>"ROMAN", :url=>"romance.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Romance Linguistics", :abbrev=>"ROLING", :url=>"romling.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Romanian (Romance)", :abbrev=>"RMN", :url=>"romanianr.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Spanish", :abbrev=>"SPAN", :url=>"spanish.html", :parent_id=>top_category.id)
#    top_category = Category.create(:name=>"Scandinavian Languages and Literature", :parent_id=>college.id)
#    Category.create(:name=>"Danish", :abbrev=>"DANISH", :url=>"danish.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Estonian", :abbrev=>"ESTO", :url=>"eston.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Finnish", :abbrev=>"FINN", :url=>"finnish.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Latvian", :abbrev=>"LATV", :url=>"latvian.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Lithuanian", :abbrev=>"LITH", :url=>"lith.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Norwegian", :abbrev=>"NORW", :url=>"norweg.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Scandinavian", :abbrev=>"SCAND", :url=>"scand.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Swedish", :abbrev=>"SWED", :url=>"swedish.html", :parent_id=>top_category.id)
#    top_category = Category.create(:name=>"Slavic Languages and Literature", :parent_id=>college.id)
#    Category.create(:name=>"Bosnian/Croatian/Serbian", :abbrev=>"BCS", :url=>"bcs.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Bulgarian", :abbrev=>"BULGR", :url=>"bulgar.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Czech", :abbrev=>"CZECH", :url=>"czech.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Georgian", :abbrev=>"GEORG", :url=>"georg.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Polish", :abbrev=>"POLSH", :url=>"polish.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Romanian (Slavic)", :abbrev=>"ROMN", :url=>"romanian.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Russian", :abbrev=>"RUSS", :url=>"russian.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Slavic", :abbrev=>"SLAV", :url=>"slavic.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Slavic Languages and Literature", :abbrev=>"SLAVIC", :url=>"slav.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Ukranian", :abbrev=>"UKR", :url=>"ukrain.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Social Sciences", :abbrev=>"SOCSCI", :url=>"socsci.html", :parent_id=>college.id)
#    Category.create(:name=>"Sociology", :abbrev=>"SOC", :url=>"soc.html", :parent_id=>college.id)
#    Category.create(:name=>"Speech and Hearing Sciences", :abbrev=>"SPHSC", :url=>"sphsc.html", :parent_id=>college.id)
#    Category.create(:name=>"Statistics", :abbrev=>"STAT", :url=>"stat.html", :parent_id=>college.id)
#    Category.create(:name=>"Summer Arts Festival", :abbrev=>"ARTS", :url=>"arts.html", :parent_id=>college.id)
#    Category.create(:name=>"Women Studies", :abbrev=>"WOMEN", :url=>"women.html", :parent_id=>college.id)
#    Category.create(:name=>"Zoology", :abbrev=>"BIOL", :url=>"biology.html", :parent_id=>college.id) #special
#    
#    #College of Built Environments
#    college = Category.create(:name=>"College of Built Environments")
#    Category.create(:name=>"Architecture", :abbrev=>"ARCH", :url=>"archit.html", :parent_id=>college.id)
#    Category.create(:name=>"Built Environment", :abbrev=>"B E", :url=>"be.html", :parent_id=>college.id)
#    Category.create(:name=>"Construction Management", :abbrev=>"CM", :url=>"constmgmt.html", :parent_id=>college.id)
#    Category.create(:name=>"Landscape Architecture", :abbrev=>"L ARCH", :url=>"landscape.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Urban Planning", :parent_id=>college.id)
#    Category.create(:name=>"Community and Environmental Planning", :abbrev=>"CEP", :url=>"commenv.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Strategic Planning for Critical Infrastructure", :abbrev=>"SPCI", :url=>"spci.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Urban Planning", :abbrev=>"URBDP", :url=>"urbdes.html", :parent_id=>top_category.id)
#    
#    #Business School
#    college = Category.create(:name=>"Business School")
#    Category.create(:name=>"Accounting", :abbrev=>"ACCTG", :url=>"acctg.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Business Administration", :parent_id=>college.id)
#    Category.create(:name=>"Administration", :abbrev=>"ADMIN", :url=>"admin.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Business Administration", :abbrev=>"B A", :url=>"ba.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Business Administration Research Methods", :abbrev=>"BA RM", :url=>"barm.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Business Communications", :abbrev=>"B CMU", :url=>"buscomm.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Business Economics", :abbrev=>"B ECON", :url=>"busecon.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Business Policy", :abbrev=>"B POL", :url=>"bpol.html", :parent_id=>top_category.id)
#    Category.create(:name=>"E-Business", :abbrev=>"EBIZ", :url=>"ebiz.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Entrepreneurship", :abbrev=>"ENTRE", :url=>"entre.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Finance", :abbrev=>"FIN", :url=>"finance.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Human Resources Management and Organizational Behavior", :abbrev=>"HRMOB", :url=>"hrmob.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Informational Systems", :abbrev=>"I S", :url=>"infosys.html", :parent_id=>top_category.id)
#    Category.create(:name=>"International Business", :abbrev=>"I BUS", :url=>"intlbus.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Management", :abbrev=>"MGMT", :url=>"mgmt.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Marketing", :abbrev=>"MKTG", :url=>"mktg.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Operations Management", :abbrev=>"OPMGT", :url=>"opmgmt.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Organization and Environment", :abbrev=>"O E", :url=>"orgenv.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Quantitative Methods", :abbrev=>"QMETH", :url=>"qmeth.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Strategic Management", :abbrev=>"ST MGT", :url=>"stratm.html", :parent_id=>top_category.id)
#    
#    #School of Dentistry
#    college = Category.create(:name=>"School of Dentistry")
#    Category.create(:name=>"Dental Hygiene", :abbrev=>"D HYG", :url=>"denthy.html", :parent_id=>college.id)
#    Category.create(:name=>"Dental Public Health Sciences", :abbrev=>"DPHS", :url=>"dphs.html", :parent_id=>college.id)
#    Category.create(:name=>"Dentistry", :abbrev=>"DENT", :url=>"dent.html", :parent_id=>college.id)
#    Category.create(:name=>"Endodontics", :abbrev=>"ENDO", :url=>"endo.html", :parent_id=>college.id)
#    Category.create(:name=>"Oral Biology", :abbrev=>"ORALB", :url=>"oralbio.html", :parent_id=>college.id)
#    Category.create(:name=>"Oral Medicine", :abbrev=>"ORALM", :url=>"oralm.html", :parent_id=>college.id)
#    Category.create(:name=>"Oral Surgery", :abbrev=>"O S", :url=>"os.html", :parent_id=>college.id)
#    Category.create(:name=>"Orthodontics", :abbrev=>"ORTHO", :url=>"orthod.html", :parent_id=>college.id)
#    Category.create(:name=>"Pediatric Dentistry", :abbrev=>"PEDO", :url=>"pedodon.html", :parent_id=>college.id)
#    Category.create(:name=>"Periodontics", :abbrev=>"PERIO", :url=>"perio.html", :parent_id=>college.id)
#    Category.create(:name=>"Prosthodontics", :abbrev=>"PROS", :url=>"pros.html", :parent_id=>college.id)
#    Category.create(:name=>"Restorative Dentistry", :abbrev=>"RES D", :url=>"restor.html", :parent_id=>college.id)
#    
#    #College of Education
#    college = Category.create(:name=>"College of Education")
#    Category.create(:name=>"Curriculum and Instruction", :abbrev=>"EDC&I", :url=>"edci.html", :parent_id=>college.id)
#    Category.create(:name=>"College of Education", :abbrev=>"EDUC", :url=>"indsrf.html", :parent_id=>college.id)
#    Category.create(:name=>"Early Childhood and Family Studies", :abbrev=>"ECFS", :url=>"ecfs.html", :parent_id=>college.id)
#    Category.create(:name=>"Education (Teacher Education Program)", :abbrev=>"EDTEP", :url=>"teached.html", :parent_id=>college.id)
#    Category.create(:name=>"Educational Leadership and Policy Studies", :abbrev=>"EDLPS", :url=>"edlp.html", :parent_id=>college.id)
#    Category.create(:name=>"Educational Psychology", :abbrev=>"EDPSY", :url=>"edpsy.html", :parent_id=>college.id)
#    Category.create(:name=>"Special Education", :abbrev=>"EDSPE", :url=>"sped.html", :parent_id=>college.id)
#    
#    #College of Engineering
#    college = Category.create(:name=>"College of Engineering")
#    Category.create(:name=>"Aeronautics and Astronautics", :abbrev=>"A A", :url=>"aa.html", :parent_id=>college.id)
#    Category.create(:name=>"Chemical Engineering", :abbrev=>"CHEM E", :url=>"cheng.html", :parent_id=>college.id)
#    Category.create(:name=>"Civil and Environmental Engineering", :abbrev=>"CEE", :url=>"cee.html", :parent_id=>college.id)
#    Category.create(:name=>"Computer Science and Engineering", :abbrev=>"CSE", :url=>"cse.html", :parent_id=>college.id)
#    Category.create(:name=>"Electrical Engineering", :abbrev=>"E E", :url=>"ee.html", :parent_id=>college.id)
#    Category.create(:name=>"Engineering", :abbrev=>"ENGR", :url=>"engr.html", :parent_id=>college.id)
#    Category.create(:name=>"Industrial Engineering", :abbrev=>"IND E", :url=>"inde.html", :parent_id=>college.id)
#    Category.create(:name=>"Materials Science and Engineering", :abbrev=>"MS E", :url=>"mse.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Mechanical Engineering", :parent_id=>college.id)
#    Category.create(:name=>"Mechanical Engineering", :abbrev=>"M E", :url=>"meche.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Mechanical Engineering Industrial Engineering", :abbrev=>"MEIE", :url=>"meie.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Technical Communication", :abbrev=>"T C", :url=>"techc.html", :parent_id=>college.id)
#    
#    #College of Forest Resources
#    college = Category.create(:name=>"College of Forest Resources")
#    Category.create(:name=>"College of Forest Resources", :abbrev=>"CFR", :url=>"forr.html", :parent_id=>college.id)
#    Category.create(:name=>"Environmental Science and Resource Management", :abbrev=>"ESRM", :url=>"esrm.html", :parent_id=>college.id)
#    Category.create(:name=>"Paper Science and Engineering", :abbrev=>"PSE", :url=>"paper.html", :parent_id=>college.id)
#    
#    #The Information School
#    college = Category.create(:name=>"The Information School")
#    Category.create(:name=>"Informatics", :abbrev=>"INFO", :url=>"info.html", :parent_id=>college.id)
#    Category.create(:name=>"Information School Interdisciplinary", :abbrev=>"INFX", :url=>"infx.html", :parent_id=>college.id)
#    Category.create(:name=>"Information Science", :abbrev=>"INSC", :url=>"insc.html", :parent_id=>college.id)
#    Category.create(:name=>"Information Management", :abbrev=>"IMT", :url=>"95imt.html", :parent_id=>college.id)
#    Category.create(:name=>"Library and Information Science", :abbrev=>"LIS", :url=>"lis.html", :parent_id=>college.id)
#    
#    #Interdisciplinary Graduate Programs
#    college = Category.create(:name=>"Interdisciplinary Graduate Programs")
#    Category.create(:name=>"Biomolecular Structure and Design", :abbrev=>"BMSD", :url=>"bmsd.html", :parent_id=>college.id)
#    Category.create(:name=>"Graduate School", :abbrev=>"GRDSCH", :url=>"grad.html", :parent_id=>college.id)
#    Category.create(:name=>"Global Trade, Transportation & Logistics", :abbrev=>"GTTL", :url=>"gttl.html", :parent_id=>college.id)
#    Category.create(:name=>"Individual PhD", :abbrev=>"IPHD", :url=>"iphd.html", :parent_id=>college.id)
#    Category.create(:name=>"Molecular and Cellular Biology", :abbrev=>"MCB", :url=>"mcb.html", :parent_id=>college.id)
#    Category.create(:name=>"Museology", :abbrev=>"MUSEUM", :url=>"museo.html", :parent_id=>college.id)
#    Category.create(:name=>"Near and Middle Eastern Studies", :abbrev=>"N&MES", :url=>"nearmide.html", :parent_id=>college.id)
#    Category.create(:name=>"Neurobiology and Behavior", :abbrev=>"NEUBEH", :url=>"neurobio.html", :parent_id=>college.id)
#    Category.create(:name=>"Nutritional Science", :abbrev=>"NUTR", :url=>"nutrit.html", :parent_id=>college.id)
#    Category.create(:name=>"Program on the Environment", :abbrev=>"ENVIR", :url=>"envst.html", :parent_id=>college.id)
#    Category.create(:name=>"Quantitative Ecology and Resource Management", :abbrev=>"QERM", :url=>"quante.html", :parent_id=>college.id)
#    Category.create(:name=>"Quaternary Science", :abbrev=>"QUAT", :url=>"qrc.html", :parent_id=>college.id)
#    
#    #Interschool or Intercollege Programs
#    college = Category.create(:name=>"Interschool or Intercollege Programs")
#    Category.create(:name=>"Bioengineering", :abbrev=>"BIOEN", :url=>"bioeng.html", :parent_id=>college.id)
#    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"gh.html", :parent_id=>college.id)
#    Category.create(:name=>"University Conjoint Courses", :abbrev=>"UCONJ", :url=>"uconjoint.html", :parent_id=>college.id)
#    
#    #School of Law
#    college = Category.create(:name=>"School of Law")
#    Category.create(:name=>"Health Law", :abbrev=>"LAW H", :url=>"lawh.html", :parent_id=>college.id)
#    Category.create(:name=>"Intellectual Property Law", :abbrev=>"LAW P", :url=>"lawp.html", :parent_id=>college.id)
#    Category.create(:name=>"Law", :abbrev=>"LAW", :url=>"law.html", :parent_id=>college.id)
#    Category.create(:name=>"Law (Taxation)", :abbrev=>"LAW T", :url=>"lawt.html", :parent_id=>college.id)
#    Category.create(:name=>"Law A", :abbrev=>"LAW A", :url=>"lawa.html", :parent_id=>college.id)
#    Category.create(:name=>"Law B", :abbrev=>"LAW B", :url=>"lawb.html", :parent_id=>college.id)
#    Category.create(:name=>"Law E", :abbrev=>"LAW E", :url=>"lawe.html", :parent_id=>college.id)
#    
#    #School of Medicine
#    college = Category.create(:name=>"School of Medicine")
#    Category.create(:name=>"Anesthesiology", :abbrev=>"ANEST", :url=>"anest.html", :parent_id=>college.id)
#    Category.create(:name=>"Biochemistry", :abbrev=>"BIOC", :url=>"bioch.html", :parent_id=>college.id)
#    Category.create(:name=>"Bioengineering", :abbrev=>"BIOEN", :url=>"bioeng.html", :parent_id=>college.id)
#    Category.create(:name=>"Biological Structure", :abbrev=>"B STR", :url=>"biostruct.html", :parent_id=>college.id)
#    Category.create(:name=>"Comparative Medicine", :abbrev=>"C MED", :url=>"compmed.html", :parent_id=>college.id)
#    Category.create(:name=>"Conjoint Courses", :abbrev=>"CONJ", :url=>"conj.html", :parent_id=>college.id)
#    Category.create(:name=>"Family Medicine", :abbrev=>"FAMED", :url=>"famed.html", :parent_id=>college.id)
#    Category.create(:name=>"Genome Sciences", :abbrev=>"GENOME", :url=>"genome.html", :parent_id=>college.id)
#    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"gh.html", :parent_id=>college.id)
#    Category.create(:name=>"Human Biology", :abbrev=>"HUBIO", :url=>"humbio.html", :parent_id=>college.id)
#    Category.create(:name=>"Immunology", :abbrev=>"IMMUN", :url=>"immun.html", :parent_id=>college.id)
#    Category.create(:name=>"Laboratory Medicine", :abbrev=>"LAB M", :url=>"law.html", :parent_id=>college.id)
#    Category.create(:name=>"MEDEX Program", :abbrev=>"MEDEX", :url=>"93medex.html", :parent_id=>college.id)
#    Category.create(:name=>"Medical Education and Biomedical Informatics", :abbrev=>"MEBI", :url=>"law.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Medical History and Ethics", :parent_id=>college.id)
#    Category.create(:name=>"Bioethics and Humanities", :abbrev=>"B H", :url=>"bh.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Medical History and Ethics", :abbrev=>"MHE", :url=>"medhist.html", :parent_id=>top_category.id)
#    top_category = Category.create(:name=>"Medicine", :parent_id=>college.id)
#    Category.create(:name=>"Emergency Medicine", :abbrev=>"MED ER", :url=>"meder.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Medicine", :abbrev=>"MED", :url=>"medicine.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Medicine Elective Clerkships", :abbrev=>"MEDECK", :url=>"admin.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Medicine Required Clerkships", :abbrev=>"MEDRCK", :url=>"admin.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Microbiology", :abbrev=>"MICROM", :url=>"microbio.html", :parent_id=>college.id)
#    Category.create(:name=>"Neurological Surgery", :abbrev=>"NEUR S", :url=>"neurosurg.html", :parent_id=>college.id)
#    Category.create(:name=>"Neurology", :abbrev=>"NEURL", :url=>"neurl.html", :parent_id=>college.id)
#    Category.create(:name=>"Obstetrics and Gynecology", :abbrev=>"OB GYN", :url=>"obgyn.html", :parent_id=>college.id)
#    Category.create(:name=>"Ophthalmology", :abbrev=>"OPHTH", :url=>"ophthal.html", :parent_id=>college.id)
#    Category.create(:name=>"Orthopedics", :abbrev=>"ORTHP", :url=>"orthop.html", :parent_id=>college.id)
#    Category.create(:name=>"Otolaryngology -- Head and Neck Surgery", :abbrev=>"OTOHN", :url=>"otol.html", :parent_id=>college.id)
#    Category.create(:name=>"Pathology", :abbrev=>"PATH", :url=>"patho.html", :parent_id=>college.id)
#    Category.create(:name=>"Pediatrics", :abbrev=>"PEDS", :url=>"pediat.html", :parent_id=>college.id)
#    Category.create(:name=>"Pharmacology", :abbrev=>"PHCOL", :url=>"pharma.html", :parent_id=>college.id)
#    Category.create(:name=>"Physiology and Biophysics", :abbrev=>"P BIO", :url=>"physiolbio.html", :parent_id=>college.id)
#    Category.create(:name=>"Psychiatry and Behavioral Sciences", :abbrev=>"PBSCI", :url=>"psychbehav.html", :parent_id=>college.id)
#    Category.create(:name=>"Radiation Oncology", :abbrev=>"R ONC", :url=>"radonc.html", :parent_id=>college.id)
#    Category.create(:name=>"Radiology", :abbrev=>"RADGY", :url=>"radiol.html", :parent_id=>college.id)
#    Category.create(:name=>"Rehabilitation Medicine", :abbrev=>"REHAB", :url=>"rehab.html", :parent_id=>college.id)
#    Category.create(:name=>"Surgery", :abbrev=>"SURG", :url=>"surg.html", :parent_id=>college.id)
#    Category.create(:name=>"Urology", :abbrev=>"UROL", :url=>"uro.html", :parent_id=>college.id)
#    
#    #School of Nursing
#    college = Category.create(:name=>"School of Nursing")
#    Category.create(:name=>"Nursing", :abbrev=>"NSG", :url=>"nsg.html", :parent_id=>college.id)
#    Category.create(:name=>"Nursing", :abbrev=>"NURS", :url=>"nursing.html", :parent_id=>college.id)
#    Category.create(:name=>"Nursing Clinical", :abbrev=>"NCLIN", :url=>"nursingcl.html", :parent_id=>college.id)
#    Category.create(:name=>"Nursing Methods", :abbrev=>"NMETH", :url=>"nursingmeth.html", :parent_id=>college.id)
#    
#    #College of Ocean and Fishery Sciences
#    college = Category.create(:name=>"College of Ocean and Fishery Sciences")
#    Category.create(:name=>"Aquatic and Fishery Sciences", :abbrev=>"FISH", :url=>"fish.html", :parent_id=>college.id)
#    Category.create(:name=>"School of Marine Affairs", :abbrev=>"SMA", :url=>"marine.html", :parent_id=>college.id)
#    Category.create(:name=>"Oceanography", :abbrev=>"OCEAN", :url=>"ocean.html", :parent_id=>college.id)
#    
#    #School of Pharmacy
#    college = Category.create(:name=>"School of Pharmacy")
#    Category.create(:name=>"Medicinal Chemistry", :abbrev=>"MEDCH", :url=>"medchem.html", :parent_id=>college.id)
#    Category.create(:name=>"Pharmaceutics", :abbrev=>"PCEUT", :url=>"pharmceu.html", :parent_id=>college.id)
#    Category.create(:name=>"Pharmacy", :abbrev=>"PHARM", :url=>"pharmacy.html", :parent_id=>college.id)
#    Category.create(:name=>"Pharmacy Regulatory Affairs", :abbrev=>"PHRMRA", :url=>"phrmra.html", :parent_id=>college.id)
#    
#    #Evans School of Public Affairs
#    college = Category.create(:name=>"Evans School of Public Affairs")
#    Category.create(:name=>"Public Affairs", :abbrev=>"PB AF", :url=>"pubaff.html", :parent_id=>college.id)
#    Category.create(:name=>"Public Policy and Management", :abbrev=>"PPM", :url=>"ppm.html", :parent_id=>college.id)
#    
#    #School of Public Health
#    college = Category.create(:name=>"School of Public Health")
#    Category.create(:name=>"Biostatistics", :abbrev=>"BIOST", :url=>"biostat.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Environmental and Occupational Health Sciences", :parent_id=>college.id)
#    Category.create(:name=>"Environmental Health", :abbrev=>"ENV H", :url=>"envh.html", :parent_id=>top_category.id)
#    top_category = Category.create(:name=>"Epidemiology", :parent_id=>college.id)
#    Category.create(:name=>"Epidemiology", :abbrev=>"EPI", :url=>"epidem.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Public Health Genetics", :abbrev=>"PHG", :url=>"phg.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"gh.html", :parent_id=>college.id)
#    top_category = Category.create(:name=>"Health Services", :parent_id=>college.id)
#    Category.create(:name=>"Health Services", :abbrev=>"HSERV", :url=>"hlthsvcs.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Health Services Management", :abbrev=>"HSMGMT", :url=>"hsmgmt.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Pathobiology", :abbrev=>"PABIO", :url=>"pathobio.html", :parent_id=>college.id)
#    
#    #Reserve Officers Training Corps Programs
#    college = Category.create(:name=>"Reserve Officers Training Corps Programs")
#    Category.create(:name=>"Aerospace Studies", :abbrev=>"A S", :url=>"88aerosci.html", :parent_id=>college.id)
#    Category.create(:name=>"Military Science", :abbrev=>"M SCI", :url=>"88milsci.html", :parent_id=>college.id)
#    Category.create(:name=>"Naval Science", :abbrev=>"N SCI", :url=>"88navsci.html", :parent_id=>college.id)
#    
#    #School of Social Work
#    college = Category.create(:name=>"School of Social Work")
#    Category.create(:name=>"Social Welfare BASW", :abbrev=>"SOC WF", :url=>"socwlbasw.html", :parent_id=>college.id)
#    Category.create(:name=>"Social Welfare", :abbrev=>"SOC WL", :url=>"socwl.html", :parent_id=>college.id)
#    Category.create(:name=>"Social Work (MSW)", :abbrev=>"SOC W", :url=>"socwk.html", :parent_id=>college.id)
#    
#    #Extended MPH Degree Program
#    college = Category.create(:name=>"Extended MPH Degree Program")
#    top_category = Category.create(:name=>"School of Public Health", :parent_id=>college.id)
#    Category.create(:name=>"Biostatistics", :abbrev=>"BIOST", :url=>"94biostat.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Environmental Health", :abbrev=>"ENV H", :url=>"94envh.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Epidemiology", :abbrev=>"EPI", :url=>"94epidem.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Public Health Genetics", :abbrev=>"PHG", :url=>"94phg.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Health Services", :abbrev=>"HSERV", :url=>"94hlthsvcs.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Health Services Management", :abbrev=>"HSMGMT", :url=>"94hsmgmt.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Nutritional Science", :abbrev=>"NUTR", :url=>"94nutrit.html", :parent_id=>top_category.id)
#    
#    #Friday Harbor Laboratories
#    college = Category.create(:name=>"Friday Harbor Laboratories")
#    top_category = Category.create(:name=>"College of Arts and Sciences", :parent_id=>college.id)
#    Category.create(:name=>"Biology", :abbrev=>"BIOL", :url=>"91biology.html", :parent_id=>top_category.id)
#    top_category = Category.create(:name=>"College of Ocean and Fishery Sciences", :parent_id=>college.id)
#    Category.create(:name=>"Aquatic and Fishery Sciences", :abbrev=>"FISH", :url=>"91fish.html", :parent_id=>top_category.id)
#    Category.create(:name=>"School of Marine Affairs", :abbrev=>"SMA", :url=>"91marine.html", :parent_id=>top_category.id)
#    Category.create(:name=>"Oceanography", :abbrev=>"OCEAN", :url=>"91ocean.html", :parent_id=>top_category.id)
    
    #process each category (DO VERK)
    
    i=50
    
    #DO VERK
    categories = Category.find_by_sql("SELECT * FROM huskyschedule_development.categories WHERE url!=''")
    for category in categories
      category_parser(url+category.url, category.url, category.abbrev, quarter, year, category.id)
    end
    
#    cat = Category.find_by_sql("SELECT * FROM huskyschedule_development.categories WHERE abbrev = 'SCAND'")[0]
#    category_parser("http://www.washington.edu/students/timeschd/WIN2009/scand.html", "scand.html", quarter, year, cat.id)
  
  end

  
  #  def self.time_schedule_parser(url)
#    
#    sql.execute("DELETE FROM huskyschedule_development.categories")
#    active_subcategory = nil
#    contents = get_html_array(url)
#    i=0
#    while(i < contents.length) #main loop
#      line = contents[i]
#      if(/^<a name=/i.match(line) && !(/<!--/.match(contents[i-1]))) #no html comment before
#        #processing a college
#        #<P><B><a name="O">College of Ocean and Fishery Sciences</a></B><BR>
#        matches = line.match(/^<A name="(.*)"><B>([^<]+)</i)
#        if(matches.nil?)
#          matches = line.match(/^<P><B><A NAME="(.*)">([^<]+)<\/A>/i)
#        end
#        if(!matches.nil?)
#          abbrev = matches[1] #what to do with this
#          college_name = clean_text(matches[2])
#          if(college_name == "Extended MPH Degree Program")
#            break
#          end
#          puts("College name: #{college_name}\n\n")
#          college = Category.create(:name=>college_name, :abbrev=>"College")
#          college.save()
#          i+=1
#          while(i < contents.length) #ready to loop through categories of the college, <UL> loop
#            line2 = contents[i]
#            if(/^<UL>/i.match(line2)) #main <UL> for an entire college
#              i+=1
#              while(i < contents.length) #<LI> loop
#                line3 = contents[i]
#                if((/^<LI>.*<\/LI>/i.match(line3) && !/<a/i.match(line3)) ||
#                   ((/^<LI>/i.match(line3) && !(/<a/i.match(line3))) || 
#                   (/^<LI><A name/i.match(line3))) && 
#                   !(/^<LI>.*<\/LI>/i.match(line3) && !/<a/i.match(line3))) #sub categories
#                  matches = line3.match(/^<LI><A NAME=.*>(.*)<\/A>/i)
#                  if(matches.nil?)
#                    matches = line3.match(/^<LI>(.*)<\/LI>$/i)
#                    if(matches.nil?)
#                      matches = line3.match(/^<LI>(.*)$/i)
#                    end
#                  end
#                  category_name = clean_text(matches[1].strip)
#                  category = Category.create(:name=>category_name, :abbrev=>"Top Category")
#                  category.parent_id = college.id
#                  category.save()
#                  puts("Found a topcat #{category.name}\n")
#                  while(i < contents.length) #sub categories
#                    line4 = contents[i]
#                    if(/^<LI><A/.match(line4) && !(/<\/A>/.match(line4)))
#                      i+=1
#                      line4 += " " + contents[i]
#                    end
#                    matches_subcategory = line4.match(/^<LI><A HREF=([A-Za-z\.]+)>(.*)<\/A>/i)
#                    if(!matches_subcategory.nil?)
#                      subcategory_url = matches_subcategory[1]
#                      subcategory_name = clean_text(matches_subcategory[2])
#                      sub_category = Category.new(:name=>subcategory_name, :parent_id=>category.id)
#                      sub_category.save()
#                      puts("Found a subcat #{sub_category.name}\n\n")
#                      #category_parser(url+subcategory_url, sub_category.id)
#                      i+=1 #continue searching
#                    elsif(/^<\/LI>$/i.match(line4) || /^<\/UL><\/LI>$/i.match(line4) || /^<\/UL>$/i.match(line4))
#                      i+=1
#                      puts("Breaking out of subcat loop i=#{i}\n\n")
#                      break #done processing sub categories
#                    else
#                      i+=1
#                    end
#                  end #done processing sub categories
#                elsif(/^<LI>/i.match(line3) && /^<LI><A/i.match(line3) && !(/<!--/.match(contents[i-1])) && !/see\s/i.match(line3))
#                  if(/^<LI><A/.match(line3) && !(/<\/A>/.match(line3)))
#                    i+=1
#                    line3 += " " + contents[i]
#                  end
#                  matches = line3.match(/^<LI><A.*=([^>]+)>(.*)<\/A>/i)
#                  category_url = matches[1]
#                  category_name = clean_text(matches[2])
#                  category = Category.new(:name=>category_name, :parent_id=>college.id)
#                  category.save()
#                  puts("Found a category #{category.name}\n\n")
#                  #category_parser(url+category_url, category.id)
#                  i+=1 #continue searching
#                elsif(/^<\/UL>/i.match(line3))
#                  puts("breaking out of college loop i=#{i}\n\n")
#                  break #out of <LI> loop
#                else
#                  i+=1
#                end
#              end
#            elsif(/^<\/UL>$/i.match(line2) || /^<div id="footer">/i.match(line2)) #end of this college's data
#              break #out of <UL> loop
#            else #if(/^<UL>/i.match(line_category))
#              i+=1
#            end
#          end
#        else #matches = line.match(/^<A name="(.*)"><B>(.*)<\/B>/i) if(!matches.nil?)
#          i+=1
#        end
#      elsif(/^<div id="footer">/i.match(line))
#        break
#      else #if(/^<a name=/i.match(line) && !(/<!--/.match(contents[i-1]))) no html comment before
#        i+=1
#      end
#    end #main while loop
#    return "Complete."
#  end
    
#################################################################################################  
#parser for a specific category   
#################################################################################################
  
  def self.category_parser(url, cat_url, dept_abbrev, quarter, year, parent_id)
    contents = get_html_array(url)
    #variables to be filled
    active_lecture = nil
    course_description_contents = get_html_array(Category::DESCRIPTION_URL + cat_url) #load this once
    #end variables to be filled
    
    i=0 #main counter for the parser
    
    while(i<contents.length)
      line = contents[i]
      if(/^<br>$/i.match(line))
        #beginning a course
        i+=1
        while(i<contents.length)
          line = contents[i]
          matches = line.match(/NAME=([A-Za-z]+)([0-9]+)>/i) #<A NAME=academ198>
          if(!matches.nil?) #ready to process all lectures/quiz sections of a course
            course_number = matches[2].to_i
            course_title = get_course_title(line, course_description_contents, course_number)
            course_description = get_course_description(line, course_description_contents, course_number)
            #puts("Course description = #{course_description}")
            credit_type = get_credit_type(line)
            puts("Parsing #{dept_abbrev} #{course_number}\n")
            while(i<contents.length) #ready to start gathering data about the lectures/sections
              line2 = contents[i]
              matches2 = line2.match(/SLN=([0-9]{5})>/i)
              if(!matches2.nil?) #process this class's data
                sln = matches2[1].to_i
                section = get_section(line2, sln)
                c = nil
                lab_or_quiz = section.length > 1
                if(!lab_or_quiz) #lecture
                  c = Course.create(:deptabbrev=>dept_abbrev, :number=>course_number, :title=>course_title, :credit_type=>credit_type, :quarter_id=>quarter, :year=>year)
                  begin #stupid edge case because one course's description had a character 'ø' and I can't plug that into a regex
                    c.description = course_description
                    c.save()
                  rescue
                    c.description = "See #{Category::DESCRIPTION_URL}#{cat_url} for description."
                  end
                  active_lecture = c
                  c.parent_id = parent_id
                elsif(/LB/.match(line2))
                  c = Lab.create(:parent_id=>active_lecture.id)
                else #quiz section
                  c = QuizSection.create(:parent_id=>active_lecture.id)
                end
                c.sln = sln
                c.section = section
                i = process_course(c, i, contents, line2, lab_or_quiz)
                c.save()
              elsif(/^<br>$/i.match(line2) || /to be arranged/i.match(line2))
                break
              else
                i+=1 #continue advancing through the lines
              end
            end
          elsif(/^<br>$/i.match(line))
            break
          else
            i+=1 #continue advancing through the lines
          end
        end #finished processing a course  
      elsif(!(line.match(/^<div id="footer"/i).nil?))
        break
      else
        i+=1 #continue advancing through the lines
      end
    end #outer-most while loop
  end
  
  def self.process_course(c, i, contents, line, lab_or_quiz)
    if(/to be arranged/i.match(line))
      return i+1
    else
      if(!lab_or_quiz)
        assign_credit_amount(c, line, c.sln, c.section)
        c.restricted = get_restricted(line)
      end
      c.additional_info = get_additional_info(line)
      times = get_times(c.sln, c.section, line)
      building_id = get_building_id(line)
      building = Building.find_by_id(building_id)
      if(building_id != Building::BUILDING_NOTFOUND)
        room = get_room(line, building.abbrev)
        if(room != "Not listed")
          c.teacher_id = get_teacher_id(room, line)
        else
          c.teacher_id = get_teacher_id_no_room(building.abbrev, line)
        end
      else
        room = "Not listed"
      end
      c.rendezvous = [Rendezvous.new(:times=>times, :building_id=>building_id, :room=>room)]
      c.crnc = get_crnc(line)
      c.status = Course.get_status(line)
      assign_enrollment_ratio(c, line)
      if(c.description.nil?)
        c.description = ""
      end
      c.description += get_course_fee(line)
      #notes
      i+=1
      notes = ""
      puts(c.inspect)
      while(i < contents.size)
        line2 = contents[i]
        if(is_line_of_class_times(line2))
          process_line_of_class_times(c, line2)
        elsif(/^<\/td>/.match(line2))
          break
        else
          notes += line2.strip + " "
        end
        i+=1
      end
      c.notes = check_notes(notes)
      puts(c.inspect)
      c.times = times
      buildings = []
      for rendezvous in c.rendezvous
        buildings.push(rendezvous.building_id)
      end
      c.buildings = buildings
      return i
    end
  end
  
  def self.clean_text(text, find)
    split = text.split(find)
    if(split.length > 0)
      result = ""
      for s in split
        result += " " + s.strip
      end
      puts("HERE bad = #{find}")
      return result.strip
    else
      return text.strip
    end
  end
  
  def self.check_notes(notes)
    bad = "\377"
    return clean_text(notes, bad) #stupid edge case
  end
  
  def self.get_course_title(line, course_description_contents, course_number)
    contents = course_description_contents
    i=0
    
    while(i<contents.length)
      line2 = contents[i]
      matches2 = line2.match(/#{course_number}\s?<\/A>\s+([^\(]+)\(/i)
      if(!matches2.nil?)
        return matches2[1].strip
      else
        i+=1
      end
    end
    #not found in course_description_contents
    matches = line.match(/<a href=.*#{course_number}>(.*)<\/A>/i)
    if(matches.nil?)
      return "NOT FOUND" 
    else
      return matches[1]
    end
  end
  
  def self.get_course_description(line, course_description_contents, course_number)
    contents = course_description_contents
    i=0
    while(i<contents.length)
      line2 = contents[i]
      matches2 = line2.match(/^<P><B><A NAME=.*#{course_number}.*>.*#{course_number}.*<\/A>.*<BR>(.*)$/i)
      if(!matches2.nil?)
        return matches2[1]
      else
        i+=1
      end
    end
    return "" #unable to find course description
  end
  
  def self.get_credit_type(line)
    matches = line.match(/<b>\(([^\)]+)\)<\/b>/i)
    if(!matches.nil?)
      return Course.get_credit_types(matches[1])
    else
      return [Course::CREDITTYPE_NOTLISTED]
    end
  end
  
  def self.get_restricted(line)
    return !(line.match(/^Restr/).nil?)
  end
  
  def self.get_section(line, sln)
    matches = line.match(/#{sln}<\/A>\s([A-Z0-9]+)\s+/i)
    if(!matches.nil?)
       return matches[1]
    else
      return "error on line #{line}"
    end
  end
  
  def self.assign_credit_amount(c, line, sln, section)
    matches = line.match(/>#{sln}<\/A>\s+#{section}\s+([0-9-]+)/i)
    if(matches.nil?)
      matches2 = line.match(/#{sln}.*>.*<\/A>\s+#{section}\s+[^\d]+/i) #"VAR" or something else
      if(!matches2.nil?)
        c.credits = 1
        c.variable_credit = 11 #Max # of credits i've seen
      else
        c.credits = -1 #error
      end
    else
      credits = matches[1]
      if(/-/.match(credits))
        split = credits.split(/-/)
        c.credits = split[0].to_i #lowest = most significant
        c.variable_credit = split[1].to_i #highest = variable
      else
        c.credits = credits.to_i
      end
    end
  end
  
  MONDAY = Time.parse("Monday January 26, 2009")
  TUESDAY = Time.parse("Tuesday January 27, 2009")
  WEDNESDAY = Time.parse("Wednesday January 28, 2009")
  THURSDAY = Time.parse("Thursday January 29, 2009")
  FRIDAY = Time.parse("Friday January 30, 2009")
  
  def self.build_times_array(days_of_week, start_time_string, end_time_string)
    start_time_pm = false
    end_time_pm = false
    start_time = start_time_string.to_i #930
    start_hour = start_time/100 #9 /
    start_minutes = start_time%100 #30
    if(/P/.match(end_time_string))
      end_pm = true
      end_time_string = end_time_string.match(/([0-9]+)/)[1]
    end
    end_time = end_time_string.to_i #1020  
    end_hour = end_time/100 #10 /
    end_minutes = end_time%100 #20
    if(start_hour == 12)
      start_pm = true
      end_pm = true
    elsif(end_hour == 12)
      end_pm = true
      start_pm = false
    elsif(start_hour > end_hour) #11am - 1pm
      end_pm = true
      start_pm = false
    else #start_hour < end_hour
      if(end_pm) #was set above when a "P" was seen
        start_pm = true
      elsif(start_hour >= 7 && start_hour < 11) #between 7am and 10am
        end_pm = false
        start_pm = false
      else #1 <= start <= _____
        start_pm = true
        end_pm = true
      end  
    end
    start_time_string = start_hour.to_s + ":" + start_minutes.to_s + " " + ((start_pm)? "pm" : "am")
    end_time_string = end_hour.to_s + ":" + end_minutes.to_s + " " + ((end_pm)? "pm" : "am")
    times = []
    if(/M/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = MONDAY), Time.parse(end_time_string, now = MONDAY)])
    end
    if(/TW/.match(days_of_week) || /TTh/.match(days_of_week) || /TF/.match(days_of_week) || /T$/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = TUESDAY), Time.parse(end_time_string, now = TUESDAY)])
    end
    if(/W/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = WEDNESDAY), Time.parse(end_time_string, now = WEDNESDAY)])
    end
    if(/Th/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = THURSDAY), Time.parse(end_time_string, now = THURSDAY)])
    end
    if(/F/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = FRIDAY), Time.parse(end_time_string, now = FRIDAY)])
    end
    return times
  end
  
  def self.get_times(sln, section, line)
    matches = line.match(/#{sln}\s*<\/A>\s+#{section}\s+(\d?)\s+[QZLB]{0,2}\s+([A-Za-z]+)\s+([0-9]+)-([0-9P]+)\s+/i)
    if(!matches.nil?)
      days_of_week = matches[2] #"MTWThF"
      start_time_string = matches[3] #"930"
      end_time_string = matches[4] #"1020" or "1020P"
      return build_times_array(days_of_week, start_time_string, end_time_string)
    else
      return []
    end
  end
  
  def self.get_building_id(line)
    matches = line.match(/>([A-Z]{2,5})</)
    if(!matches.nil?)
      building_abbrev = matches[1]
      return Building.get_building_id(building_abbrev)
    else
      return Building::BUILDING_NOTFOUND
    end  
  end
  
  def self.get_room(line, building_abbrev)
    matches = line.match(/>#{building_abbrev}<\/a>\s+([0-9A-Z]+)\s+/i)
    return (matches.nil?)? "Not listed" : matches[1]
  end
  
  def self.get_teacher_id(room, line)
    id = 0
    if(/#{room}\s+\d+\//.match(line))
      return Teacher::TEACHER_NOTLISTED 
    else
      name = ""
      matches_link = line.match(/#{room}\s+<a href=.*>([^<]+)<\/a>\s+[OpenClosed0-9]+/i)
      if(!matches_link.nil?)
        name = matches_link[1]
      else
        matches_no_link = line.match(/#{room}\s+([A-Z-,\s\.]+)\s+[OpenClosed\d]+/)
        if(!matches_no_link.nil?)
          name = matches_no_link[1]
        else
          return Teacher::TEACHER_NOTLISTED
        end
      end
      return Teacher.get_teacher_id(name)
    end
  end
  
  #for when the room number isn't given
  def self.get_teacher_id_no_room(building_abbrev, line)
    id = 0
    matches_link = line.match(/>#{building_abbrev}<\/A>\s+<A HREF=.*>([^<]+)<\/A>/i)
    name = ""
    if(matches_link.nil?)
      matches_no_link = line.match(/<#{building_abbrev}<\/A>\s+([A-Z-,\s\.]+)\s+[OpenClosed\d]+/i)
      if(matches_no_link.nil?)
        return Teacher::TEACHER_NOTFOUND
      else
        name = matches_no_link[1]
      end
    else
      name = matches_link[1]
    end
    return Teacher.get_teacher_id(name)
  end
  
  def self.get_crnc(line)
    return !(/CR\/NC/.match(line).nil?)
  end
  
  def self.assign_enrollment_ratio(c, line)
    matches = line.match(/([0-9]+)\/\s*([0-9]+)E?\s+/)
    c.students_enrolled = matches[1].to_i
    c.enrollment_space = matches[2].to_i
  end
  
  def self.is_line_of_class_times(line)
    return /\sM\s/.match(line)   ||
           /\sMT/.match(line)    ||
           /\sMW/.match(line)    ||
           /\sMTh/.match(line)   ||
           /\sMF\s/.match(line)  ||
           /\sT\s/.match(line)   ||
           /\sTW/.match(line)    ||
           /\sTTh/.match(line)   ||
           /\sTF\s/.match(line)  ||
           /\sW\s+\d/.match(line)||
           /\sWTh/.match(line)   ||
           /\sWF\s/.match(line)  ||
           /\sTh\s/.match(line)  ||
           /\sThF\s/.match(line) ||
           /\sF\s/.match(line)
  end

  def self.process_line_of_class_times(c, line)
    matches = line.match(/([MTWhF]+)\s+([0-9]+)-([0-9P]+)\s+.*>([A-Z]+)<\/A>\s+([A-Z0-9]+)/)
    if(!matches.nil?)
      days_of_week = matches[1]
      start_time_string = matches[2]
      end_time_string = matches[3]
      times = build_times_array(days_of_week, start_time_string, end_time_string)
      abbrev = matches[4]
      building = Building.find_by_abbrev(abbrev)
      if(building.nil?) #building is already in there
        building = Building.create(:abbrev => abbrev)
      end
      room = matches[5]
      c.rendezvous.push(Rendezvous.new(:times=>times, :room=>room, :building_id=>building.id))
    end  
  end 
  
  def self.get_course_fee(line)
    matches = line.match(/\s+\$([0-9]+)\s+/)
    if(!matches.nil?)
      return "Course fee: $#{matches[1]}."
    else
      return ""
    end
  end 
  
  def self.get_additional_info(line)
    matches = line.match(/([DHJRSW%#]+)\s*$/)
    if(!matches.nil?)
       return Course.get_additional_info(matches[1])
    end
  end

end