# ElixirSecurityAdvisory API

This repository is not yet ready for production, check back later.

## TODO

* Find Out why the GitHub client is having errors after a few minutes
* SetUp CI
* Search for Hosting Solution supporting mnesia (Gigalixir?)
* Setup Hosting
* Test Subscriptions
* Update to Elixir 1.7 as soon as amnesia fixes some problems

## Development Usage

1. Set Environment Variable `GITHUB_ACCESS_TOKEN` to a valid access token
1. Create mnesia db files with the command `mix amnesia.create -d ElixirSecurityAdvisory.Vulnerabilities.Database --disk`
1. Start Server with `iex -S mix phx.server`
