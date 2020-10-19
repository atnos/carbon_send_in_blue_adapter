# carbon_send_in_blue_adapter

This is luckyframework/carbon's adapter for SendInBlue: https://www.sendinblue.com

https://github.com/luckyframework/carbon

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     carbon_send_in_blue_adapter:
       github: atnos/carbon_send_in_blue_adapter
   ```

2. Run `shards install`

## Usage

Set your `SENDINBLUE_API_KEY` variable inside `.env`

and update your `config/email.cr` file with:

```crystal
require "carbon_send_in_blue_adapter"

BaseEmail.configure do |settings|
  if Lucky::Env.production?
    sendinblue_key = sendinblue_key_from_env
    settings.adapter = Carbon::SendInBlueAdapter.new(api_key: sendinblue_key)
  else
    settings.adapter = Carbon::DevAdapter.new(print_emails: true)
  end
end

private def sendinblue_key_from_env
  ENV["SENDINBLUE_API_KEY"]? || raise_missing_key_message
end

private def raise_missing_key_message
  puts "Missing SENDINBLUE_API_KEY. Set the SENDINBLUE_API_KEY env variable to '' if not sending emails, or set the SENDINBLUE_API_KEY ENV var.".colorize.red
  exit(1)
end

```

## Contributing

1. Fork it (<https://github.com/your-github-user/carbon_send_in_blue_adapter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Bruno Perles](https://github.com/brunto) - creator and maintainer
