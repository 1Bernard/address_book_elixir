defmodule AddressBook.MixProject do
  use Mix.Project

  def project do
    [
      app: :address_book,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Add ex_doc to the list of applications to compile
      applications: [:logger, :ex_doc],
      # Add this line to include private functions in generated docs
      docs: [extras: ["README.md"], main: "readme", private: true]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, "~> 0.37.3", only: :dev, runtime: false}
    ]
  end

end
