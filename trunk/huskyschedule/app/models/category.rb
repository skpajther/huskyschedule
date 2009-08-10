class Category < ActiveRecord::Base
  has_and_belongs_to_many :children,
          :class_name => 'Category',
          :join_table => 'category_edges',
          :foreign_key => 'parent_id',
          :association_foreign_key => 'child_id'
  
  has_and_belongs_to_many :parents,
      :class_name => 'Category',
      :join_table => 'category_edges',
      :foreign_key => 'child_id',
      :association_foreign_key => 'parent_id'
     
  #has_many :children, :class_name => "Category", :foreign_key => "parent_id"
  #belongs_to :parent, :class_name => "Category", :foreign_key => "parent_id"
  
  DESCRIPTION_URL = "http://www.washington.edu/students/crscat/"
  HOME_ID = 1
  
  def all_children
    ret = []
    for child in self.children
      ret.push(child)
      ret = ret + child.all_children
    end
    return ret
  end
  
  def all_children_query_string
    st = ""
    if(self.children.size > 0)
      st = ","
    end
    return "courses.parent_id IN (#{self.id}#{st}#{self.all_children.map{|child| child.id }.inspect.delete!('[]')})"
  end
  
  def parent_path
    curr = self
    familypath = []
    familypath.push(curr)
    
    while curr.parent!=nil
      familypath.push(curr.parent)
      curr = curr.parent
    end
    
    return familypath
  end
  
  def self.create_all_categories
    Category.delete_all
    sql = ActiveRecord::Base.connection();
    sql.execute("DELETE FROM category_edges");
    
    home = Category.create(:id=>HOME_ID, :name=>"Home")
    
    #Undergraduate Interdisciplinary Programs
    college = Category.create(:name=>"Undergraduate Interdisciplinary Programs", :parents=>[home])
    category = Category.create(:name=>"Honors", :abbrev=>"HONORS", :parents=>[college])
    category = Category.create(:name=>"Program on the Environment", :abbrev=>"ENVIR", :parents=>[college], :url=>"envst.html")
    category = Category.create(:name=>"University Academy", :abbrev=>"ACADEM", :parents=>[college], :url=>"academ.html")
    category = Category.create(:name=>"Quantitative Science (Fisheries and Forest Resources)", :abbrev=>"Q SCI", :parents=>[college], :url=>"quantsci.html")
    
    #Arts & Sciences
    college = Category.create(:name=>"College of Arts and Science", :parents=>[home])
    top_category = Category.create(:name=>"American Ethnic Studies", :parents=>[college])
    Category.create(:name=>"Afro-American Studies", :parents=>[top_category], :url=>"afamst.html")
    Category.create(:name=>"American Ethnic Studies", :parents=>[top_category], :abbrev=>"AES", :url=>"aes.html")
    Category.create(:name=>"Asian-American Studies", :parents=>[top_category], :abbrev=>"AAS", :url=>"asamst.html")
    Category.create(:name=>"Chicano Studies", :parents=>[top_category], :abbrev=>"CHSTU", :url=>"chist.html")
    Category.create(:name=>"Swahili", :parents=>[top_category], :abbrev=>"SWA", :url=>"swa.html")
    Category.create(:name=>"Tagalog", :parents=>[top_category], :abbrev=>"TAGLG", :url=>"taglg.html")
    Category.create(:name=>"American Indian Studies", :abbrev=>"AIS", :parents=>[college], :url=>"ais.html")
    top_category = Category.create(:name=>"Anthropology", :parents=>[college])
    Category.create(:name=>"Anthropology", :abbrev=>"ANTH", :parents=>[top_category], :url=>"anthro.html")
    Category.create(:name=>"Archaeology", :abbrev=>"ARCHY", :parents=>[top_category], :url=>"archeo.html")
    Category.create(:name=>"Biocultural Anthropology", :abbrev=>"BIO A", :parents=>[top_category], :url=>"bioanth.html")
    Category.create(:name=>"Applied Mathematics", :abbrev=>"AMATH", :parents=>[college], :url=>"appmath.html")
    Category.create(:name=>"Art", :abbrev=>"ART", :parents=>[college], :url=>"art.html")
    Category.create(:name=>"Art History", :abbrev=>"ART H", :parents=>[college], :url=>"arthis.html")
    top_category = Category.create(:name=>"Asian Languages and Literature", :parents=>[college])
    Category.create(:name=>"Asian Languages and Literature", :parents=>[top_category], :abbrev=>"ASIAN", :url=>"asianll.html")
    Category.create(:name=>"Bengali", :parents=>[top_category], :abbrev=>"BENG", :url=>"beng.html")
    Category.create(:name=>"Chinese", :parents=>[top_category], :abbrev=>"CHIN", :url=>"chinese.html")
    Category.create(:name=>"Hindi", :parents=>[top_category], :abbrev=>"HINDI", :url=>"hindi.html")
    Category.create(:name=>"Indian", :parents=>[top_category], :abbrev=>"INDN", :url=>"indian.html")
    Category.create(:name=>"Indonesian", :parents=>[top_category], :abbrev=>"INDON", :url=>"indones.html")
    Category.create(:name=>"Japanese", :parents=>[top_category], :abbrev=>"JAPAN", :url=>"japanese.html")
    Category.create(:name=>"Korean", :parents=>[top_category], :abbrev=>"KOREAN", :url=>"korean.html")
    Category.create(:name=>"Sanskrit", :parents=>[top_category], :abbrev=>"SNKRT", :url=>"sanskrit.html")
#    Category.create(:name=>"Tagalog", :parents=>[top_category], :abbrev=>"TAGLG", :url=>"asamst.html") #special
#    Category.create(:name=>"Tamil", :parents=>[top_category], :abbrev=>"TAMIL", :url=>"tamil.html")
    Category.create(:name=>"Thai", :parents=>[top_category], :abbrev=>"THAI", :url=>"thai.html")
