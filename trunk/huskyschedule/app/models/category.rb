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
    Category.delete_all("name<>'Home'")
    
    #Undergraduate Interdisciplinary Programs
    college = Category.create(:name=>"Undergraduate Interdisciplinary Programs", :parent_id=>HOME_ID)
    category = Category.create(:name=>"University Academy", :abbrev=>"ACADEM", :parent_id=>college.id, :url=>"academ.html")
    category = Category.create(:name=>"Program on the Environment", :abbrev=>"ENVIR", :parent_id=>college.id, :url=>"envst.html")
    category = Category.create(:name=>"Quantitative Science (Fisheries and Forest Resources)", :abbrev=>"Q SCI", :parent_id=>college.id, :url=>"quantsci.html")
    
    #Arts & Sciences
    college = Category.create(:name=>"College of Arts and Science", :parent_id=>HOME_ID)
    top_category = Category.create(:name=>"American Ethnic Studies", :parent_id=>college.id)
    Category.create(:name=>"Afro-American Studies", :parent_id=>top_category.id, :abbrev=>"AFRAM", :url=>"afamst.html")
    Category.create(:name=>"American Ethnic Studies", :parent_id=>top_category.id, :abbrev=>"AES", :url=>"aes.html")
    Category.create(:name=>"Asian-American Studies", :parent_id=>top_category.id, :abbrev=>"AAS", :url=>"asamst.html")
    Category.create(:name=>"Chicano Studies", :parent_id=>top_category.id, :abbrev=>"CHSTU", :url=>"chist.html")
    Category.create(:name=>"American Indian Studies", :abbrev=>"AIS", :parent_id=>college.id, :url=>"ais.html")
    top_category = Category.create(:name=>"Anthropology", :parent_id=>college.id)
    Category.create(:name=>"Anthropology", :abbrev=>"ANTH", :parent_id=>top_category.id, :url=>"anthro.html")
    Category.create(:name=>"Archaeology", :abbrev=>"ARCHY", :parent_id=>top_category.id, :url=>"archeo.html")
    Category.create(:name=>"Biocultural Anthropology", :abbrev=>"BIO A", :parent_id=>top_category.id, :url=>"bioanth.html")
    Category.create(:name=>"Applied Mathematics", :abbrev=>"AMATH", :parent_id=>college.id, :url=>"appmath.html")
    Category.create(:name=>"Art", :abbrev=>"ART", :parent_id=>college.id, :url=>"art.html")
    Category.create(:name=>"Art History", :abbrev=>"ART H", :parent_id=>college.id, :url=>"arthis.html")
    top_category = Category.create(:name=>"Asian Languages and Literature", :parent_id=>college.id)
    Category.create(:name=>"Altai", :parent_id=>top_category.id, :abbrev=>"ALTAI", :url=>"altai.html")
    Category.create(:name=>"Asian Languages and Literature", :parent_id=>top_category.id, :abbrev=>"ASIAN", :url=>"asianll.html")
    Category.create(:name=>"Bengali", :parent_id=>top_category.id, :abbrev=>"BENG", :url=>"beng.html")
    Category.create(:name=>"Chinese", :parent_id=>top_category.id, :abbrev=>"CHIN", :url=>"chinese.html")
    Category.create(:name=>"Hindi", :parent_id=>top_category.id, :abbrev=>"HINDI", :url=>"hindi.html")
    Category.create(:name=>"Indian", :parent_id=>top_category.id, :abbrev=>"INDN", :url=>"indian.html")
    Category.create(:name=>"Indonesian", :parent_id=>top_category.id, :abbrev=>"INDON", :url=>"indones.html")
    Category.create(:name=>"Japanese", :parent_id=>top_category.id, :abbrev=>"JAPAN", :url=>"japanese.html")
    Category.create(:name=>"Korean", :parent_id=>top_category.id, :abbrev=>"KOREAN", :url=>"korean.html")
    Category.create(:name=>"Sanskrit", :parent_id=>top_category.id, :abbrev=>"SNKRT", :url=>"sanskrit.html")
    Category.create(:name=>"Tagalog", :parent_id=>top_category.id, :abbrev=>"TAGLG", :url=>"asamst.html") #special
    Category.create(:name=>"Tamil", :parent_id=>top_category.id, :abbrev=>"TAMIL", :url=>"tamil.html")
    Category.create(:name=>"Thai", :parent_id=>top_category.id, :abbrev=>"THAI", :url=>"thai.html")
    Category.create(:name=>"Tibetan", :parent_id=>top_category.id, :abbrev=>"TIB", :url=>"tibetan.html")
    Category.create(:name=>"Urdu", :parent_id=>top_category.id, :abbrev=>"URDU", :url=>"urdu.html")
    Category.create(:name=>"Vietnamese", :parent_id=>top_category.id, :abbrev=>"VIET", :url=>"viet.html")
    Category.create(:name=>"Astronomy", :abbrev=>"ASTR", :url=>"astro.html", :parent_id=>college.id)
    Category.create(:name=>"Astrobiology", :abbrev=>"ASTBIO", :url=>"astbio.html", :parent_id=>college.id)
    Category.create(:name=>"Atmospheric Sciences", :abbrev=>"ATM S", :url=>"atmos.html", :parent_id=>college.id)
    Category.create(:name=>"Biology", :abbrev=>"BIOL", :url=>"biology.html", :parent_id=>college.id)
    Category.create(:name=>"Botany", :abbrev=>"BOT", :url=>"biology.html", :parent_id=>college.id) #special
    Category.create(:name=>"Center for Statistics and Social Sciences", :abbrev=>"CS&SS", :url=>"cs&ss.html", :parent_id=>college.id)
    Category.create(:name=>"Center for Studies in Demography and Ecology", :abbrev=>"CSDE", :url=>"csde.html", :parent_id=>college.id)
    Category.create(:name=>"Center for the Humanities", :abbrev=>"HUM", :url=>"centhum.html", :parent_id=>college.id)
    Category.create(:name=>"Chemistry", :abbrev=>"CHEM", :url=>"chem.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Classics", :parent_id=>college.id)
    Category.create(:name=>"Classical Archaeology", :abbrev=>"CL AR", :url=>"clarch.html", :parent_id=>top_category.id)
    Category.create(:name=>"Classical Linguistics", :abbrev=>"CL LI", :url=>"cling.html", :parent_id=>top_category.id)
    Category.create(:name=>"Classics", :abbrev=>"CLAS", :url=>"clas.html", :parent_id=>top_category.id)
    Category.create(:name=>"Greek", :abbrev=>"GREEK", :url=>"greek.html", :parent_id=>top_category.id)
    Category.create(:name=>"Latin", :abbrev=>"LATIN", :url=>"latin.html", :parent_id=>top_category.id)
    Category.create(:name=>"Communication", :abbrev=>"COM", :url=>"com.html", :parent_id=>college.id)
    Category.create(:name=>"Comparative History of Ideas", :abbrev=>"CHID", :url=>"chid.html", :parent_id=>college.id)
    Category.create(:name=>"Comparative Literature", :abbrev=>"C LIT", :url=>"complit.html", :parent_id=>college.id)
    Category.create(:name=>"Computer Science", :abbrev=>"CSE", :url=>"cse.html", :parent_id=>college.id) #special
    Category.create(:name=>"Dance", :abbrev=>"DANCE", :url=>"dance.html", :parent_id=>college.id)
    Category.create(:name=>"Digital Arts and Experimental Media", :abbrev=>"DXARTS", :url=>"dxarts.html", :parent_id=>college.id)
    Category.create(:name=>"Drama", :abbrev=>"DRAMA", :url=>"drama.html", :parent_id=>college.id)
    Category.create(:name=>"Earth and Space Sciences", :abbrev=>"ESS", :url=>"ess.html", :parent_id=>college.id)
    Category.create(:name=>"Economics", :abbrev=>"ECON", :url=>"econ.html", :parent_id=>college.id)
    Category.create(:name=>"Environmental Studies", :abbrev=>"ENVIR", :url=>"envst.html", :parent_id=>college.id) #special
    Category.create(:name=>"General Interdisciplinary Studies", :abbrev=>"GIS", :url=>"gis.html", :parent_id=>college.id)
    Category.create(:name=>"General Studies", :abbrev=>"GEN ST", :url=>"genst.html", :parent_id=>college.id)
    Category.create(:name=>"Genetics", :abbrev=>"GENOME", :url=>"genome.html", :parent_id=>college.id) #special
    Category.create(:name=>"Geography", :abbrev=>"GEOG", :url=>"geog.html", :parent_id=>college.id)
    Category.create(:name=>"Geological Sciences", :abbrev=>"ESS", :url=>"ess.html", :parent_id=>college.id)
    Category.create(:name=>"Geophysics", :abbrev=>"ESS", :url=>"ess.html", :parent_id=>college.id)
    Category.create(:name=>"Germanics", :abbrev=>"GERMAN", :url=>"germ.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"History", :parent_id=>college.id)
    Category.create(:name=>"Ancient and Medieval History", :abbrev=>"HSTAM", :url=>"ancmedh.html", :parent_id=>top_category.id)
    Category.create(:name=>"History", :abbrev=>"HIST", :url=>"hist.html", :parent_id=>top_category.id)
    Category.create(:name=>"History of Asia", :abbrev=>"HSTAS", :url=>"histasia.html", :parent_id=>top_category.id)
    Category.create(:name=>"History of the Americas", :abbrev=>"HSTAA", :url=>"histam.html", :parent_id=>top_category.id)
    Category.create(:name=>"Modern European History", :abbrev=>"HSTEU", :url=>"modeuro.html", :parent_id=>top_category.id)
    Category.create(:name=>"History and Philosophy of Science", :abbrev=>"HPS", :url=>"hps.html", :parent_id=>top_category.id)
    Category.create(:name=>"Honors", :abbrev=>"H A&S", :url=>"honors.html", :parent_id=>college.id)
    Category.create(:name=>"Humanities -- Center for the Humanities", :abbrev=>"HUM", :url=>"centhum.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Jackson School of International Studies", :parent_id=>college.id)
    Category.create(:name=>"European Studies", :abbrev=>"EURO", :url=>"euro.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies", :abbrev=>"SIS", :url=>"intl.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (African Studies)", :abbrev=>"SISAF", :url=>"intlafr.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (Asian Studies)", :abbrev=>"SISA", :url=>"intlasian.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (Canadian Studies)", :abbrev=>"SISCA", :url=>"intlcan.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (Comparative Religion)", :abbrev=>"RELIG", :url=>"religion.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (East Asian Studies)", :abbrev=>"SISEA", :url=>"intleas.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (Jewish Studies)", :abbrev=>"SISJE", :url=>"intljewish.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (Latin American Studies)", :abbrev=>"SISLA", :url=>"intllatam.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (Middle Eastern Studies)", :abbrev=>"SISME", :url=>"intlmide.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (Russian, East European, and Central Asian Studies)", :abbrev=>"SISRE", :url=>"russeeuca.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (South Asian Studies)", :abbrev=>"SISSA", :url=>"intlsoa.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Studies (Southeast Asian Studies)", :abbrev=>"SISSE", :url=>"intlsea.html", :parent_id=>top_category.id)
    Category.create(:name=>"Law, Societies, and Justice", :abbrev=>"LSJ", :url=>"lsj.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Linguistics", :parent_id=>college.id)
    Category.create(:name=>"American Sign Language", :abbrev=>"ASL", :url=>"asl.html", :parent_id=>top_category.id)
    Category.create(:name=>"Frensh Linguistics", :abbrev=>"FRLING", :url=>"frling.html", :parent_id=>top_category.id)
    Category.create(:name=>"Linguistics", :abbrev=>"LING", :url=>"ling.html", :parent_id=>top_category.id)
    Category.create(:name=>"Romance Linguistics", :abbrev=>"ROLING", :url=>"romling.html", :parent_id=>top_category.id)
    Category.create(:name=>"Spanish Linguistics", :abbrev=>"SPLING", :url=>"spanlin.html", :parent_id=>top_category.id)
    Category.create(:name=>"Mathematics", :abbrev=>"MATH", :url=>"math.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Music", :parent_id=>college.id)
    Category.create(:name=>"Music", :abbrev=>"MUSIC", :url=>"music.html", :parent_id=>top_category.id)
    Category.create(:name=>"Music - Applied", :abbrev=>"MUSAP", :url=>"appmus.html", :parent_id=>top_category.id)
    Category.create(:name=>"Music Education", :abbrev=>"MUSED", :url=>"mused.html", :parent_id=>top_category.id)
    Category.create(:name=>"Music Ensemble", :abbrev=>"MUSEN", :url=>"musensem.html", :parent_id=>top_category.id)
    Category.create(:name=>"Music History", :abbrev=>"MUHST", :url=>"mushist.html", :parent_id=>top_category.id)
    top_category = Category.create(:name=>"Near Eastern Languages and Civilization", :parent_id=>college.id)
    Category.create(:name=>"Akkadian", :abbrev=>"AKKAD", :url=>"akkad.html", :parent_id=>top_category.id)
    Category.create(:name=>"Arabic", :abbrev=>"ARAB", :url=>"arabic.html", :parent_id=>top_category.id)
    Category.create(:name=>"Aramaic", :abbrev=>"ARAMIC", :url=>"aramic.html", :parent_id=>top_category.id)
    Category.create(:name=>"Egyptian", :abbrev=>"EGYPT", :url=>"egypt.html", :parent_id=>top_category.id)
    Category.create(:name=>"Hebrew", :abbrev=>"HEBR", :url=>"hebrew.html", :parent_id=>top_category.id)
    Category.create(:name=>"Near Eastern Languages and Civilization", :abbrev=>"NEAR E", :url=>"neareast.html", :parent_id=>top_category.id)
    Category.create(:name=>"Persian", :abbrev=>"PRSAN", :url=>"persian.html", :parent_id=>top_category.id)
    Category.create(:name=>"Turkic", :abbrev=>"TKIC", :url=>"turkic.html", :parent_id=>top_category.id)
    Category.create(:name=>"Turkish", :abbrev=>"TKISH", :url=>"turkish.html", :parent_id=>top_category.id)
    Category.create(:name=>"Ugaritic", :abbrev=>"UGARIT", :url=>"ugarit.html", :parent_id=>top_category.id)
    Category.create(:name=>"Neurobiology", :abbrev=>"NBIO", :url=>"nbio.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Philosophy", :parent_id=>college.id)
    Category.create(:name=>"History and Philosophy of Science", :abbrev=>"HPS", :url=>"hps.html", :parent_id=>top_category.id)
    Category.create(:name=>"Philosophy", :abbrev=>"PHIL", :url=>"phil.html", :parent_id=>top_category.id)
    Category.create(:name=>"Values in Society", :abbrev=>"VALUES", :url=>"values.html", :parent_id=>top_category.id)
    Category.create(:name=>"Physics", :abbrev=>"PHYS", :url=>"phys.html", :parent_id=>college.id)
    Category.create(:name=>"Political Science", :abbrev=>"POL S", :url=>"polisci.html", :parent_id=>college.id)
    Category.create(:name=>"Psychology", :abbrev=>"PSYCH", :url=>"psych.html", :parent_id=>college.id)
    Category.create(:name=>"Quantitative Science", :abbrev=>"Q SCI", :url=>"quantsci.html", :parent_id=>college.id) #special
    top_category = Category.create(:name=>"Romance Languages and Literature", :parent_id=>college.id)
    Category.create(:name=>"French", :abbrev=>"FRENCH", :url=>"french.html", :parent_id=>top_category.id)
    Category.create(:name=>"Italian", :abbrev=>"ITAL", :url=>"italian.html", :parent_id=>top_category.id)
    Category.create(:name=>"Portugese", :abbrev=>"PORT", :url=>"port.html", :parent_id=>top_category.id)
    Category.create(:name=>"Romance Languages and Literature", :abbrev=>"ROMAN", :url=>"romance.html", :parent_id=>top_category.id)
    Category.create(:name=>"Romance Linguistics", :abbrev=>"ROLING", :url=>"romling.html", :parent_id=>top_category.id)
    Category.create(:name=>"Romanian (Romance)", :abbrev=>"RMN", :url=>"romanianr.html", :parent_id=>top_category.id)
    Category.create(:name=>"Spanish", :abbrev=>"SPAN", :url=>"spanish.html", :parent_id=>top_category.id)
    top_category = Category.create(:name=>"Scandinavian Languages and Literature", :parent_id=>college.id)
    Category.create(:name=>"Danish", :abbrev=>"DANISH", :url=>"danish.html", :parent_id=>top_category.id)
    Category.create(:name=>"Estonian", :abbrev=>"ESTO", :url=>"eston.html", :parent_id=>top_category.id)
    Category.create(:name=>"Finnish", :abbrev=>"FINN", :url=>"finnish.html", :parent_id=>top_category.id)
    Category.create(:name=>"Latvian", :abbrev=>"LATV", :url=>"latvian.html", :parent_id=>top_category.id)
    Category.create(:name=>"Lithuanian", :abbrev=>"LITH", :url=>"lith.html", :parent_id=>top_category.id)
    Category.create(:name=>"Norwegian", :abbrev=>"NORW", :url=>"norweg.html", :parent_id=>top_category.id)
    Category.create(:name=>"Scandinavian", :abbrev=>"SCAND", :url=>"scand.html", :parent_id=>top_category.id)
    Category.create(:name=>"Swedish", :abbrev=>"SWED", :url=>"swedish.html", :parent_id=>top_category.id)
    top_category = Category.create(:name=>"Slavic Languages and Literature", :parent_id=>college.id)
    Category.create(:name=>"Bosnian/Croatian/Serbian", :abbrev=>"BCS", :url=>"bcs.html", :parent_id=>top_category.id)
    Category.create(:name=>"Bulgarian", :abbrev=>"BULGR", :url=>"bulgar.html", :parent_id=>top_category.id)
    Category.create(:name=>"Czech", :abbrev=>"CZECH", :url=>"czech.html", :parent_id=>top_category.id)
    Category.create(:name=>"Georgian", :abbrev=>"GEORG", :url=>"georg.html", :parent_id=>top_category.id)
    Category.create(:name=>"Polish", :abbrev=>"POLSH", :url=>"polish.html", :parent_id=>top_category.id)
    Category.create(:name=>"Romanian (Slavic)", :abbrev=>"ROMN", :url=>"romanian.html", :parent_id=>top_category.id)
    Category.create(:name=>"Russian", :abbrev=>"RUSS", :url=>"russian.html", :parent_id=>top_category.id)
    Category.create(:name=>"Slavic", :abbrev=>"SLAV", :url=>"slavic.html", :parent_id=>top_category.id)
    Category.create(:name=>"Slavic Languages and Literature", :abbrev=>"SLAVIC", :url=>"slav.html", :parent_id=>top_category.id)
    Category.create(:name=>"Ukranian", :abbrev=>"UKR", :url=>"ukrain.html", :parent_id=>top_category.id)
    Category.create(:name=>"Social Sciences", :abbrev=>"SOCSCI", :url=>"socsci.html", :parent_id=>college.id)
    Category.create(:name=>"Sociology", :abbrev=>"SOC", :url=>"soc.html", :parent_id=>college.id)
    Category.create(:name=>"Speech and Hearing Sciences", :abbrev=>"SPHSC", :url=>"sphsc.html", :parent_id=>college.id)
    Category.create(:name=>"Statistics", :abbrev=>"STAT", :url=>"stat.html", :parent_id=>college.id)
    Category.create(:name=>"Summer Arts Festival", :abbrev=>"ARTS", :url=>"arts.html", :parent_id=>college.id)
    Category.create(:name=>"Women Studies", :abbrev=>"WOMEN", :url=>"women.html", :parent_id=>college.id)
    Category.create(:name=>"Zoology", :abbrev=>"BIOL", :url=>"biology.html", :parent_id=>college.id) #special
    
    #College of Built Environments
    college = Category.create(:name=>"College of Built Environments", :parent_id=>HOME_ID)
    Category.create(:name=>"Architecture", :abbrev=>"ARCH", :url=>"archit.html", :parent_id=>college.id)
    Category.create(:name=>"Built Environment", :abbrev=>"B E", :url=>"be.html", :parent_id=>college.id)
    Category.create(:name=>"Construction Management", :abbrev=>"CM", :url=>"constmgmt.html", :parent_id=>college.id)
    Category.create(:name=>"Landscape Architecture", :abbrev=>"L ARCH", :url=>"landscape.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Urban Planning", :parent_id=>college.id)
    Category.create(:name=>"Community and Environmental Planning", :abbrev=>"CEP", :url=>"commenv.html", :parent_id=>top_category.id)
    Category.create(:name=>"Strategic Planning for Critical Infrastructure", :abbrev=>"SPCI", :url=>"spci.html", :parent_id=>top_category.id)
    Category.create(:name=>"Urban Planning", :abbrev=>"URBDP", :url=>"urbdes.html", :parent_id=>top_category.id)
    
    #Business School
    college = Category.create(:name=>"Business School", :parent_id=>HOME_ID)
    Category.create(:name=>"Accounting", :abbrev=>"ACCTG", :url=>"acctg.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Business Administration", :parent_id=>college.id)
    Category.create(:name=>"Administration", :abbrev=>"ADMIN", :url=>"admin.html", :parent_id=>top_category.id)
    Category.create(:name=>"Business Administration", :abbrev=>"B A", :url=>"ba.html", :parent_id=>top_category.id)
    Category.create(:name=>"Business Administration Research Methods", :abbrev=>"BA RM", :url=>"barm.html", :parent_id=>top_category.id)
    Category.create(:name=>"Business Communications", :abbrev=>"B CMU", :url=>"buscomm.html", :parent_id=>top_category.id)
    Category.create(:name=>"Business Economics", :abbrev=>"B ECON", :url=>"busecon.html", :parent_id=>top_category.id)
    Category.create(:name=>"Business Policy", :abbrev=>"B POL", :url=>"bpol.html", :parent_id=>top_category.id)
    Category.create(:name=>"E-Business", :abbrev=>"EBIZ", :url=>"ebiz.html", :parent_id=>top_category.id)
    Category.create(:name=>"Entrepreneurship", :abbrev=>"ENTRE", :url=>"entre.html", :parent_id=>top_category.id)
    Category.create(:name=>"Finance", :abbrev=>"FIN", :url=>"finance.html", :parent_id=>top_category.id)
    Category.create(:name=>"Human Resources Management and Organizational Behavior", :abbrev=>"HRMOB", :url=>"hrmob.html", :parent_id=>top_category.id)
    Category.create(:name=>"Informational Systems", :abbrev=>"I S", :url=>"infosys.html", :parent_id=>top_category.id)
    Category.create(:name=>"International Business", :abbrev=>"I BUS", :url=>"intlbus.html", :parent_id=>top_category.id)
    Category.create(:name=>"Management", :abbrev=>"MGMT", :url=>"mgmt.html", :parent_id=>top_category.id)
    Category.create(:name=>"Marketing", :abbrev=>"MKTG", :url=>"mktg.html", :parent_id=>top_category.id)
    Category.create(:name=>"Operations Management", :abbrev=>"OPMGT", :url=>"opmgmt.html", :parent_id=>top_category.id)
    Category.create(:name=>"Organization and Environment", :abbrev=>"O E", :url=>"orgenv.html", :parent_id=>top_category.id)
    Category.create(:name=>"Quantitative Methods", :abbrev=>"QMETH", :url=>"qmeth.html", :parent_id=>top_category.id)
    Category.create(:name=>"Strategic Management", :abbrev=>"ST MGT", :url=>"stratm.html", :parent_id=>top_category.id)
    
    #School of Dentistry
    college = Category.create(:name=>"School of Dentistry", :parent_id=>HOME_ID)
    Category.create(:name=>"Dental Hygiene", :abbrev=>"D HYG", :url=>"denthy.html", :parent_id=>college.id)
    Category.create(:name=>"Dental Public Health Sciences", :abbrev=>"DPHS", :url=>"dphs.html", :parent_id=>college.id)
    Category.create(:name=>"Dentistry", :abbrev=>"DENT", :url=>"dent.html", :parent_id=>college.id)
    Category.create(:name=>"Endodontics", :abbrev=>"ENDO", :url=>"endo.html", :parent_id=>college.id)
    Category.create(:name=>"Oral Biology", :abbrev=>"ORALB", :url=>"oralbio.html", :parent_id=>college.id)
    Category.create(:name=>"Oral Medicine", :abbrev=>"ORALM", :url=>"oralm.html", :parent_id=>college.id)
    Category.create(:name=>"Oral Surgery", :abbrev=>"O S", :url=>"os.html", :parent_id=>college.id)
    Category.create(:name=>"Orthodontics", :abbrev=>"ORTHO", :url=>"orthod.html", :parent_id=>college.id)
    Category.create(:name=>"Pediatric Dentistry", :abbrev=>"PEDO", :url=>"pedodon.html", :parent_id=>college.id)
    Category.create(:name=>"Periodontics", :abbrev=>"PERIO", :url=>"perio.html", :parent_id=>college.id)
    Category.create(:name=>"Prosthodontics", :abbrev=>"PROS", :url=>"pros.html", :parent_id=>college.id)
    Category.create(:name=>"Restorative Dentistry", :abbrev=>"RES D", :url=>"restor.html", :parent_id=>college.id)
    
    #College of Education
    college = Category.create(:name=>"College of Education", :parent_id=>HOME_ID)
    Category.create(:name=>"Curriculum and Instruction", :abbrev=>"EDC&I", :url=>"edci.html", :parent_id=>college.id)
    Category.create(:name=>"College of Education", :abbrev=>"EDUC", :url=>"indsrf.html", :parent_id=>college.id)
    Category.create(:name=>"Early Childhood and Family Studies", :abbrev=>"ECFS", :url=>"ecfs.html", :parent_id=>college.id)
    Category.create(:name=>"Education (Teacher Education Program)", :abbrev=>"EDTEP", :url=>"teached.html", :parent_id=>college.id)
    Category.create(:name=>"Educational Leadership and Policy Studies", :abbrev=>"EDLPS", :url=>"edlp.html", :parent_id=>college.id)
    Category.create(:name=>"Educational Psychology", :abbrev=>"EDPSY", :url=>"edpsy.html", :parent_id=>college.id)
    Category.create(:name=>"Special Education", :abbrev=>"EDSPE", :url=>"sped.html", :parent_id=>college.id)
    
    #College of Engineering
    college = Category.create(:name=>"College of Engineering", :parent_id=>HOME_ID)
    Category.create(:name=>"Aeronautics and Astronautics", :abbrev=>"A A", :url=>"aa.html", :parent_id=>college.id)
    Category.create(:name=>"Chemical Engineering", :abbrev=>"CHEM E", :url=>"cheng.html", :parent_id=>college.id)
    Category.create(:name=>"Civil and Environmental Engineering", :abbrev=>"CEE", :url=>"cee.html", :parent_id=>college.id)
    Category.create(:name=>"Computer Science and Engineering", :abbrev=>"CSE", :url=>"cse.html", :parent_id=>college.id)
    Category.create(:name=>"Electrical Engineering", :abbrev=>"E E", :url=>"ee.html", :parent_id=>college.id)
    Category.create(:name=>"Engineering", :abbrev=>"ENGR", :url=>"engr.html", :parent_id=>college.id)
    Category.create(:name=>"Industrial Engineering", :abbrev=>"IND E", :url=>"inde.html", :parent_id=>college.id)
    Category.create(:name=>"Materials Science and Engineering", :abbrev=>"MS E", :url=>"mse.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Mechanical Engineering", :parent_id=>college.id)
    Category.create(:name=>"Mechanical Engineering", :abbrev=>"M E", :url=>"meche.html", :parent_id=>top_category.id)
    Category.create(:name=>"Mechanical Engineering Industrial Engineering", :abbrev=>"MEIE", :url=>"meie.html", :parent_id=>top_category.id)
    Category.create(:name=>"Technical Communication", :abbrev=>"T C", :url=>"techc.html", :parent_id=>college.id)
    
    #College of Forest Resources
    college = Category.create(:name=>"College of Forest Resources", :parent_id=>HOME_ID)
    Category.create(:name=>"College of Forest Resources", :abbrev=>"CFR", :url=>"forr.html", :parent_id=>college.id)
    Category.create(:name=>"Environmental Science and Resource Management", :abbrev=>"ESRM", :url=>"esrm.html", :parent_id=>college.id)
    Category.create(:name=>"Paper Science and Engineering", :abbrev=>"PSE", :url=>"paper.html", :parent_id=>college.id)
    
    #The Information School
    college = Category.create(:name=>"The Information School", :parent_id=>HOME_ID)
    Category.create(:name=>"Informatics", :abbrev=>"INFO", :url=>"info.html", :parent_id=>college.id)
    Category.create(:name=>"Information School Interdisciplinary", :abbrev=>"INFX", :url=>"infx.html", :parent_id=>college.id)
    Category.create(:name=>"Information Science", :abbrev=>"INSC", :url=>"insc.html", :parent_id=>college.id)
    Category.create(:name=>"Information Management", :abbrev=>"IMT", :url=>"95imt.html", :parent_id=>college.id)
    Category.create(:name=>"Library and Information Science", :abbrev=>"LIS", :url=>"lis.html", :parent_id=>college.id)
    
    #Interdisciplinary Graduate Programs
    college = Category.create(:name=>"Interdisciplinary Graduate Programs", :parent_id=>HOME_ID)
    Category.create(:name=>"Biomolecular Structure and Design", :abbrev=>"BMSD", :url=>"bmsd.html", :parent_id=>college.id)
    Category.create(:name=>"Graduate School", :abbrev=>"GRDSCH", :url=>"grad.html", :parent_id=>college.id)
    Category.create(:name=>"Global Trade, Transportation & Logistics", :abbrev=>"GTTL", :url=>"gttl.html", :parent_id=>college.id)
    Category.create(:name=>"Individual PhD", :abbrev=>"IPHD", :url=>"iphd.html", :parent_id=>college.id)
    Category.create(:name=>"Molecular and Cellular Biology", :abbrev=>"MCB", :url=>"mcb.html", :parent_id=>college.id)
    Category.create(:name=>"Museology", :abbrev=>"MUSEUM", :url=>"museo.html", :parent_id=>college.id)
    Category.create(:name=>"Near and Middle Eastern Studies", :abbrev=>"N&MES", :url=>"nearmide.html", :parent_id=>college.id)
    Category.create(:name=>"Neurobiology and Behavior", :abbrev=>"NEUBEH", :url=>"neurobio.html", :parent_id=>college.id)
    Category.create(:name=>"Nutritional Science", :abbrev=>"NUTR", :url=>"nutrit.html", :parent_id=>college.id)
    Category.create(:name=>"Program on the Environment", :abbrev=>"ENVIR", :url=>"envst.html", :parent_id=>college.id)
    Category.create(:name=>"Quantitative Ecology and Resource Management", :abbrev=>"QERM", :url=>"quante.html", :parent_id=>college.id)
    Category.create(:name=>"Quaternary Science", :abbrev=>"QUAT", :url=>"qrc.html", :parent_id=>college.id)
    
    #Interschool or Intercollege Programs
    college = Category.create(:name=>"Interschool or Intercollege Programs", :parent_id=>HOME_ID)
    Category.create(:name=>"Bioengineering", :abbrev=>"BIOEN", :url=>"bioeng.html", :parent_id=>college.id)
    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"gh.html", :parent_id=>college.id)
    Category.create(:name=>"University Conjoint Courses", :abbrev=>"UCONJ", :url=>"uconjoint.html", :parent_id=>college.id)
    
    #School of Law
    college = Category.create(:name=>"School of Law", :parent_id=>HOME_ID)
    Category.create(:name=>"Health Law", :abbrev=>"LAW H", :url=>"lawh.html", :parent_id=>college.id)
    Category.create(:name=>"Intellectual Property Law", :abbrev=>"LAW P", :url=>"lawp.html", :parent_id=>college.id)
    Category.create(:name=>"Law", :abbrev=>"LAW", :url=>"law.html", :parent_id=>college.id)
    Category.create(:name=>"Law (Taxation)", :abbrev=>"LAW T", :url=>"lawt.html", :parent_id=>college.id)
    Category.create(:name=>"Law A", :abbrev=>"LAW A", :url=>"lawa.html", :parent_id=>college.id)
    Category.create(:name=>"Law B", :abbrev=>"LAW B", :url=>"lawb.html", :parent_id=>college.id)
    Category.create(:name=>"Law E", :abbrev=>"LAW E", :url=>"lawe.html", :parent_id=>college.id)
    
    #School of Medicine
    college = Category.create(:name=>"School of Medicine", :parent_id=>HOME_ID)
    Category.create(:name=>"Anesthesiology", :abbrev=>"ANEST", :url=>"anest.html", :parent_id=>college.id)
    Category.create(:name=>"Biochemistry", :abbrev=>"BIOC", :url=>"bioch.html", :parent_id=>college.id)
    Category.create(:name=>"Bioengineering", :abbrev=>"BIOEN", :url=>"bioeng.html", :parent_id=>college.id)
    Category.create(:name=>"Biological Structure", :abbrev=>"B STR", :url=>"biostruct.html", :parent_id=>college.id)
    Category.create(:name=>"Comparative Medicine", :abbrev=>"C MED", :url=>"compmed.html", :parent_id=>college.id)
    Category.create(:name=>"Conjoint Courses", :abbrev=>"CONJ", :url=>"conj.html", :parent_id=>college.id)
    Category.create(:name=>"Family Medicine", :abbrev=>"FAMED", :url=>"famed.html", :parent_id=>college.id)
    Category.create(:name=>"Genome Sciences", :abbrev=>"GENOME", :url=>"genome.html", :parent_id=>college.id)
    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"gh.html", :parent_id=>college.id)
    Category.create(:name=>"Human Biology", :abbrev=>"HUBIO", :url=>"humbio.html", :parent_id=>college.id)
    Category.create(:name=>"Immunology", :abbrev=>"IMMUN", :url=>"immun.html", :parent_id=>college.id)
    Category.create(:name=>"Laboratory Medicine", :abbrev=>"LAB M", :url=>"law.html", :parent_id=>college.id)
    Category.create(:name=>"MEDEX Program", :abbrev=>"MEDEX", :url=>"93medex.html", :parent_id=>college.id)
    Category.create(:name=>"Medical Education and Biomedical Informatics", :abbrev=>"MEBI", :url=>"law.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Medical History and Ethics", :parent_id=>college.id)
    Category.create(:name=>"Bioethics and Humanities", :abbrev=>"B H", :url=>"bh.html", :parent_id=>top_category.id)
    Category.create(:name=>"Medical History and Ethics", :abbrev=>"MHE", :url=>"medhist.html", :parent_id=>top_category.id)
    top_category = Category.create(:name=>"Medicine", :parent_id=>college.id)
    Category.create(:name=>"Emergency Medicine", :abbrev=>"MED ER", :url=>"meder.html", :parent_id=>top_category.id)
    Category.create(:name=>"Medicine", :abbrev=>"MED", :url=>"medicine.html", :parent_id=>top_category.id)
    Category.create(:name=>"Medicine Elective Clerkships", :abbrev=>"MEDECK", :url=>"admin.html", :parent_id=>top_category.id)
    Category.create(:name=>"Medicine Required Clerkships", :abbrev=>"MEDRCK", :url=>"admin.html", :parent_id=>top_category.id)
    Category.create(:name=>"Microbiology", :abbrev=>"MICROM", :url=>"microbio.html", :parent_id=>college.id)
    Category.create(:name=>"Neurological Surgery", :abbrev=>"NEUR S", :url=>"neurosurg.html", :parent_id=>college.id)
    Category.create(:name=>"Neurology", :abbrev=>"NEURL", :url=>"neurl.html", :parent_id=>college.id)
    Category.create(:name=>"Obstetrics and Gynecology", :abbrev=>"OB GYN", :url=>"obgyn.html", :parent_id=>college.id)
    Category.create(:name=>"Ophthalmology", :abbrev=>"OPHTH", :url=>"ophthal.html", :parent_id=>college.id)
    Category.create(:name=>"Orthopedics", :abbrev=>"ORTHP", :url=>"orthop.html", :parent_id=>college.id)
    Category.create(:name=>"Otolaryngology -- Head and Neck Surgery", :abbrev=>"OTOHN", :url=>"otol.html", :parent_id=>college.id)
    Category.create(:name=>"Pathology", :abbrev=>"PATH", :url=>"patho.html", :parent_id=>college.id)
    Category.create(:name=>"Pediatrics", :abbrev=>"PEDS", :url=>"pediat.html", :parent_id=>college.id)
    Category.create(:name=>"Pharmacology", :abbrev=>"PHCOL", :url=>"pharma.html", :parent_id=>college.id)
    Category.create(:name=>"Physiology and Biophysics", :abbrev=>"P BIO", :url=>"physiolbio.html", :parent_id=>college.id)
    Category.create(:name=>"Psychiatry and Behavioral Sciences", :abbrev=>"PBSCI", :url=>"psychbehav.html", :parent_id=>college.id)
    Category.create(:name=>"Radiation Oncology", :abbrev=>"R ONC", :url=>"radonc.html", :parent_id=>college.id)
    Category.create(:name=>"Radiology", :abbrev=>"RADGY", :url=>"radiol.html", :parent_id=>college.id)
    Category.create(:name=>"Rehabilitation Medicine", :abbrev=>"REHAB", :url=>"rehab.html", :parent_id=>college.id)
    Category.create(:name=>"Surgery", :abbrev=>"SURG", :url=>"surg.html", :parent_id=>college.id)
    Category.create(:name=>"Urology", :abbrev=>"UROL", :url=>"uro.html", :parent_id=>college.id)
    
    #School of Nursing
    college = Category.create(:name=>"School of Nursing", :parent_id=>HOME_ID)
    Category.create(:name=>"Nursing", :abbrev=>"NSG", :url=>"nsg.html", :parent_id=>college.id)
    Category.create(:name=>"Nursing", :abbrev=>"NURS", :url=>"nursing.html", :parent_id=>college.id)
    Category.create(:name=>"Nursing Clinical", :abbrev=>"NCLIN", :url=>"nursingcl.html", :parent_id=>college.id)
    Category.create(:name=>"Nursing Methods", :abbrev=>"NMETH", :url=>"nursingmeth.html", :parent_id=>college.id)
    
    #College of Ocean and Fishery Sciences
    college = Category.create(:name=>"College of Ocean and Fishery Sciences", :parent_id=>HOME_ID)
    Category.create(:name=>"Aquatic and Fishery Sciences", :abbrev=>"FISH", :url=>"fish.html", :parent_id=>college.id)
    Category.create(:name=>"School of Marine Affairs", :abbrev=>"SMA", :url=>"marine.html", :parent_id=>college.id)
    Category.create(:name=>"Oceanography", :abbrev=>"OCEAN", :url=>"ocean.html", :parent_id=>college.id)
    
    #School of Pharmacy
    college = Category.create(:name=>"School of Pharmacy", :parent_id=>HOME_ID)
    Category.create(:name=>"Medicinal Chemistry", :abbrev=>"MEDCH", :url=>"medchem.html", :parent_id=>college.id)
    Category.create(:name=>"Pharmaceutics", :abbrev=>"PCEUT", :url=>"pharmceu.html", :parent_id=>college.id)
    Category.create(:name=>"Pharmacy", :abbrev=>"PHARM", :url=>"pharmacy.html", :parent_id=>college.id)
    Category.create(:name=>"Pharmacy Regulatory Affairs", :abbrev=>"PHRMRA", :url=>"phrmra.html", :parent_id=>college.id)
    
    #Evans School of Public Affairs
    college = Category.create(:name=>"Evans School of Public Affairs", :parent_id=>HOME_ID)
    Category.create(:name=>"Public Affairs", :abbrev=>"PB AF", :url=>"pubaff.html", :parent_id=>college.id)
    Category.create(:name=>"Public Policy and Management", :abbrev=>"PPM", :url=>"ppm.html", :parent_id=>college.id)
    
    #School of Public Health
    college = Category.create(:name=>"School of Public Health", :parent_id=>HOME_ID)
    Category.create(:name=>"Biostatistics", :abbrev=>"BIOST", :url=>"biostat.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Environmental and Occupational Health Sciences", :parent_id=>college.id)
    Category.create(:name=>"Environmental Health", :abbrev=>"ENV H", :url=>"envh.html", :parent_id=>top_category.id)
    top_category = Category.create(:name=>"Epidemiology", :parent_id=>college.id)
    Category.create(:name=>"Epidemiology", :abbrev=>"EPI", :url=>"epidem.html", :parent_id=>top_category.id)
    Category.create(:name=>"Public Health Genetics", :abbrev=>"PHG", :url=>"phg.html", :parent_id=>top_category.id)
    Category.create(:name=>"Global Health", :abbrev=>"G H", :url=>"gh.html", :parent_id=>college.id)
    top_category = Category.create(:name=>"Health Services", :parent_id=>college.id)
    Category.create(:name=>"Health Services", :abbrev=>"HSERV", :url=>"hlthsvcs.html", :parent_id=>top_category.id)
    Category.create(:name=>"Health Services Management", :abbrev=>"HSMGMT", :url=>"hsmgmt.html", :parent_id=>top_category.id)
    Category.create(:name=>"Pathobiology", :abbrev=>"PABIO", :url=>"pathobio.html", :parent_id=>college.id)
    
    #Reserve Officers Training Corps Programs
    college = Category.create(:name=>"Reserve Officers Training Corps Programs", :parent_id=>HOME_ID)
    Category.create(:name=>"Aerospace Studies", :abbrev=>"A S", :url=>"88aerosci.html", :parent_id=>college.id)
    Category.create(:name=>"Military Science", :abbrev=>"M SCI", :url=>"88milsci.html", :parent_id=>college.id)
    Category.create(:name=>"Naval Science", :abbrev=>"N SCI", :url=>"88navsci.html", :parent_id=>college.id)
    
    #School of Social Work
    college = Category.create(:name=>"School of Social Work", :parent_id=>HOME_ID)
    Category.create(:name=>"Social Welfare BASW", :abbrev=>"SOC WF", :url=>"socwlbasw.html", :parent_id=>college.id)
    Category.create(:name=>"Social Welfare", :abbrev=>"SOC WL", :url=>"socwl.html", :parent_id=>college.id)
    Category.create(:name=>"Social Work (MSW)", :abbrev=>"SOC W", :url=>"socwk.html", :parent_id=>college.id)
    
    #Extended MPH Degree Program
    college = Category.create(:name=>"Extended MPH Degree Program", :parent_id=>HOME_ID)
    top_category = Category.create(:name=>"School of Public Health", :parent_id=>college.id)
    Category.create(:name=>"Biostatistics", :abbrev=>"BIOST", :url=>"94biostat.html", :parent_id=>top_category.id)
    Category.create(:name=>"Environmental Health", :abbrev=>"ENV H", :url=>"94envh.html", :parent_id=>top_category.id)
    Category.create(:name=>"Epidemiology", :abbrev=>"EPI", :url=>"94epidem.html", :parent_id=>top_category.id)
    Category.create(:name=>"Public Health Genetics", :abbrev=>"PHG", :url=>"94phg.html", :parent_id=>top_category.id)
    Category.create(:name=>"Health Services", :abbrev=>"HSERV", :url=>"94hlthsvcs.html", :parent_id=>top_category.id)
    Category.create(:name=>"Health Services Management", :abbrev=>"HSMGMT", :url=>"94hsmgmt.html", :parent_id=>top_category.id)
    Category.create(:name=>"Nutritional Science", :abbrev=>"NUTR", :url=>"94nutrit.html", :parent_id=>top_category.id)
    
    #Friday Harbor Laboratories
    college = Category.create(:name=>"Friday Harbor Laboratories", :parent_id=>HOME_ID)
    top_category = Category.create(:name=>"College of Arts and Sciences", :parent_id=>college.id)
    Category.create(:name=>"Biology", :abbrev=>"BIOL", :url=>"91biology.html", :parent_id=>top_category.id)
    top_category = Category.create(:name=>"College of Ocean and Fishery Sciences", :parent_id=>college.id)
    Category.create(:name=>"Aquatic and Fishery Sciences", :abbrev=>"FISH", :url=>"91fish.html", :parent_id=>top_category.id)
    Category.create(:name=>"School of Marine Affairs", :abbrev=>"SMA", :url=>"91marine.html", :parent_id=>top_category.id)
    Category.create(:name=>"Oceanography", :abbrev=>"OCEAN", :url=>"91ocean.html", :parent_id=>top_category.id)    
  end
  
end