# HancockCMSGallery

Image gallery for [HancockCMS](https://github.com/red-rocks/hancock_cms). Prototypes for image sliders, partners or services lists, etc

### Remaded from [EnjoyCMSGallery](https://github.com/red-rocks/enjoy_cms_gallery)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hancock_cms_gallery'
```

Then add this
```ruby
gem 'paperclip' # AR
```
or this
```ruby
gem 'glebtv-mongoid-paperclip' # Mongoid
```
before it.

Also you can add [PaperclipOptimizer](https://github.com/janfoeh/paperclip-optimizer) (before 'hancock_cms_gallery'). HancockCMSGallery supports that gem.
```ruby
gem 'paperclip-optimizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hancock_cms_gallery

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/red-rocks/hancock_cms_gallery.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