#    Category.create(:name=>"Tibetan", :parents=>[top_category], :abbrev=>"TIB", :url=>"tibetan.html")
    Category.create(:name=>"Urdu", :parents=>[top_category], :abbrev=>"URDU", :url=>"urdu.html")
    Category.create(:name=>"Vietnamese", :parents=>[top_category], :abbrev=>"VIET", :url=>"viet.html")
    Category.create(:name=>"Astronomy", :abbrev=>"ASTR", :url=>"astro.html", :parents=>[college])
    Category.create(:name=>"Astrobiology", :abbrev=>"ASTBIO", :url=>"astbio.html", :parents=>[college])
    Category.create(:name=>"Atmospheric Sciences", :abbrev=>"ATM S", :url=>"atmos.html", :parents=>[college])
    Category.create(:name=>"Biology", :abbrev=>"BIOL", :url=>"biology.html", :parents=>[college])
    Category.create(:name=>"Center for Statistics and Social Sciences", :abbrev=>"CS&SS", :url=>"cs&ss.html", :parents=>[college])
    Category.create(:name=>"Center for Studies in Demography and Ecology", :abbrev=>"CSDE", :url=>"csde.html", :parents=>[college])
    Category.create(:name=>"Center for the Humanities", :abbrev=>"HUM", :url=>"centhum.html", :parents=>[college])
    Category.create(:name=>"Chemistry", :abbrev=>"CHEM", :url=>"chem.html", :parents=>[college])
    top_category = Category.create(:name=>"Classics", :parents=>[college])
    Category.create(:name=>"Classical Archaeology", :abbrev=>"CL AR", :url=>"clarch.html", :parents=>[top_category])
    Category.create(:name=>"Classical Linguistics", :abbrev=>"CL LI", :url=>"cling.html", :parents=>[top_category])
    Category.create(:name=>"Classics", :abbrev=>"CLAS", :url=>"clas.html", :parents=>[top_category])
    Category.create(:name=>"Greek", :abbrev=>"GREEK", :url=>"greek.html", :parents=>[top_category])
    Category.create(:name=>"Latin", :abbrev=>"LATIN", :url=>"latin.html", :parents=>[top_category])
    Category.create(:name=>"Communication", :abbrev=>"COM", :url=>"com.html", :parents=>[college])
    Category.create(:name=>"Comparative History of Ideas", :abbrev=>"CHID", :url=>"chid.html", :parents=>[college])
    Category.create(:name=>"Comparative Literature", :abbrev=>"C LIT", :url=>"complit.html", :parents=>[college])
    Category.create(:name=>"Computer Science", :abbrev=>"CSE", :url=>"cse.html", :parents=>[college]) #special
    Category.create(:name=>"Dance", :abbrev=>"DANCE", :url=>"dance.html", :parents=>[college])
    Category.create(:name=>"Digital Arts and Experimental Media", :abbrev=>"DXARTS", :url=>"dxarts.html", :parents=>[college])
    Category.create(:name=>"Drama", :abbrev=>"DRAMA", :url=>"drama.html", :parents=>[college])
    Category.create(:name=>"Earth and Space Sciences", :abbrev=>"ESS", :url=>"ess.html", :parents=>[college])
    Category.create(:name=>"Economics", :abbrev=>"ECON", :url=>"econ.html", :parents=>[college])
    Category.create(:name=>"English", :abbrev=>"ENGL", :url=>"engl.html", :parents=>[college])
    top_category = Category.create(:name=>"General Studies", :parents=>[college])
    Category.create(:name=>"General Interdisciplinary Studies", :abbrev=>"GIS", :url=>"gis.html", :parents=>[top_category])
    Category.create(:name=>"General Studies", :abbrev=>"GEN ST", :url=>"genst.html", :parents=>[top_category])
    Category.create(:name=>"Individualized Studies", :abbrev=>"INDIV", :url=>"indiv.html", :parents=>[top_category])
    Category.create(:name=>"Genetics", :abbrev=>"GENOME", :url=>"genome.html", :parents=>[college]) #special
    Category.create(:name=>"Geography", :abbrev=>"GEOG", :url=>"geog.html", :parents=>[college])
    Category.create(:name=>"Germanics", :abbrev=>"GERMAN", :url=>"germ.html", :parents=>[college])
    top_category = Category.create(:name=>"History", :parents=>[college])
    Category.create(:name=>"Ancient and Medieval History", :abbrev=>"HSTAM", :url=>"ancmedh.html", :parents=>[top_category])
    Category.create(:name=>"History", :abbrev=>"HIST", :url=>"hist.html", :parents=>[top_category])
    Category.create(:name=>"History of Asia", :abbrev=>"HSTAS", :url=>"histasia.html", :parents=>[top_category])
    Category.create(:name=>"History of the Americas", :abbrev=>"HSTAA", :url=>"histam.html", :parents=>[top_category])
    Category.create(:name=>"Modern European History", :abbrev=>"HSTEU", :url=>"modeuro.html", :parents=>[top_category])
    Category.create(:name=>"History and Philosophy of Science", :abbrev=>"HPS", :url=>"hps.html", :parents=>[top_category])
