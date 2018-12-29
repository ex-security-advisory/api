# ElixirSecurityAdvisory API

[![Build Status](https://travis-ci.com/ex-security-advisory/api.svg?branch=master)](https://travis-ci.com/ex-security-advisory/api)
[![Coverage Status](https://coveralls.io/repos/github/ex-security-advisory/api/badge.svg?branch=master)](https://coveralls.io/github/ex-security-advisory/api?branch=master)

This repository is not yet ready for production, check back later.

## Development Usage

1. Set Environment Variable `GITHUB_ACCESS_TOKEN` to a valid access token
1. Create mnesia db files with the command `mix amnesia.create -d ElixirSecurityAdvisory.Vulnerabilities.Database --disk`
1. Start Server with `iex -S mix phx.server`
