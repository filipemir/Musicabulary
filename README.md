![Build Status](https://codeship.com/projects/00f29540-e86f-0133-f3a6-429aaf3cc23f/status?branch=master)
![Code Climate](https://codeclimate.com/github/filipemir/argot.png)
![Coverage Status](https://coveralls.io/repos/filipemir/argot/badge.png)

# Musicabulary
Musicabulary is a little web app I created during a two week period as the capstone for my time at [Launch Academy](https://launchacademy.com/). Its stated purpose was to help [last.fm](http://www.last.fm/) users take a peek at the lyrical diversity of their favorite musicians. Its actual purpose was to give me a reason to dip my toes in [d3.js](https://d3js.org/).

See it live [here](http://musicabulary.herokuapp.com).

![Overview](https://github.com/filipemir/Musicabulary/blob/master/app/assets/images/overview-gif.gif)

### Key Features
* last.fm login implemented using OmniAuth
* Gathers data on users and artists using the last.fm and Discogs APIs
* Retrieves lyrics from genius.com using a Nokogiri web scraper
* Charts results using d3.js

### Local Development
To run Musicabulary on your local machine, you'll need to have postgres setup. Easiest way to do that is to use http://postgresapp.com/

Then clone the repo and do the following:
* `bundle install`
* `bundle exec rake db:setup`

You'll need to access keys for the last.fm and discogs APIs. To get those, create new accounts [here](http://www.last.fm/api/account/create) and [here](https://www.discogs.com/settings/developers). When you create your last.fm account you'll need to specify a Omniauth callback URL. The path you'll want to use is `/users/auth/lastfm/callback`, so if you were developing locally you'll want to enter `http://localhost:3000/users/auth/lastfm/callback`, replacing 3000 with whatever port you're using.

Once you've set up your API keys, create a `.env` file in your root directory and add your values as follows:
```
LASTFM_KEY=<your last.fm key>
LASTFM_SECRET=<your last.fm secret>
DISCOGS_TOKEN=<your discogs token>
```

Once you have done that you should be all set. Run `rails s`

Note that running `bundle exec rake db:setup` sets off `seeds.rb`, which seeds the database with the songs for around 200 artists. Since each song is a different HTTP request, setting up the database can take quite some time (I've seen it run over an hour). If you want to speed up the process for subsequent runs, uncomment the commented-out lines in the `seeds.rb` file before you run it the first time. This will tell the seeder file to store each retrieved lyric in a CSV file in `db/lyrics_archive`. In addition, it directs the seeder file to check prior to scraping each song lyric if a CSV file for the respective song is present locally. If it is, the HTTP request will be skipped, which greatly increases loading speeds.

### Issues
I stopped regular development on this project way before it was completed. Here is a quick list of the improvements I would live to make if and when I return to it:
* The big one: the app is way too slow when users first log in. This is primarily because it fires off a ton of HTTP requests each of which does not resolve until the artist's score is computed. This is obviously a very bad user experience. A much better way to do it would be to have all the server side requests be asynchronous, with the client side polling the server for updated results.
* Add a CRON job to update the last.fm top artists periodically.
* There is next to no JS test coverage, so that too should be improved
* Improve feature tests.
* Make styling responsive. It looks terrible on phones.
* Make it easier to extract insights (such as they are) from charts:
    * Add genre color-coding
    * Add decade color-coding
    * Add ability to add arbitrary artists to charts