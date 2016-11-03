![Build Status](https://codeship.com/projects/00f29540-e86f-0133-f3a6-429aaf3cc23f/status?branch=master)
![Code Climate](https://codeclimate.com/github/filipemir/argot.png)
![Coverage Status](https://coveralls.io/repos/filipemir/argot/badge.png)

# Musicabulary
Musicabulary is a webapp designed to help last.fm users take a peek at the lyrical diversity of their favorite musicians. I created it during a two-week period as my capstone project for Launch Academy. See it live [here](http://musicabulary.herokuapp.com/).

### Key Features
* last.fm login implemented using OmniAuth
* Gathers data on users and artists using the last.fm and Discogs APIs
* Retrieves lyrics from genius.com using a Nokogiri web scraper
* Charts results using d3.js

### Deploying Musicabulary
To run Musicabulary on your local machine, you'll ned to have postgres. Easiest way to do that is to use http://postgresapp.com/

Then clone the repo and do the following:
* `bundle install`
* `bundle exec rake db:setup`

You'll need to add the last.fm and discogs APIs keys to your environmental variables. First, create new accounts [here](http://www.last.fm/api/account/create) and [here](https://www.discogs.com/settings/developers). When you create you last.fm account you'll need to specify a Omniauth callback URL. The path you'll want to use is `/users/auth/lastfm/callback`, so if you were devleoping locally you'll want to enter `http://localhost:3000//users/auth/lastfm/callback`, replacing 3000 with whatever port you're using. 

Once you've set up your API keys, create a `.env` file in your root directory and add your values as follows:
```
LASTFM_KEY=<your last.fm key>
LASTFM_SECRET=<your last.fm secret>
DISCOGS_TOKEN=<your discogs token>
``` 

Once you have done that you should be all set. Run `rails s`

Note that running `bundle exec rake db:setup` sets off `seeds.rb`, which seeds the database with the songs for around 200 artists. Since each song is a different HTTP request, setting up the database can take quite some time (I've seen it run over an hour). If you want to speed up the process for subsequent runs, uncomment the commented-out lines in the `seeds.rb` file before you run it the first time. This will tell the seeder file to store each retrieved lyric in a CSV file in `db/lyrics_archive`. In addition, it directs the seeder file to check prior to scraping each song lyric if a CSV file for the respective song is present locally. If it is, the HTTP request will be skipped, which greatly increases loading speeds. 

### To-dos
Wordcabulary is still under active development. Here are some of the tasks I'm planning to tackle in the near future:
* Improve management of loading times for first-time user by adding loading screens and notifications
* Improve test coverage for javascript
* Improve feature tests
* Make styling responsive
* Add genre color-coding
* Add decade color-coding
* Add ability to add arbitrary artists to charts