#    Category.create(:name=>"Honors", :abbrev=>"HONORS", :url=>"hnrs.html", :parents=>[college])
    Category.find_by_abbrev("HONORS").parents.push(college)
    Category.create(:name=>"Humanities -- Center for the Humanities", :abbrev=>"HUM", :url=>"centhum.html", :parents=>[college])
    top_category = Category.create(:name=>"Jackson School of International Studies", :parents=>[college])
    Category.create(:name=>"European Studies", :abbrev=>"EURO", :url=>"euro.html", :parents=>[top_category])
    Category.create(:name=>"International Studies", :abbrev=>"SIS", :url=>"intl.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (African Studies)", :abbrev=>"SISAF", :url=>"intlafr.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (Asian Studies)", :abbrev=>"SISA", :url=>"intlasian.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (Canadian Studies)", :abbrev=>"SISCA", :url=>"intlcan.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (Comparative Religion)", :abbrev=>"RELIG", :url=>"religion.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (East Asian Studies)", :abbrev=>"SISEA", :url=>"intleas.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (Jewish Studies)", :abbrev=>"SISJE", :url=>"intljewish.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (Latin American Studies)", :abbrev=>"SISLA", :url=>"intllatam.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (Middle Eastern Studies)", :abbrev=>"SISME", :url=>"intlmide.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (Russian, East European, and Central Asian Studies)", :abbrev=>"SISRE", :url=>"russeeuca.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (South Asian Studies)", :abbrev=>"SISSA", :url=>"intlsoa.html", :parents=>[top_category])
    Category.create(:name=>"International Studies (Southeast Asian Studies)", :abbrev=>"SISSE", :url=>"intlsea.html", :parents=>[top_category])
    Category.create(:name=>"Law, Societies, and Justice", :abbrev=>"LSJ", :url=>"lsj.html", :parents=>[college])
    top_category = Category.create(:name=>"Linguistics", :parents=>[college])
    Category.create(:name=>"American Sign Language", :abbrev=>"ASL", :url=>"asl.html", :parents=>[top_category])
    Category.create(:name=>"Frensh Linguistics", :abbrev=>"FRLING", :url=>"frling.html", :parents=>[top_category])
    Category.create(:name=>"Linguistics", :abbrev=>"LING", :url=>"ling.html", :parents=>[top_category])
    Category.create(:name=>"Romance Linguistics", :abbrev=>"ROLING", :url=>"romling.html", :parents=>[top_category])
    Category.create(:name=>"Spanish Linguistics", :abbrev=>"SPLING", :url=>"spanlin.html", :parents=>[top_category])
    Category.create(:name=>"Mathematics", :abbrev=>"MATH", :url=>"math.html", :parents=>[college])
    top_category = Category.create(:name=>"Music", :parents=>[college])
    Category.create(:name=>"Music", :abbrev=>"MUSIC", :url=>"music.html", :parents=>[top_category])
    Category.create(:name=>"Music - Applied", :abbrev=>"MUSAP", :url=>"appmus.html", :parents=>[top_category])
    Category.create(:name=>"Music Education", :abbrev=>"MUSED", :url=>"mused.html", :parents=>[top_category])
    Category.create(:name=>"Music Ensemble", :abbrev=>"MUSEN", :url=>"musensem.html", :parents=>[top_category])
    Category.create(:name=>"Music History", :abbrev=>"MUHST", :url=>"mushist.html", :parents=>[top_category])
    top_category = Category.create(:name=>"Near Eastern Languages and Civilization", :parents=>[college])
    Category.create(:name=>"Akkadian", :abbrev=>"AKKAD", :url=>"akkad.html", :parents=>[top_category])
    Category.create(:name=>"Arabic", :abbrev=>"ARAB", :url=>"arabic.html", :parents=>[top_category])
    Category.create(:name=>"Aramaic", :abbrev=>"ARAMIC", :url=>"aramic.html", :parents=>[top_category])
    Category.create(:name=>"Egyptian", :abbrev=>"EGYPT", :url=>"egypt.html", :parents=>[top_category])
    Category.create(:name=>"Hebrew", :abbrev=>"HEBR", :url=>"hebrew.html", :parents=>[top_category])
    Category.create(:name=>"Near Eastern Languages and Civilization", :abbrev=>"NEAR E", :url=>"neareast.html", :parents=>[top_category])
    Category.create(:name=>"Persian", :abbrev=>"PRSAN", :url=>"persian.html", :parents=>[top_category])
    Category.create(:name=>"Turkic", :abbrev=>"TKIC", :url=>"turkic.html", :parents=>[top_category])
    Category.create(:name=>"Turkish", :abbrev=>"TKISH", :url=>"turkish.html", :parents=>[top_category])
    Category.create(:name=>"Ugaritic", :abbrev=>"UGARIT", :url=>"ugarit.html", :parents=>[top_category])
    Category.create(:name=>"Neurobiology", :abbrev=>"NBIO", :url=>"nbio.html", :parents=>[college])
    top_category = Category.create(:name=>"Philosophy", :parents=>[college])
#    Category.create(:name=>"History and Philosophy of Science", :abbrev=>"HPS", :url=>"hps.html", :parents=>[top_category])
    Category.find_by_abbrev("HPS").parents.push(top_category)
    Category.create(:name=>"Philosophy", :abbrev=>"PHIL", :url=>"phil.html", :parents=>[top_category])
    Category.create(:name=>"Values in Society", :abbrev=>"VALUES", :url=>"values.html", :parents=>[top_category])
    Category.create(:name=>"Physics", :abbrev=>"PHYS", :url=>"phys.html", :parents=>[college])
    Category.create(:name=>"Political Science", :abbrev=>"POL S", :url=>"polisci.html", :parents=>[college])
    Category.create(:name=>"Psychology", :abbrev=>"PSYCH", :url=>"psych.html", :parents=>[college])
#    Category.create(:name=>"Quantitative Science", :abbrev=>"Q SCI", :url=>"quantsci.html", :parents=>[college]) #special
    Category.find_by_abbrev("Q SCI").parents.push(college)
    top_category = Category.create(:name=>"Romance Languages and Literature", :parents=>[college])
    Category.create(:name=>"French", :abbrev=>"FRENCH", :url=>"french.html", :parents=>[top_category])
    Category.create(:name=>"Italian", :abbrev=>"ITAL", :url=>"italian.html", :parents=>[top_category])
    Category.create(:name=>"Portugese", :abbrev=>"PORT", :url=>"port.html", :parents=>[top_category])
    Category.create(:name=>"Romance Languages and Literature", :abbrev=>"ROMAN", :url=>"romance.html", :parents=>[top_category])
