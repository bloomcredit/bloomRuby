# Bloomr

## Installation

    $ gem install 'bloomr'

## Usage

```
require('bloomr')

api = Bloomr::Api.new(
    api_url_base: 'https://sandbox.bloom.dev',
    auth_url_base: 'https://authn.bloom.dev',
    client_id: 'CLIENT_ID',
    client_secret: 'CLIENT_SECRET'
)

token = api.fetch_auth_token
id = api.register_consumer(token, {
    'first_name' => 'Michael',
    'last_name' => 'Scott',
    'city' => 'Scranton',
    'line1' => '1725 Slough Avenue',
    'state_code' => 'PA',
    'zipcode' => '18503',
    "address_primary" => true,
    'date_of_birth' => '1964-03-15',
    "ssn" => "123456789"
})
api.get_credit_data(token, ORDER_ID)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bloomr.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
