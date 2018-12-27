defmodule ElixirSecurityAdvisoryApiV1.Schema.Scalar do
  @moduledoc false

  use ElixirSecurityAdvisoryApiV1, :schema_scalar

  scalar :version_requirement do
    description "SemVer 2.0 schema Version Requirement"
    # parse &Parser.version_requirement/1
    serialize &Serializer.version_requirement/1
  end

  scalar :uri do
    description "RFC 3986 URI"
    # parse &Parser.uri/1
    serialize &Serializer.uri/1
  end

  scalar :date do
    description "ISO 8601:2004 Date"
    # parse &Parser.date/1
    serialize &Serializer.date/1
  end

  scalar :markdown do
    description "GitHub flavored Markdown"
    # parse &Parser.markdown/1
    serialize &Serializer.markdown/1
  end

  scalar :version do
    description "SemVer 2.0 schema Version"
    parse &Parser.version/1
    # serialize &Serializer.version/1
  end
end