#    Category.create(:name=>"Romance Linguistics", :abbrev=>"ROLING", :url=>"romling.html", :parents=>[top_category])
    Category.find_by_abbrev("ROLING").parents.push(top_category)
    Category.create(:name=>"Romanian (Romance)", :abbrev=>"RMN", :url=>"romanianr.html", :parents=>[top_category])
    Category.create(:name=>"Spanish", :abbrev=>"SPAN", :url=>"spanish.html", :parents=>[top_category])
    top_category = Category.create(:name=>"Scandinavian Languages and Literature", :parents=>[college])
    Category.create(:name=>"Danish", :abbrev=>"DANISH", :url=>"danish.html", :parents=>[top_category])
    Category.create(:name=>"Estonian", :abbrev=>"ESTO", :url=>"eston.html", :parents=>[top_category])
    Category.create(:name=>"Finnish", :abbrev=>"FINN", :url=>"finnish.html", :parents=>[top_category])
    Category.create(:name=>"Latvian", :abbrev=>"LATV", :url=>"latvian.html", :parents=>[top_category])
    Category.create(:name=>"Lithuanian", :abbrev=>"LITH", :url=>"lith.html", :parents=>[top_category])
    Category.create(:name=>"Norwegian", :abbrev=>"NORW", :url=>"norweg.html", :parents=>[top_category])
    Category.create(:name=>"Scandinavian", :abbrev=>"SCAND", :url=>"scand.html", :parents=>[top_category])
    Category.create(:name=>"Swedish", :abbrev=>"SWED", :url=>"swedish.html", :parents=>[top_category])
    top_category = Category.create(:name=>"Slavic Languages and Literature", :parents=>[college])
    Category.create(:name=>"Bosnian/Croatian/Serbian", :abbrev=>"BCS", :url=>"bcs.html", :parents=>[top_category])
    Category.create(:name=>"Bulgarian", :abbrev=>"BULGR", :url=>"bulgar.html", :parents=>[top_category])
    Category.create(:name=>"Czech", :abbrev=>"CZECH", :url=>"czech.html", :parents=>[top_category])
    Category.create(:name=>"Georgian", :abbrev=>"GEORG", :url=>"georg.html", :parents=>[top_category])
    Category.create(:name=>"Polish", :abbrev=>"POLSH", :url=>"polish.html", :parents=>[top_category])
    Category.create(:name=>"Romanian (Slavic)", :abbrev=>"ROMN", :url=>"romanian.html", :parents=>[top_category])
    Category.create(:name=>"Russian", :abbrev=>"RUSS", :url=>"russian.html", :parents=>[top_category])
    Category.create(:name=>"Slavic", :abbrev=>"SLAV", :url=>"slavic.html", :parents=>[top_category])
    Category.create(:name=>"Slavic Languages and Literature", :abbrev=>"SLAVIC", :url=>"slav.html", :parents=>[top_category])
    Category.create(:name=>"Slovenian", :abbrev=>"SLVN", :url=>"slvn.html", :parents=>[top_category])
    Category.create(:name=>"Ukranian", :abbrev=>"UKR", :url=>"ukrain.html", :parents=>[top_category])
    Category.create(:name=>"Social Sciences", :abbrev=>"SOCSCI", :url=>"socsci.html", :parents=>[college])
    Category.create(:name=>"Sociology", :abbrev=>"SOC", :url=>"soc.html", :parents=>[college])
    Category.create(:name=>"Speech and Hearing Sciences", :abbrev=>"SPHSC", :url=>"sphsc.html", :parents=>[college])
    Category.create(:name=>"Statistics", :abbrev=>"STAT", :url=>"stat.html", :parents=>[college])
    Category.create(:name=>"Summer Arts Festival", :abbrev=>"ARTS", :url=>"arts.html", :parents=>[college])
    Category.create(:name=>"Women Studies", :abbrev=>"WOMEN", :url=>"women.html", :parents=>[college])
    
    #College of Built Environments
    college = Category.create(:name=>"College of Built Environments", :parents=>[home])
    Category.create(:name=>"Architecture", :abbrev=>"ARCH", :url=>"archit.html", :parents=>[college])
    Category.create(:name=>"Built Environment", :abbrev=>"B E", :url=>"be.html", :parents=>[college])
    Category.create(:name=>"Construction Management", :abbrev=>"CM", :url=>"constmgmt.html", :parents=>[college])
    Category.create(:name=>"Landscape Architecture", :abbrev=>"L ARCH", :url=>"landscape.html", :parents=>[college])
    top_category = Category.create(:name=>"Urban Planning", :parents=>[college])
    Category.create(:name=>"Community and Environmental Planning", :abbrev=>"CEP", :url=>"commenv.html", :parents=>[top_category])
    Category.create(:name=>"Strategic Planning for Critical Infrastructure", :abbrev=>"SPCI", :url=>"spci.html", :parents=>[top_category])
    Category.create(:name=>"Urban Planning", :abbrev=>"URBDP", :url=>"urbdes.html", :parents=>[top_category])
    
    #Business School
    college = Category.create(:name=>"Business School", :parents=>[home])
    Category.create(:name=>"Accounting", :abbrev=>"ACCTG", :url=>"acctg.html", :parents=>[college])
    top_category = Category.create(:name=>"Business Administration", :parents=>[college])
    Category.create(:name=>"Administration", :abbrev=>"ADMIN", :url=>"admin.html", :parents=>[top_category])
    Category.create(:name=>"Business Administration", :abbrev=>"B A", :url=>"ba.html", :parents=>[top_category])
    Category.create(:name=>"Business Administration Research Methods", :abbrev=>"BA RM", :url=>"barm.html", :parents=>[top_category])
    Category.create(:name=>"Business Communications", :abbrev=>"B CMU", :url=>"buscomm.html", :parents=>[top_category])
    Category.create(:name=>"Business Economics", :abbrev=>"B ECON", :url=>"busecon.html", :parents=>[top_category])
    Category.create(:name=>"Business Policy", :abbrev=>"B POL", :url=>"bpol.html", :parents=>[top_category])
    Category.create(:name=>"E-Business", :abbrev=>"EBIZ", :url=>"ebiz.html", :parents=>[top_category])
    Category.create(:name=>"Entrepreneurship", :abbrev=>"ENTRE", :url=>"entre.html", :parents=>[top_category])
    Category.create(:name=>"Finance", :abbrev=>"FIN", :url=>"finance.html", :parents=>[top_category])
    Category.create(:name=>"Human Resources Management and Organizational Behavior", :abbrev=>"HRMOB", :url=>"hrmob.html", :parents=>[top_category])
    Category.create(:name=>"Informational Systems", :abbrev=>"I S", :url=>"infosys.html", :parents=>[top_category])
    Category.create(:name=>"International Business", :abbrev=>"I BUS", :url=>"intlbus.html", :parents=>[top_category])
    Category.create(:name=>"Management", :abbrev=>"MGMT", :url=>"mgmt.html", :parents=>[top_category])
    Category.create(:name=>"Marketing", :abbrev=>"MKTG", :url=>"mktg.html", :parents=>[top_category])
    Category.create(:name=>"Operations Management", :abbrev=>"OPMGT", :url=>"opmgmt.html", :parents=>[top_category])
    Category.create(:name=>"Organization and Environment", :abbrev=>"O E", :url=>"orgenv.html", :parents=>[top_category])
    Category.create(:name=>"Quantitative Methods", :abbrev=>"QMETH", :url=>"qmeth.html", :parents=>[top_category])
    Category.create(:name=>"Strategic Management", :abbrev=>"ST MGT", :url=>"stratm.html", :parents=>[top_category])
    
    #School of Dentistry
    college = Category.create(:name=>"School of Dentistry", :parents=>[home])
    Category.create(:name=>"Dental Hygiene", :abbrev=>"D HYG", :url=>"denthy.html", :parents=>[college])
    Category.create(:name=>"Dental Public Health Sciences", :abbrev=>"DPHS", :url=>"dphs.html", :parents=>[college])
    Category.create(:name=>"Dentistry", :abbrev=>"DENT", :url=>"dent.html", :parents=>[college])
    Category.create(:name=>"Endodontics", :abbrev=>"ENDO", :url=>"endo.html", :parents=>[college])
    Category.create(:name=>"Oral Biology", :abbrev=>"ORALB", :url=>"oralbio.html", :parents=>[college])
    Category.create(:name=>"Oral Medicine", :abbrev=>"ORALM", :url=>"oralm.html", :parents=>[college])
    Category.create(:name=>"Oral Surgery", :abbrev=>"O S", :url=>"os.html", :parents=>[college])
    Category.create(:name=>"Orthodontics", :abbrev=>"ORTHO", :url=>"orthod.html", :parents=>[college])
    Category.create(:name=>"Pediatric Dentistry", :abbrev=>"PEDO", :url=>"pedodon.html", :parents=>[college])
    Category.create(:name=>"Periodontics", :abbrev=>"PERIO", :url=>"perio.html", :parents=>[college])
    Category.create(:name=>"Prosthodontics", :abbrev=>"PROS", :url=>"pros.html", :parents=>[college])
    Category.create(:name=>"Restorative Dentistry", :abbrev=>"RES D", :url=>"restor.html", :parents=>[college])
    
    #College of Education
    college = Category.create(:name=>"College of Education", :parents=>[home])
    Category.create(:name=>"Curriculum and Instruction", :abbrev=>"EDC&I", :url=>"edci.html", :parents=>[college])
    Category.create(:name=>"College of Education", :abbrev=>"EDUC", :url=>"indsrf.html", :parents=>[college])
    Category.create(:name=>"Early Childhood and Family Studies", :abbrev=>"ECFS", :url=>"ecfs.html", :parents=>[college])
    Category.create(:name=>"Education (Teacher Education Program)", :abbrev=>"EDTEP", :url=>"teached.html", :parents=>[college])
    Category.create(:name=>"Educational Leadership and Policy Studies", :abbrev=>"EDLPS", :url=>"edlp.html", :parents=>[college])
    Category.create(:name=>"Educational Psychology", :abbrev=>"EDPSY", :url=>"edpsy.html", :parents=>[college])
    Category.create(:name=>"Special Education", :abbrev=>"EDSPE", :url=>"sped.html", :parents=>[college])
    
    #College of Engineering
    college = Category.create(:name=>"College of Engineering", :parents=>[home])
    Category.create(:name=>"Aeronautics and Astronautics", :abbrev=>"A A", :url=>"aa.html", :parents=>[college])
    Category.create(:name=>"Chemical Engineering", :abbrev=>"CHEM E", :url=>"cheng.html", :parents=>[college])
    Category.create(:name=>"Civil and Environmental Engineering", :abbrev=>"CEE", :url=>"cee.html", :parents=>[college])
