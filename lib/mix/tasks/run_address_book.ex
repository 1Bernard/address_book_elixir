defmodule Mix.Tasks.RunAddressBook do
  @moduledoc """
  Runs the simple file-based address book application.

  This is the Mix task that serves as the command-line entry point.
  Execute with `mix run_address_book`.
  """
  @behaviour Mix.Task

  @doc """
  The entry point for the Mix task.

  This function is called by Mix when you run `mix run_address_book`.
  It delegates the actual application startup to `AddressBook.run/0`.
  The underscore `_` means we are ignoring any arguments passed to the task.
  """
  def run(_) do
    # Call the main run function of your AddressBook module
    AddressBook.run()
  end
end
