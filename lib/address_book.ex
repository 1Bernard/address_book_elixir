defmodule AddressBook do
  # Define file names for storing contacts and users
  # Files are now located in a 'database' subdirectory
  @contacts_file_name "database/contacts.txt"
  @users_file_name "database/users.txt"

  # --- Public Interface ---

  # Starts the address book application loop
  def run do
    IO.puts(String.pad_leading(" Simple File-Based Address Book ", 50, "#"))

    # Ensure the database directory exists
    File.mkdir_p("database")

    # Load contacts and users when the application starts
    contacts = load_contacts()
    users = load_users()

    # Start the main loop in a pre-login state
    # nil indicates no user is logged in
    main_loop(contacts, users, nil)
  end

  # --- Core Logic ---

  # Main loop that handles both pre-login and post-login states
  # State is managed by passing contacts, users, and current_user
  defp main_loop(contacts, users, current_user) do
    # Display the appropriate menu based on login status
    if current_user do
      # User is logged in, show contact menu
      contact_menu()
    else
      # No user logged in, show authentication menu
      auth_menu()
    end

    # Read user input and handle potential end-of-file (Ctrl+D)
    case IO.gets("Select from the options above: ") do
      :eof ->
        # If end of input is reached, end the session gracefully
        end_session()

      input_line ->
        # If a line was read, trim it
        input = String.trim(input_line)

        # Handle input based on login status
        if current_user do
          # User is logged in, handle contact actions
          handle_contact_action(input, contacts, users, current_user)
        else
          # No user logged in, handle authentication actions
          handle_auth_action(input, contacts, users)
        end
    end
  end

  # Handles actions when no user is logged in (registration, login, exit)
  defp handle_auth_action(input, contacts, users) do
    case input do
      # Register
      "1" ->
        register(contacts, users)

      # Login
      "2" ->
        login(contacts, users)

      # End Session
      "0" ->
        end_session()

      # Invalid option
      _ ->
        IO.puts(String.pad_leading("Invalid option. Please select a valid option.", 50, "#"))
        # Continue the loop with the same state
        main_loop(contacts, users, nil)
    end
  end

  # Handles actions when a user is logged in (CRUD, Search, logout)
  defp handle_contact_action(input, contacts, users, current_user) do
    # Filter contacts to only show the current user's contacts for relevant operations
    # Note: Search operates on all user contacts, handled within the search function.
    user_contacts = Enum.filter(contacts, fn c -> c.user == current_user end)

    case input do
      # Add Contact
      "1" ->
        create(contacts, users, current_user)

      # Edit Contact
      "2" ->
        edit(contacts, users, current_user)

      # View Contact List
      "3" ->
        # Pass filtered contacts to view
        view(user_contacts, contacts, users, current_user)

      # Delete Contact
      "4" ->
        delete(contacts, users, current_user)

      # Search Contacts (New Option)
      "5" ->
        search(contacts, users, current_user)

      # Logout
      "6" ->
        logout(contacts, users)

      # Invalid option
      _ ->
        IO.puts(String.pad_leading("Invalid option. Please select a valid option.", 50, "#"))
        # Continue the loop with the same state
        main_loop(contacts, users, current_user)
    end
  end

  # Displays the authentication menu (pre-login)
  defp auth_menu do
    IO.puts(String.pad_leading(" Address Book Application ", 50, "#"))
    IO.puts("1. Register")
    IO.puts("2. Login")
    IO.puts("0. End Session")
  end

  # Displays the contact management menu (post-login)
  defp contact_menu do
    IO.puts(String.pad_leading(" Contact Management ", 50, "#"))
    IO.puts("1. Add Contact")
    IO.puts("2. Edit Contact")
    IO.puts("3. View Contact List")
    IO.puts("4. Delete Contact")
    IO.puts("5. Search Contacts") # Added Search option
    IO.puts("6. Logout")
  end

  # --- Authentication Functions ---

  # Registers a new user
  defp register(contacts, users) do
    IO.puts(String.pad_leading(" New User Registration ", 50, "#"))

    # Get username from user
    username = get_input("Enter a username: ")

    # Check if username already exists
    if Enum.any?(users, fn u -> u.username == username end) do
      IO.puts(String.pad_leading("Username already exists. Please try a different one.", 50, "#"))
      # Return to main loop (auth menu)
      main_loop(contacts, users, nil)
    else
      # Get password from user (in a real app, hash and salt the password!)
      # WARNING: Storing password in plain text!
      password = get_input("Enter a password: ")

      # Create a new user map
      new_user = %{username: username, password: password}

      # Add the new user to the users list
      new_users = users ++ [new_user]

      # Save the updated users list to the file
      case save_users(new_users) do
        :ok ->
          IO.puts(String.pad_leading(" User Registered Successfully", 50, "#"))
          # Return to main loop (auth menu)
          main_loop(contacts, new_users, nil)

        {:error, reason} ->
          IO.puts(
            String.pad_leading("An error occurred while saving user data: #{reason}", 50, "#")
          )

          # Return to main loop with original users data if saving failed
          main_loop(contacts, users, nil)
      end
    end
  end

  # Logs in an existing user
  defp login(contacts, users) do
    IO.puts(String.pad_leading(" User Login ", 50, "#"))

    # Get username from user
    username = get_input("Enter your username: ")
    # Get password from user
    password = get_input("Enter your password: ")

    # Find the user with the matching username and password
    # WARNING: Plain text password check! Use secure hashing in production.
    authenticated_user =
      Enum.find(users, fn u -> u.username == username && u.password == password end)

    case authenticated_user do
      # If no user found or password incorrect
      nil ->
        IO.puts(String.pad_leading("Invalid username or password.", 50, "#"))
        # Return to main loop (auth menu)
        main_loop(contacts, users, nil)

      # If user found and authenticated
      user ->
        IO.puts(String.pad_leading(" Welcome, #{user.username}!", 50, "#"))
        # Start the main loop in a post-login state with the current user's username
        main_loop(contacts, users, user.username)
    end
  end

  # Logs out the current user
  defp logout(contacts, users) do
    IO.puts(String.pad_leading(" Logged out successfully.", 50, "#"))
    # Return to the main loop in a pre-login state
    main_loop(contacts, users, nil)
  end

  # --- Contact Management Functions (require current_user) ---

  # Adds a new contact for the current user with a review step
  defp create(contacts, users, current_user) do
    IO.puts(String.pad_leading(" Add Contact ", 50, "#"))

    # Get contact details from user input
    first_name = get_input("Your First Name (or type '*' to return to main menu): ")
    # If user typed '*', return to main menu
    if first_name == "*", do: main_loop(contacts, users, current_user)

    last_name = get_input("Your Last Name (or type '*' to return to main menu): ")
    # If user typed '*', return to main menu
    if last_name == "*", do: main_loop(contacts, users, current_user)

    contact_num = get_input("Your Contact (or type '*' to return to main menu): ")
    # If user typed '*', return to main menu
    if contact_num == "*", do: main_loop(contacts, users, current_user)

    email = get_input("Your Email (or type '*' to return to main menu): ")
    # If user typed '*', return to main menu
    if email == "*", do: main_loop(contacts, users, current_user)

    # Store the collected details in a map
    new_contact_details = %{
      first_name: first_name,
      last_name: last_name,
      contact: contact_num,
      email: email
    }

    # Proceed to the review/save menu
    review_new_contact(new_contact_details, contacts, users, current_user)
  end

  # Displays the summary of the new contact and the options to save, edit, or cancel.
  defp review_new_contact(contact_details, contacts, users, current_user) do
    IO.puts(String.pad_leading(" Summary ", 50, "-"))
    IO.puts("First Name: #{contact_details.first_name}")
    IO.puts("Last Name: #{contact_details.last_name}")
    IO.puts("Phone Number: #{contact_details.contact}") # Assuming 'contact' is phone number
    IO.puts("Email: #{contact_details.email}")
    IO.puts(String.pad_leading("", 50, "-"))

    IO.puts("\nWhat would you like to do next?")
    IO.puts("1. Save Contact")
    IO.puts("2. Edit Details")
    IO.puts("3. Cancel and Return to Main Menu")

    # Read user input for the menu choice
    case IO.gets("Select from the options above: ") |> String.trim() do
      "1" -> save_new_contact(contact_details, contacts, users, current_user) # Save the contact
      "2" -> edit_new_contact_details(contact_details, contacts, users, current_user) # Edit the details
      "3" ->
        IO.puts(String.pad_leading(" Contact creation cancelled.", 50, "#"))
        main_loop(contacts, users, current_user) # Cancel and return to main menu
      _ ->
        IO.puts(String.pad_leading("Invalid option. Please select a valid option.", 50, "#"))
        review_new_contact(contact_details, contacts, users, current_user) # Re-prompt for menu choice
    end
  end

  # Saves the new contact to the file.
  defp save_new_contact(contact_details, contacts, users, current_user) do
    # Determine the next entry number for THIS USER's contacts
    user_contacts = Enum.filter(contacts, fn c -> c.user == current_user end)

    next_entry =
      if Enum.empty?(user_contacts) do
        # If this user has no contacts, start with 1
        1
      else
        # Find the maximum entry number for this user and add 1
        Enum.max_by(user_contacts, fn c -> c.entry end).entry + 1
      end

    # Create a new contact map, including the current user's username and the new entry number
    new_contact = %{
      user: current_user, # Associate contact with the current user's username
      entry: next_entry, # User-specific entry number
      first_name: contact_details.first_name,
      last_name: contact_details.last_name,
      contact: contact_details.contact,
      email: contact_details.email
    }

    # Add the new contact to the database list
    new_contacts = contacts ++ [new_contact]

    # Save the updated database to the file
    case save_contacts(new_contacts) do
      :ok ->
        IO.puts(String.pad_leading(" Contact Successfully Added", 50, "#"))
        # Display the updated list of contacts for the current user
        display_contacts(Enum.filter(new_contacts, fn c -> c.user == current_user end))
        # Return to the main loop (contact menu)
        main_loop(new_contacts, users, current_user)

      {:error, reason} ->
        IO.puts(String.pad_leading("An error occurred while saving contact: #{reason}", 50, "#"))
        # Return to the main loop with the original database if saving failed
        main_loop(contacts, users, current_user)
    end
  end

  # Allows the user to edit the details of the contact they are currently creating.
  defp edit_new_contact_details(current_details, contacts, users, current_user) do
    IO.puts(String.pad_leading(" Edit New Contact Details ", 50, "#"))

    # Get updated details, allowing blank input to keep existing value
    # We'll pass the current value to get_input for display, but it doesn't pre-fill
    updated_first_name = get_input("Update First Name (leave blank for no change, '*' to cancel, current: #{current_details.first_name}): ")
    if updated_first_name == "*", do: main_loop(contacts, users, current_user)

    updated_last_name = get_input("Update Last Name (leave blank for no change, '*' to cancel, current: #{current_details.last_name}): ")
    if updated_last_name == "*", do: main_loop(contacts, users, current_user)

    updated_contact_num = get_input("Update Contact (leave blank for no change, '*' to cancel, current: #{current_details.contact}): ")
    if updated_contact_num == "*", do: main_loop(contacts, users, current_user)

    updated_email = get_input("Update Email (leave blank for no change, '*' to cancel, current: #{current_details.email}): ")
    if updated_email == "*", do: main_loop(contacts, users, current_user)

    # Create a new map with updated details, keeping existing if input was blank
    updated_details = %{
      first_name: if(updated_first_name != "", do: updated_first_name, else: current_details.first_name),
      last_name: if(updated_last_name != "", do: updated_last_name, else: current_details.last_name),
      contact: if(updated_contact_num != "", do: updated_contact_num, else: current_details.contact),
      email: if(updated_email != "", do: updated_email, else: current_details.email)
    }

    # Return to the review menu with the updated details
    review_new_contact(updated_details, contacts, users, current_user)
  end


  # Edits an existing contact for the current user
  defp edit(contacts, users, current_user) do
    # Filter contacts to only show the current user's contacts
    user_contacts = Enum.filter(contacts, fn c -> c.user == current_user end)

    # Check if the user has any contacts
    if Enum.empty?(user_contacts) do
      IO.puts(String.pad_leading(" You have no records ", 50, "#"))
      # Return to the main loop (contact menu)
      main_loop(contacts, users, current_user)
    else
      IO.puts(String.pad_leading(" Edit Contact ", 50, "#"))
      # Display current user's contacts for selection
      display_contacts(user_contacts)

      # Get the entry number to edit from the user
      edit_input =
        get_input("Select from the options above to edit (or type '*' to return to main menu): ")

      # If user typed '*', return to main menu
      if edit_input == "*", do: main_loop(contacts, users, current_user)

      # Attempt to parse the input as an integer
      case Integer.parse(edit_input) do
        {entry_to_edit, _} ->
          # Find the contact with the matching entry number *for the current user*
          contact_to_edit = Enum.find(user_contacts, fn c -> c.entry == entry_to_edit end)

          case contact_to_edit do
            # If no contact found with that entry number for this user
            nil ->
              IO.puts(String.pad_leading("Invalid selection. Please try again.", 50, "#"))
              # Call edit again to re-prompt
              edit(contacts, users, current_user)

            # If contact found
            _ ->
              IO.puts(String.pad_leading(" You have selected ", 50, "#"))
              # Display the selected contact
              display_contact(contact_to_edit)

              IO.puts(String.pad_leading(" Update Contact ", 50, "#"))

              # Get updated first name
              updated_first_name =
                get_input("Update First Name (leave blank for no change, '*' to cancel): ")

              if updated_first_name == "*", do: main_loop(contacts, users, current_user)

              # Get updated last name
              updated_last_name =
                get_input("Update Last Name (leave blank for no change, '*' to cancel): ")

              if updated_last_name == "*", do: main_loop(contacts, users, current_user)

              # Get updated contact number
              updated_contact_num =
                get_input("Update Contact (leave blank for no change, '*' to cancel): ")

              if updated_contact_num == "*", do: main_loop(contacts, users, current_user)

              # Get updated email
              updated_email = get_input("Update Email (leave blank for no change, '*' to cancel): ")
              if updated_email == "*", do: main_loop(contacts, users, current_user)

              # Create the updated contact map (keep the original user and entry)
              updated_contact = %{
                user: contact_to_edit.user,
                entry: contact_to_edit.entry,
                first_name: if(updated_first_name != "", do: updated_first_name, else: contact_to_edit.first_name),
                last_name: if(updated_last_name != "", do: updated_last_name, else: contact_to_edit.last_name),
                contact: if(updated_contact_num != "", do: updated_contact_num, else: contact_to_edit.contact),
                email: if(updated_email != "", do: updated_email, else: contact_to_edit.email)
              }

              # Find the index of the original contact in the full database
              original_contact_index =
                Enum.find_index(contacts, fn c ->
                  c.user == contact_to_edit.user && c.entry == contact_to_edit.entry
                end)

              # Replace the old contact with the updated one in the full database list
              new_contacts = List.replace_at(contacts, original_contact_index, updated_contact)

              # Save the updated database
              case save_contacts(new_contacts) do
                :ok ->
                  IO.puts(String.pad_leading(" Contact Updated Successfully", 50, "#"))
                  # Display the updated list for the current user
                  display_contacts(Enum.filter(new_contacts, fn c -> c.user == current_user end))
                  # Return to main loop
                  main_loop(new_contacts, users, current_user)

                {:error, reason} ->
                  IO.puts(
                    String.pad_leading(
                      "An error occurred while saving contact: #{reason}",
                      50,
                      "#"
                    )
                  )

                  # Return to main loop with original database if saving failed
                  main_loop(contacts, users, current_user)
              end
          end

        # If input was not a valid integer
        :error ->
          IO.puts(String.pad_leading("Invalid selection. Please try again.", 50, "#"))
          # Call edit again to re-prompt
          edit(contacts, users, current_user)
      end
    end
  end

  # Views all contacts for the current user
  defp view(user_contacts, contacts, users, current_user) do
    # Check if the user has any contacts
    if Enum.empty?(user_contacts) do
      IO.puts(String.pad_leading(" You have no records", 50, "#"))
      # Return to the main loop (contact menu)
      main_loop(contacts, users, current_user)
    else
      IO.puts(String.pad_leading(" All your stored contacts ", 50, "#"))
      # Display the current user's contacts
      display_contacts(user_contacts)
      # Return to the main loop (contact menu)
      main_loop(contacts, users, current_user)
    end
  end

  # Deletes a contact for the current user
  defp delete(contacts, users, current_user) do
    # Filter contacts to only show the current user's contacts
    user_contacts = Enum.filter(contacts, fn c -> c.user == current_user end)

    # Check if the user has any contacts
    if Enum.empty?(user_contacts) do
      IO.puts(String.pad_leading(" You have no records ", 50, "#"))
      # Return to the main loop (contact menu)
      main_loop(contacts, users, current_user)
    else
      IO.puts(String.pad_leading(" Delete contacts ", 50, "#"))
      # Display current user's contacts for selection
      display_contacts(user_contacts)

      # Get the entry number to delete from the user
      delete_input =
        get_input(
          "Select from the options above to delete (or type '*' to return to main menu): "
        )

      # If user typed '*', return to main menu
      if delete_input == "*", do: main_loop(contacts, users, current_user)

      # Attempt to parse the input as an integer
      case Integer.parse(delete_input) do
        {entry_to_delete, _} ->
          # Find the contact with the matching entry number *for the current user*
          contact_to_delete = Enum.find(user_contacts, fn c -> c.entry == entry_to_delete end)

          case contact_to_delete do
            # If no contact found with that entry number for this user
            nil ->
              IO.puts(String.pad_leading("Invalid selection. Please try again.", 50, "#"))
              # Call delete again to re-prompt
              delete(contacts, users, current_user)

            # If contact found
            _ ->
              IO.puts(String.pad_leading(" You have selected ", 50, "#"))
              # Display the selected contact
              display_contact(contact_to_delete)

              # Find the index of the contact in the full database
              contact_index_in_full_db =
                Enum.find_index(contacts, fn c ->
                  c.user == contact_to_delete.user && c.entry == contact_to_delete.entry
                end)

              # Remove the contact from the full database list
              contacts_after_delete = List.delete_at(contacts, contact_index_in_full_db)

              # Re-index the remaining contacts *for the current user*
              remaining_user_contacts =
                Enum.filter(contacts_after_delete, fn c -> c.user == current_user end)

              reindexed_user_contacts =
                Enum.map(remaining_user_contacts, fn contact ->
                  %{
                    contact
                    | entry:
                        Enum.find_index(remaining_user_contacts, fn c -> c == contact end) + 1
                  }
                end)

              # Create the final database by removing the old user contacts and adding the re-indexed ones
              contacts_without_user_contacts =
                Enum.reject(contacts_after_delete, fn c -> c.user == current_user end)

              final_contacts = contacts_without_user_contacts ++ reindexed_user_contacts

              # Save the updated database
              case save_contacts(final_contacts) do
                :ok ->
                  IO.puts(String.pad_leading(" Contact Successfully deleted ", 50, "#"))
                  # Display the remaining contacts for the current user
                  # Pass the reindexed list to view for display purposes
                  view(reindexed_user_contacts, final_contacts, users, current_user)

                {:error, reason} ->
                  IO.puts(
                    String.pad_leading(
                      "An error occurred while saving contact: #{reason}",
                      50,
                      "#"
                    )
                  )

                  # Return to main loop with original database if saving failed
                  main_loop(contacts, users, current_user)
              end
          end

        # If input was not a valid integer
        :error ->
          IO.puts(String.pad_leading("Invalid selection. Please try again.", 50, "#"))
          # Call delete again to re-prompt
          delete(contacts, users, current_user)
      end
    end
  end

  # Searches contacts for the current user based on a search term. (New Feature)
  defp search(contacts, users, current_user) do
    IO.puts(String.pad_leading(" Search Contacts ", 50, "#"))

    search_term = get_input("Enter search term (or type '*' to return to main menu): ")
    if search_term == "*", do: main_loop(contacts, users, current_user) # Return if '*' entered

    # Filter contacts to only search within the current user's contacts
    user_contacts = Enum.filter(contacts, fn c -> c.user == current_user end)

    # Filter user contacts based on the search term (case-insensitive)
    filtered_contacts = Enum.filter(user_contacts, fn contact ->
      String.contains?(String.downcase(contact.first_name), String.downcase(search_term)) ||
      String.contains?(String.downcase(contact.last_name), String.downcase(search_term)) ||
      String.contains?(String.downcase(contact.contact), String.downcase(search_term)) ||
      String.contains?(String.downcase(contact.email), String.downcase(search_term))
    end)

    # Display results
    if Enum.empty?(filtered_contacts) do
      IO.puts(String.pad_leading(" No contacts found matching '#{search_term}'", 50, "#"))
    else
      IO.puts(String.pad_leading(" Search Results for '#{search_term}' ", 50, "#"))
      display_contacts(filtered_contacts)
    end

    main_loop(contacts, users, current_user) # Return to the contact management menu
  end


  # Ends the application session
  defp end_session do
    IO.puts(String.pad_leading(" Session Ended. Hope to see you soon.", 50, "#"))
    # Exit the application
    System.halt(0)
  end

  # --- File I/O ---

  # Loads contacts from the file
  # Parses the custom key=value format
  defp load_contacts do
    # Check if the file exists
    if File.exists?(@contacts_file_name) do
      # Read the file content
      case File.read(@contacts_file_name) do
        {:ok, content} ->
          # Split the content into entries based on double newlines
          content
          |> String.split("\n\n", trim: true)
          |> Enum.map(fn entry_string ->
            # Split each entry into lines
            entry_string
            |> String.split("\n", trim: true)
            |> Enum.reduce(%{}, fn line, acc ->
              # Split each line into key and value
              [key, value] = String.split(line, "=", parts: 2) |> Enum.map(&String.trim/1)
              # Convert entry key to integer, otherwise keep as string
              parsed_value = if key == "entry", do: String.to_integer(value), else: value
              # Add key-value pair to the accumulator map, convert key to atom
              Map.put(acc, String.to_atom(key), parsed_value)
            end)
          end)

        {:error, reason} ->
          IO.puts("Error reading contacts file: #{reason}")
          # Return empty list if there's an error reading
          []
      end
    else
      # Return empty list if file doesn't exist
      []
    end
  end

  # Saves contacts to the file
  # Formats the list of contact maps into the custom key=value format
  defp save_contacts(contacts) do
    # Format the database into a string suitable for writing to the file
    formatted_data =
      Enum.map(contacts, fn contact ->
        # Format each contact as key=value pairs separated by newlines
        # Ensure the 'user' field is included
        """
        user = #{contact.user}
        entry = #{contact.entry}
        first_name = #{contact.first_name}
        last_name = #{contact.last_name}
        contact = #{contact.contact}
        email = #{contact.email}
        """
      end)
      # Join the formatted contacts with double newlines
      |> Enum.join("\n")

    # Ensure directory exists before writing
    File.mkdir_p("database")
    # Write the formatted data to the file
    File.write(@contacts_file_name, formatted_data)
  end

  # Loads users from the file
  # Parses the custom key=value format
  defp load_users do
    # Check if the file exists
    if File.exists?(@users_file_name) do
      # Read the file content
      case File.read(@users_file_name) do
        {:ok, content} ->
          # Split the content into user entries based on double newlines
          content
          |> String.split("\n\n", trim: true)
          |> Enum.map(fn user_string ->
            # Split each user entry into lines
            user_string
            |> String.split("\n", trim: true)
            |> Enum.reduce(%{}, fn line, acc ->
              # Split each line into key and value
              [key, value] = String.split(line, "=", parts: 2) |> Enum.map(&String.trim/1)
              # Add key-value pair to the accumulator map, convert key to atom
              Map.put(acc, String.to_atom(key), value)
            end)
          end)

        {:error, reason} ->
          IO.puts("Error reading users file: #{reason}")
          # Return empty list if there's an error reading
          []
      end
    else
      # Return empty list if file doesn't exist
      []
    end
  end

  # Saves users to the file
  # Formats the list of user maps into the custom key=value format
  defp save_users(users) do
    # Format the users list into a string suitable for writing to the file
    formatted_data =
      Enum.map(users, fn user ->
        # Format each user as key=value pairs separated by newlines
        # WARNING: Storing password in plain text!
        """
        username = #{user.username}
        password = #{user.password}
        """
      end)
      # Join the formatted users with double newlines
      |> Enum.join("\n")

    # Ensure directory exists before writing
    File.mkdir_p("database")
    # Write the formatted data to the file
    File.write(@users_file_name, formatted_data)
  end

  # --- Helper Functions ---

  # Gets input from the user with a prompt
  defp get_input(prompt) do
    IO.gets(prompt) |> String.trim()
  end

  # Displays a list of contacts
  defp display_contacts(contacts) do
    Enum.each(contacts, fn contact ->
      display_contact(contact)
      # Add an empty line between contacts
      IO.puts("")
    end)
  end

  # Displays a single contact
  defp display_contact(contact) do
    # Note: We don't display the 'user' field here to the user
    IO.puts("entry = #{contact.entry}")
    IO.puts("first_name = #{contact.first_name}")
    IO.puts("last_name = #{contact.last_name}")
    IO.puts("contact = #{contact.contact}")
    IO.puts("email = #{contact.email}")
  end
end