#    Category.create(:name=>"Computer Science and Engineering", :abbrev=>"CSE", :url=>"cse.html", :parents=>[college])
    Category.find_by_abbrev("CSE").parents.push(college)
    Category.create(:name=>"Electrical Engineering", :abbrev=>"E E", :url=>"ee.html", :parents=>[college])
    Category.create(:name=>"Engineering", :abbrev=>"ENGR", :url=>"engr.html", :parents=>[college])
    Category.create(:name=>"Human Centered Design and Engineering", :abbrev=>"HCDE", :parents=>[college], :url=>"hcde.html")
    Category.create(:name=>"Industrial Engineering", :abbrev=>"IND E", :url=>"inde.html", :parents=>[college])
    Category.create(:name=>"Materials Science and Engineering", :abbrev=>"MS E", :url=>"mse.html", :parents=>[college])
    top_category = Category.create(:name=>"Mechanical Engineering", :parents=>[college])
    Category.create(:name=>"Mechanical Engineering", :abbrev=>"M E", :url=>"meche.html", :parents=>[top_category])
    Category.create(:name=>"Mechanical Engineering Industrial Engineering", :abbrev=>"MEIE", :url=>"meie.html", :parents=>[top_category])
    
    #College of the Environment
    college = Category.create(:name=>"College of the Environment", :parents=>[home])
