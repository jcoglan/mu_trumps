PopTrumps
=========

This is the web service for a Pop Trumps game built at Music Hack Day, at the
Midem conference in Cannes.

To run the server, you need Ruby and these gems:

    gem install rack thin sinatra activerecord sqlite3

Initialize the database:

    ruby config/prepare.rb

And run the server:

    rackup -s thin -E production -p 8000 config.ru
