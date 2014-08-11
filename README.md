# Inch CI [![Build Status](https://travis-ci.org/inch-ci/inch_ci-web.svg?branch=master)](https://travis-ci.org/inch-ci/inch_ci-web) [![Inline docs](http://inch-ci.org/github/inch-ci/inch_ci-web.svg?branch=master)](http://inch-ci.org/github/inch-ci/inch_ci-web)

This will become an automated CI service for [Inch](https://github.com/rrrene/inch).


## Installation

`Inch CI` is a basic [Rails](https://github.com/rails/rails) app that requires [Sidekiq](https://github.com/mperham/sidekiq) for its background-workers.

Fork the project, clone it and then execute:

    $ bundle install

### Configuration

As in every Rails app, you have to cnfigure your database via `config/database.yml`. Optionally, you can add a valid GitHub access token to `config/access_tokens.yml` (sample files are present in `config/`).

### Seeding

After configuring the above, you can seed the database using `rake db:seed`. This will download the [_projects.yml](https://github.com/rrrene/inch-pages/blob/master/_projects.yml) file from the old Inch Pages project and seed the first 5 projects into your database (if you want to add more projects, use `COUNT=X rake db:seed`, where `X` is the desired number)



## Contributing

1. [Fork it!](http://github.com/inch-ci/inch_ci-web/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



## Author

René Föhring (@rrrene)



## Credits

Inch CI takes a lot of inspiration from the existing CI services, most notably Travis and Code Climate, which helped me improve my code long before I had the idea for Inch.



## License

Inch is released under the MIT License. See the LICENSE.txt file for further
details.
