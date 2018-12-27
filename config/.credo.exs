%{
  configs: [
    %{
      name: "default",
      files: %{
        included: [
          "apps/*/lib/**/*.ex",
          "apps/*/test/**/*.ex",
          "apps/*/test/**/*.exs",
          "apps/*/.formatter.exs",
          "apps/*/mix.exs",
          "config/*.exs",
          "mix.exs",
          ".formatter.exs"
        ]
      }
    }
  ]
}
