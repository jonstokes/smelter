# Smelter

Smelter is a small gem that has a pretty specific use case. You can store
scripts and extensions in a data store (redis, postgres, or anything else)
and then use that stored code to dynamically mutate a shared context.

All of the caveats around `context_eval`ing some code from a data store apply.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'smelter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smelter

## Usage

The classes in `spec/support/test_classes.rb` and the specs will tell you all you
need to know about how this works. But here's an overview, with code from the specs.

Consider the following extension and script:

```ruby
  Test::Extension.define "test/my_extension" do
    extension do
      def subtract(a, b)
        a - b
      end
    end
  end

  Test::Script.define "test/my_script" do
    extensions 'test/*'

    script do
      number do |context|
        context['number'] * 10
      end

      subtraction_result do |context|
        subtract(context['number'], 1)
      end
    end
  end
```

Now imagine that the extension and script above are stored in some data store,
like redis or postgres. You then can do something like the following:

```ruby
  # Find the script by name in the database, and get a ScriptRunner
  # object that has the script's extensions defined on it.
  runner = Test::Script.runner("test/my_script")

  # Prepare a context Hash (or Struct) that the script can mutate
  # by running the Procs associated with each context attribute from
  # top to bottom.
  context = { 'number' => 5 }

  # Mutate the context by running the script on it.
  runner.run(context)

  # Results!
  context
  #=> { 'number' => 50, 'subtraction_result' => 49 }
```

Like I said, a pretty specific use case.

Stretched.io uses uses this code to prepare JSON objects from web pages
by extracting different attributes using [Nokogiri](http://nokogiri.org) and the [Buzzsaw DSL](http://github.com/jonstokes/buzzsaw.git).

Here's some actual code that I use with Stretched:

```ruby
Stretched::Script.define "globals/scripts/product_page" do
  extensions 'globals/extensions/*'

  script do
    title do |context|
      next unless context['title'].present?
      context['title'].squeeze(' ')
    end

    availability do |context|
      if %w(AuctionListing ClassifiedListing).include?(context['type'])
        "in_stock"
      else
        context['availability'].try(:downcase)
      end
    end

    image do |context|
      if context['image']
        clean_up_image_url(context['image'])
      end
    end

    price_in_cents do |context|
      convert_dollars_to_cents(context['price_in_cents'])
    end
  end
end
```
For the above, I populate the `context` hash with values extracted from a product
web page using [buzzsaw](http://github.com/jonstokes/buzzsaw.git) and [nokogiri](http://nokogiri.org). Then I go back over with the script and
clean up the data in the context hash, which eventually becomes a JSON object
that the platform enqueues for a user to be able to get the results of a web scrape.

The methods `convert_dollars_to_cents` and `clean_up_image_url` are defined in
one of the extensions that the script loads under `globals/extensions/*`. Notice
that the gem uses globbing to find extensions in the total namespace of extensions.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/smelter.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