#    Category.create(:name=>"Atmospheric Sciences", :abbrev=>"ATM S", :url=>"atmos.html", :parents=>[college])
    Category.find_by_abbrev("ATM S").parents.push(college)
    Category.find_by_abbrev("ESS").parents.push(college)
    Category.find_by_abbrev("ENVIR").parents.push(college)
    top_category = Category.create(:name=>"School of Forest Resources", :parents=>[college])
    Category.create(:name=>"Environmental Science and Resource Management", :abbrev=>"ESRM", :url=>"esrm.html", :parents=>[top_category])
    Category.create(:name=>"Paper Science and Engineering", :abbrev=>"PSE", :url=>"paper.html", :parents=>[top_category])
    Category.create(:name=>"School of Forest Resources", :abbrev=>"CFR", :url=>"forr.html", :parents=>[top_category])
    Category.create(:name=>"School of Marine Affairs", :abbrev=>"SMA", :url=>"marine.html", :parents=>[college])
    Category.create(:name=>"Quaternary Sciences", :abbrev=>"QUAT", :url=>"qrc.html", :parents=>[college])
    
    #The Information School
    college = Category.create(:name=>"The Information School", :parents=>[home])
    Category.create(:name=>"Informatics", :abbrev=>"INFO", :url=>"info.html", :parents=>[college])
    Category.create(:name=>"Information School Interdisciplinary", :abbrev=>"INFX", :url=>"infx.html", :parents=>[college])
    Category.create(:name=>"Information Science", :abbrev=>"INSC", :url=>"insc.html", :parents=>[college])
    Category.create(:name=>"Information Management", :abbrev=>"IMT", :url=>"95imt.html", :parents=>[college])
    Category.create(:name=>"Library and Information Science", :abbrev=>"LIS", :url=>"lis.html", :parents=>[college])
    
    #Interdisciplinary Graduate Programs
    college = Category.create(:name=>"Interdisciplinary Graduate Programs", :parents=>[home])
    Category.create(:name=>"Biomolecular Structure and Design", :abbrev=>"BMSD", :url=>"bmsd.html", :parents=>[college])
    Category.create(:name=>"Graduate School", :abbrev=>"GRDSCH", :url=>"grad.html", :parents=>[college])
    Category.create(:name=>"Global Trade, Transportation & Logistics", :abbrev=>"GTTL", :url=>"gttl.html", :parents=>[college])
    Category.create(:name=>"Individual PhD", :abbrev=>"IPHD", :url=>"iphd.html", :parents=>[college])
    Category.create(:name=>"Molecular and Cellular Biology", :abbrev=>"MCB", :url=>"mcb.html", :parents=>[college])
    Category.create(:name=>"Museology", :abbrev=>"MUSEUM", :url=>"museo.html", :parents=>[college])
    Category.create(:name=>"Near and Middle Eastern Studies", :abbrev=>"N&MES", :url=>"nearmide.html", :parents=>[college])
    Category.create(:name=>"Neurobiology and Behavior", :abbrev=>"NEUBEH", :url=>"neurobio.html", :parents=>[college])
    Category.create(:name=>"Nutritional Science", :abbrev=>"NUTR", :url=>"nutrit.html", :parents=>[college])
#    Category.create(:name=>"Program on the Environment", :abbrev=>"ENVIR", :url=>"envst.html", :parents=>[college])
    Category.find_by_abbrev("ENVIR").parents.push(college)
    Category.create(:name=>"Quantitative Ecology and Resource Management", :abbrev=>"QERM", :url=>"quante.html", :parents=>[college])
#    Category.create(:name=>"Quaternary Science", :abbrev=>"QUAT", :url=>"qrc.html", :parents=>[college])
    Category.find_by_abbrev("QUAT").parents.push(college)
    
    #Interschool or Intercollege Programs
    college = Category.create(:name=>"Interschool or Intercollege Programs", :parents=>[home])
    Category.create(:name=>"Bioengineering", :abbrev=>"BIOEN", :url=>"bioeng.html", :parents=>[college])
    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"gh.html", :parents=>[college])
    Category.create(:name=>"University Conjoint Courses", :abbrev=>"UCONJ", :url=>"uconjoint.html", :parents=>[college])
    
    #School of Law
    college = Category.create(:name=>"School of Law", :parents=>[home])
    Category.create(:name=>"Health Law", :abbrev=>"LAW H", :url=>"lawh.html", :parents=>[college])
    Category.create(:name=>"Intellectual Property Law", :abbrev=>"LAW P", :url=>"lawp.html", :parents=>[college])
    Category.create(:name=>"Law", :abbrev=>"LAW", :url=>"law.html", :parents=>[college])
    Category.create(:name=>"Law (Taxation)", :abbrev=>"LAW T", :url=>"lawt.html", :parents=>[college])
    Category.create(:name=>"Law A", :abbrev=>"LAW A", :url=>"lawa.html", :parents=>[college])
    Category.create(:name=>"Law B", :abbrev=>"LAW B", :url=>"lawb.html", :parents=>[college])
    Category.create(:name=>"Law E", :abbrev=>"LAW E", :url=>"lawe.html", :parents=>[college])
    
    #School of Medicine
    college = Category.create(:name=>"School of Medicine", :parents=>[home])
    Category.create(:name=>"Anesthesiology", :abbrev=>"ANEST", :url=>"anest.html", :parents=>[college])
    Category.create(:name=>"Biochemistry", :abbrev=>"BIOC", :url=>"bioch.html", :parents=>[college])
