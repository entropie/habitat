# coding: utf-8
require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../../blog/lib/blog/blog"
require File.dirname(__FILE__) + "/../lib/vgwort"

require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:blog, Blog::Database.with_adapter.new(TMP_PATH))

include Blog
include TestMixins

PostHash = {
  :title => "testtitle?",
  :content => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do",
  :tags => "foo, bar"
}
include UserMixin

TMP_POST = Habitat.adapter(:blog).with_user(MockUser1) do |a|
  a.create(PostHash)
end


VGWORTTEST = %|
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
90;<img src="http://vg09.met.vgwort.de/na/3857f02c4deb44ad92aa1d80b" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/3857f02c4deb44ad92aa1d8?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;047cfef53e924c4c8d384fa;
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
91;<img src="http://vg09.met.vgwort.de/na/b9088809d2014a4b892a1e15c" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/b9088809d2014a4b892a1e1?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;9b58c67ab5e341daba101;
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
92;<img src="http://vg09.met.vgwort.de/na/715a31c816e44193922d67e09" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/715a31c816e44193922d67e0?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;0c0b8a02babc47599ffad5f3;
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
93;<img src="http://vg09.met.vgwort.de/na/1a16f8fac94d40cb8" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/1a16f8fac94d40cb848360ec?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;e45579d83c9f11e9539be6;
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
94;<img src="http://vg09.met.vgwort.de/na/20d985441ba646" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/20d985441ba64662aaf16b2?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;9e9fa06eaf95edb39f6f7;
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
95;<img src="http://vg09.met.vgwort.de/na/59007a52faa7451" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/59007a52faa7451381f95af?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;740e984b2d867605baeeffa854;
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
96;<img src="http://vg09.met.vgwort.de/na/04fee4a8646c434c" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/04fee4a8646c434c8c0f86c?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;73b95039e494c9137e62e094dc001;
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
97;<img src="http://vg09.met.vgwort.de/na/521a1bf18a044a6" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/521a1bf18a044a6fa6fac578?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;3f8c5c583496c8effc6f8bb2c3cd9;
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
98;<img src="http://vg09.met.vgwort.de/na/a9dd4b8b1eeb4e1" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/a9dd4b8b1eeb4e12adf79c67?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;a7165dc6e435ab840091b2552b95c;
;Zählmarke für HTML Texte;Zählmarke für Dokumente (erlaubte Formate: PDF, ePub)
99;<img src="http://vg09.met.vgwort.de/na/295ab484b5154b6d" width="1" height="1" alt="">;<a href="http://vg09.met.vgwort.de/na/295ab484b5154b6d8f5087?l=URL_DES_DOKUMENTS">LINK-NAME</a>
;Privater Identifikationscode:;1723a156491b9c4f564a7316983a;
|


Habitat::Tests::Suites::PluginsTestSuite.environment(:blog) do
  def prepare!
  end
  
  def teardown!
    #_clr
  end
end

def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end




class TestPostWithVGwort < Minitest::Test
  def setup
    @post = TMP_POST
  end
  def test_lala
    #@post.with_plugin(VGWort).id_attached?
    puts VGWort.read_csvstr_to_database(VGWORTTEST)
    # #pp VGWort.database
    #VGWort.create_database
    #p VGWort.database
    #@post.with_plugin(VGWort).attach_id
    #puts @post.with_filter
  end


end
