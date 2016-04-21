def artist_loader(name)
  artist = Artist.create(name: name)
  artist.update
end

artist_loader('Titus Andronicus')
artist_loader('Tom Waits')
artist_loader('Bob Dylan')
artist_loader('Wilco')
artist_loader('Bahamas')
artist_loader('Shovels & Rope')
artist_loader('Josh Ritter')
artist_loader('The Decemberists')
artist_loader('Justin Townes Earle')
artist_loader('Aesop Rock')
