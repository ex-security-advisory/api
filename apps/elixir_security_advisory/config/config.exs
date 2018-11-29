# Since configuration is shared in umbrella projects, this file
# should only configure the :elixir_security_advisory application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

import_config "#{Mix.env()}.exs"
