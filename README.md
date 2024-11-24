# Puma::Plugin::Shellscript

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add puma-plugin-shellscript
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install puma-plugin-shellscript
```

## Usage

```ruby
# config/puma.rb
[...]
plugin :shellscript if ENV['PUMA_PLUGIN_SHELLSCRIPT'].present?
```

```
PUMA_PLUGIN_SHELLSCRIPT='echo test!!!!; sleep 5' be rails s
```

```
=> Booting Puma
=> Rails 8.0.0 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Puma version: 6.4.3 (ruby 3.2.2-p53) ("The Eagle of Durango")
*  Min threads: 3
*  Max threads: 3
*  Environment: development
*          PID: 55927
* Listening on http://127.0.0.1:3000
* Listening on http://[::1]:3000
[puma plugin shellscript] Running shellscript: echo test!!!!; sleep 5
Use Ctrl-C to stop
test!!!!
[puma plugin shellscript] Command exited successfully
[puma plugin shellscript] Running shellscript: echo test!!!!; sleep 5
test!!!!
[puma plugin shellscript] Command exited successfully
[puma plugin shellscript] Running shellscript: echo test!!!!; sleep 5
^C[puma plugin shellscript] Killing child process 55947
test!!!!
[puma plugin shellscript] Command failed with status:
[puma plugin shellscript] Running shellscript: echo test!!!!; sleep 5
[puma plugin shellscript] Failed to kill process: No child processes
- Gracefully stopping, waiting for requests to finish
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/puma-plugin-shellscript.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