#    Category.create(:name=>"Bioengineering", :abbrev=>"BIOEN", :url=>"bioeng.html", :parents=>[college])
    Category.find_by_abbrev("BIOEN").parents.push(college)
    Category.create(:name=>"Biological Structure", :abbrev=>"B STR", :url=>"biostruct.html", :parents=>[college])
    Category.create(:name=>"Comparative Medicine", :abbrev=>"C MED", :url=>"compmed.html", :parents=>[college])
    Category.create(:name=>"Conjoint Courses", :abbrev=>"CONJ", :url=>"conj.html", :parents=>[college])
    Category.create(:name=>"Family Medicine", :abbrev=>"FAMED", :url=>"famed.html", :parents=>[college])
#    Category.create(:name=>"Genome Sciences", :abbrev=>"GENOME", :url=>"genome.html", :parents=>[college])
    Category.find_by_abbrev("GENOME").parents.push(college)
#    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"gh.html", :parents=>[college])
    Category.find_by_abbrev("G H").parents.push(college)
    Category.create(:name=>"Human Biology", :abbrev=>"HUBIO", :url=>"humbio.html", :parents=>[college])
    Category.create(:name=>"Immunology", :abbrev=>"IMMUN", :url=>"immun.html", :parents=>[college])
    Category.create(:name=>"Laboratory Medicine", :abbrev=>"LAB M", :url=>"law.html", :parents=>[college])
    Category.create(:name=>"MEDEX Program", :abbrev=>"MEDEX", :url=>"93medex.html", :parents=>[college])
    Category.create(:name=>"Medical Education and Biomedical Informatics", :abbrev=>"MEBI", :url=>"law.html", :parents=>[college])
#    top_category = Category.create(:name=>"Medical History and Ethics", :parents=>[college])
#    Category.create(:name=>"Bioethics and Humanities", :abbrev=>"B H", :url=>"bh.html", :parents=>[top_category])
#    Category.create(:name=>"Medical History and Ethics", :abbrev=>"MHE", :url=>"medhist.html", :parents=>[top_category])
    top_category = Category.create(:name=>"Medicine", :parents=>[college])
    Category.create(:name=>"Emergency Medicine", :abbrev=>"MED ER", :url=>"meder.html", :parents=>[top_category])
    Category.create(:name=>"Medicine", :abbrev=>"MED", :url=>"medicine.html", :parents=>[top_category])
    Category.create(:name=>"Medicine Elective Clerkships", :abbrev=>"MEDECK", :url=>"admin.html", :parents=>[top_category])
    Category.create(:name=>"Medicine Required Clerkships", :abbrev=>"MEDRCK", :url=>"admin.html", :parents=>[top_category])
    Category.create(:name=>"Microbiology", :abbrev=>"MICROM", :url=>"microbio.html", :parents=>[college])
    Category.create(:name=>"Molecular Medicine", :abbrev=>"MOLMED", :url=>"molmed.html", :parents=>[college])
    Category.create(:name=>"Neurological Surgery", :abbrev=>"NEUR S", :url=>"neurosurg.html", :parents=>[college])
    Category.create(:name=>"Neurology", :abbrev=>"NEURL", :url=>"neurl.html", :parents=>[college])
    Category.create(:name=>"Obstetrics and Gynecology", :abbrev=>"OB GYN", :url=>"obgyn.html", :parents=>[college])
    Category.create(:name=>"Ophthalmology", :abbrev=>"OPHTH", :url=>"ophthal.html", :parents=>[college])
    Category.create(:name=>"Orthopedics", :abbrev=>"ORTHP", :url=>"orthop.html", :parents=>[college])
    Category.create(:name=>"Otolaryngology -- Head and Neck Surgery", :abbrev=>"OTOHN", :url=>"otol.html", :parents=>[college])
    Category.create(:name=>"Pathology", :abbrev=>"PATH", :url=>"patho.html", :parents=>[college])
    Category.create(:name=>"Pediatrics", :abbrev=>"PEDS", :url=>"pediat.html", :parents=>[college])
    Category.create(:name=>"Pharmacology", :abbrev=>"PHCOL", :url=>"pharma.html", :parents=>[college])
    Category.create(:name=>"Physiology and Biophysics", :abbrev=>"P BIO", :url=>"physiolbio.html", :parents=>[college])
    Category.create(:name=>"Psychiatry and Behavioral Sciences", :abbrev=>"PBSCI", :url=>"psychbehav.html", :parents=>[college])
    Category.create(:name=>"Radiation Oncology", :abbrev=>"R ONC", :url=>"radonc.html", :parents=>[college])
    Category.create(:name=>"Radiology", :abbrev=>"RADGY", :url=>"radiol.html", :parents=>[college])
    Category.create(:name=>"Rehabilitation Medicine", :abbrev=>"REHAB", :url=>"rehab.html", :parents=>[college])
    Category.create(:name=>"Surgery", :abbrev=>"SURG", :url=>"surg.html", :parents=>[college])
    Category.create(:name=>"Urology", :abbrev=>"UROL", :url=>"uro.html", :parents=>[college])
    
    #School of Nursing
    college = Category.create(:name=>"School of Nursing", :parents=>[home])
    Category.create(:name=>"Nursing", :abbrev=>"NSG", :url=>"nsg.html", :parents=>[college])
    Category.create(:name=>"Nursing", :abbrev=>"NURS", :url=>"nursing.html", :parents=>[college])
    Category.create(:name=>"Nursing Clinical", :abbrev=>"NCLIN", :url=>"nursingcl.html", :parents=>[college])
    Category.create(:name=>"Nursing Methods", :abbrev=>"NMETH", :url=>"nursingmeth.html", :parents=>[college])
    
    #College of Ocean and Fishery Sciences
    college = Category.create(:name=>"College of Ocean and Fishery Sciences", :parents=>[home])
    Category.create(:name=>"Aquatic and Fishery Sciences", :abbrev=>"FISH", :url=>"fish.html", :parents=>[college])
