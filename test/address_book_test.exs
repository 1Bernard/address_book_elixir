defmodule AddressBookTest do
  use ExUnit.Case
  doctest AddressBook

  test "greets the world" do
    assert AddressBook.hello() == :world
  end
end
