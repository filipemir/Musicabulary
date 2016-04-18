require 'omniauth'

OmniAuth.config.test_mode = true

def mock_auth_hash
  OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
    "provider"=>"lastfm",
    "uid"=>"gopigasus",
    "info"=>
    {"nickname"=>"gopigasus",
     "name"=>nil,
     "url"=>"http://www.last.fm/user/gopigasus",
     "image"=>"http://img2-ak.lst.fm/i/u/300x300/3986da997db38257ff069000e7467d32.png",
     "country"=>"",
     "age"=>"0",
     "gender"=>"n"},
    "credentials"=>{"token"=>"61297cb2e3fb53ccf3f15d15f5ec6b18", "name"=>"gopigasus"},
    "extra"=>
    {"raw_info"=>
      {"name"=>"gopigasus",
       "image"=>
        [{"#text"=>"http://img2-ak.lst.fm/i/u/34s/3986da997db38257ff069000e7467d32.png", "size"=>"small"},
         {"#text"=>"http://img2-ak.lst.fm/i/u/64s/3986da997db38257ff069000e7467d32.png", "size"=>"medium"},
         {"#text"=>"http://img2-ak.lst.fm/i/u/174s/3986da997db38257ff069000e7467d32.png", "size"=>"large"},
         {"#text"=>"http://img2-ak.lst.fm/i/u/300x300/3986da997db38257ff069000e7467d32.png", "size"=>"extralarge"}],
       "url"=>"http://www.last.fm/user/gopigasus",
       "country"=>"",
       "age"=>"0",
       "gender"=>"n",
       "subscriber"=>"0",
       "playcount"=>"46500",
       "playlists"=>"0",
       "bootstrap"=>"0",
       "registered"=>{"#text"=>1219632398, "unixtime"=>"1219632398"},
       "type"=>"user"}}
  })
end

mock_auth_hash