#    Category.create(:name=>"School of Marine Affairs", :abbrev=>"SMA", :url=>"marine.html", :parents=>[college])
    Category.find_by_abbrev("SMA").parents.push(college)
    Category.create(:name=>"Oceanography", :abbrev=>"OCEAN", :url=>"ocean.html", :parents=>[college])
    
    #School of Pharmacy
    college = Category.create(:name=>"School of Pharmacy", :parents=>[home])
    Category.create(:name=>"Medicinal Chemistry", :abbrev=>"MEDCH", :url=>"medchem.html", :parents=>[college])
    Category.create(:name=>"Pharmaceutics", :abbrev=>"PCEUT", :url=>"pharmceu.html", :parents=>[college])
    Category.create(:name=>"Pharmacy", :abbrev=>"PHARM", :url=>"pharmacy.html", :parents=>[college])
    Category.create(:name=>"Pharmacy Regulatory Affairs", :abbrev=>"PHRMRA", :url=>"phrmra.html", :parents=>[college])
    
    #Evans School of Public Affairs
    college = Category.create(:name=>"Evans School of Public Affairs", :parents=>[home])
    Category.create(:name=>"Public Affairs", :abbrev=>"PB AF", :url=>"pubaff.html", :parents=>[college])
    Category.create(:name=>"Public Policy and Management", :abbrev=>"PPM", :url=>"ppm.html", :parents=>[college])
    
    #School of Public Health
    college = Category.create(:name=>"School of Public Health", :parents=>[home])
    Category.create(:name=>"Biostatistics", :abbrev=>"BIOST", :url=>"biostat.html", :parents=>[college])
    top_category = Category.create(:name=>"Environmental and Occupational Health Sciences", :parents=>[college])
    Category.create(:name=>"Environmental Health", :abbrev=>"ENV H", :url=>"envh.html", :parents=>[top_category])
    top_category = Category.create(:name=>"Epidemiology", :parents=>[college])
    Category.create(:name=>"Epidemiology", :abbrev=>"EPI", :url=>"epidem.html", :parents=>[top_category])
    Category.create(:name=>"Public Health Genetics", :abbrev=>"PHG", :url=>"phg.html", :parents=>[top_category])
#    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"gh.html", :parents=>[college])
    Category.find_by_abbrev("G H").parents.push(college)
    top_category = Category.create(:name=>"Health Services", :parents=>[college])
    Category.create(:name=>"Health Services", :abbrev=>"HSERV", :url=>"hlthsvcs.html", :parents=>[top_category])
    Category.create(:name=>"Health Services Management", :abbrev=>"HSMGMT", :url=>"hsmgmt.html", :parents=>[top_category])
    Category.create(:name=>"Pathobiology", :abbrev=>"PABIO", :url=>"pathobio.html", :parents=>[college])
    
    #Reserve Officers Training Corps Programs
    college = Category.create(:name=>"Reserve Officers Training Corps Programs", :parents=>[home])
    Category.create(:name=>"Aerospace Studies", :abbrev=>"A S", :url=>"88aerosci.html", :parents=>[college])
    Category.create(:name=>"Military Science", :abbrev=>"M SCI", :url=>"88milsci.html", :parents=>[college])
    Category.create(:name=>"Naval Science", :abbrev=>"N SCI", :url=>"88navsci.html", :parents=>[college])
    
    #School of Social Work
    college = Category.create(:name=>"School of Social Work", :parents=>[home])
    Category.create(:name=>"Social Welfare BASW", :abbrev=>"SOC WF", :url=>"socwlbasw.html", :parents=>[college])
    Category.create(:name=>"Social Welfare", :abbrev=>"SOC WL", :url=>"socwl.html", :parents=>[college])
    Category.create(:name=>"Social Work (MSW)", :abbrev=>"SOC W", :url=>"socwk.html", :parents=>[college])
    
    #Extended MPH Degree Program -- excluded
#    college = Category.create(:name=>"Extended MPH Degree Program", :parents=>[home])
#    top_category = Category.create(:name=>"Interschool of Intercollege Programs", :parents=>[college])
#    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"94gh.html", :parents=>[college])
#    top_category = Category.create(:name=>"School of Public Health", :parents=>[college])
#    Category.create(:name=>"Biostatistics", :abbrev=>"BIOST", :url=>"94biostat.html", :parents=>[top_category])
#    Category.create(:name=>"Environmental Health", :abbrev=>"ENV H", :url=>"94envh.html", :parents=>[top_category])
#    Category.create(:name=>"Epidemiology", :abbrev=>"EPI", :url=>"94epidem.html", :parents=>[top_category])
#    Category.create(:name=>"Public Health Genetics", :abbrev=>"PHG", :url=>"94phg.html", :parents=>[top_category])
#    Category.create(:name=>"Health Services", :abbrev=>"HSERV", :url=>"94hlthsvcs.html", :parents=>[top_category])
#    Category.create(:name=>"Health Services Management", :abbrev=>"HSMGMT", :url=>"94hsmgmt.html", :parents=>[top_category])
#    Category.create(:name=>"Nutritional Science", :abbrev=>"NUTR", :url=>"94nutrit.html", :parents=>[top_category])
    
    #Friday Harbor Laboratories -- excluded
#    college = Category.create(:name=>"Friday Harbor Laboratories", :parents=>[home])
#    top_category = Category.create(:name=>"College of Arts and Sciences", :parents=>[college])
#    Category.create(:name=>"Biology", :abbrev=>"BIOL", :url=>"91biology.html", :parents=>[top_category])
#    top_category = Category.create(:name=>"College of Ocean and Fishery Sciences", :parents=>[college])
#    Category.create(:name=>"Aquatic and Fishery Sciences", :abbrev=>"FISH", :url=>"91fish.html", :parents=>[top_category])
#    Category.create(:name=>"School of Marine Affairs", :abbrev=>"SMA", :url=>"91marine.html", :parents=>[top_category])
#    Category.create(:name=>"Oceanography", :abbrev=>"OCEAN", :url=>"91ocean.html", :parents=>[top_category])    
  end
  
end