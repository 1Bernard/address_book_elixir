# Simple Elixir CLI Address Book

A basic command-line application in Elixir for managing personal contacts with multi-user support and file-based persistence. This project serves as an educational resource for new Elixir developers to learn fundamental concepts by exploring a functional example.

**WARNING:** This application stores user passwords in plain text for simplicity and educational purposes. **DO NOT** use this code in any production environment. Secure password handling (hashing and salting) is essential for real-world applications.

## Features

* User Registration
* User Login/Logout
* Add New Contacts (per user)
* Edit Existing Contacts (per user)
* View All Contacts (for the logged-in user)
* Delete Contacts (per user)
* Search Contacts (by name, number, or email for the logged-in user)
* Data persistence to local text files (`database/contacts.txt` and `database/users.txt`).

## How to Run

1.  **Prerequisites:**
    * Elixir and Erlang/OTP installed on your system. You can find installation instructions [here](https://elixir-lang.org/install.html).
2.  **Clone the repository:**
    ```bash
    git clone [https://github.com/1Bernard/address_book_elixir](https://github.com/1Bernard/address_book_elixir)
    cd address_book_elixir
    ```
3.  **Fetch dependencies:**
    ```bash
    mix deps.get
    ```
    This will download `ex_doc`, needed for documentation generation.
4.  **Run the application using Mix:**
    ```bash
    mix run_address_book
    ```
    The application will start, display a welcome message, and present the authentication menu.

## Project Structure

* `.gitignore`: Specifies intentionally untracked files that Git should ignore (like our data files).
* `README.md`: This documentation file you are reading.
* `LICENSE`: Contains the terms under which the project is licensed (e.g., MIT).
* `mix.exs`: Elixir project configuration file, defining dependencies, tasks, etc.
* `lib/`: Contains the core Elixir source code.
    * `address_book.ex`: The main `AddressBook` module with all application logic.
    * `mix/`: Directory for custom Mix tasks.
        * `tasks/`: Directory for custom Mix tasks.
            * `run_address_book.ex`: The `Mix.Tasks.RunAddressBook` module, the application's entry point via `mix`.
* `database/`: This directory will be automatically created the first time you run the application.
    * `contacts.txt`: Stores contact data in a custom text format.
    * `users.txt`: Stores user data in a custom text format (includes plain text passwords - see WARNING).

## Code Overview and Key Concepts for Learning

This application is designed to demonstrate several core Elixir and functional programming concepts:

1.  **Modules and Functions:** The code is organized into logical units (`AddressBook`, `Mix.Tasks.RunAddressBook`). Explore how functions are defined (`def`, `defp`) and called. Pay attention to the `@moduledoc` and `@doc` attributes used for documentation.
2.  **State Management with Recursion:** Notice the `AddressBook.main_loop/3` function. Instead of mutable state and imperative loops, the application state (the current lists of `contacts`, `users`, and the `current_user`) is passed as arguments in recursive function calls. This is a common functional pattern for managing state in long-running processes or simple state machines.
3.  **Pattern Matching and `case` Expressions:** Observe how `case` expressions and pattern matching are used extensively to handle different user inputs (`"1"`, `"2"`, etc.) and function return values (e.g., `{:ok, content}`, `{:error, reason}` from file operations).
4.  **Data Structures (Maps and Lists):** Contacts and users are represented as Elixir Maps (`%{}`, although not formal structs here). Collections of contacts and users are managed as Lists (`[]`). The `Enum` module is used to work with these lists.
5.  **The `Enum` Module:** Elixir's `Enum` module provides powerful functions for working with collections (lists, maps, etc.). See examples of `Enum.map`, `Enum.filter`, `Enum.find`, `Enum.reduce`, `Enum.any?`, `Enum.empty?`, `Enum.max_by`, `Enum.find_index`, `Enum.reject` for data manipulation and querying.
6.  **The `String` Module:** Learn how `String.trim`, `String.split`, `String.to_atom`, `String.to_integer`, `String.downcase`, `String.contains?` are used for input processing, data formatting, and searching.
7.  **File I/O (`File` module):** The application uses the `File` module to read from (`File.read/1`) and write to (`File.write/2`) the data files. Pay attention to how file operation results are handled using `{:ok, ...}` and `{:error, ...}` tuples. `File.exists?/1` checks if a file is present, and `File.mkdir_p/1` ensures directories exist.
8.  **User Interaction (`IO` module):** `IO.gets/1` is used to get input from the user (including handling the `:eof` case for Ctrl+D), and `IO.puts/1` is used to display output.

## Data Format

The application uses a simple custom text format to store data in `database/contacts.txt` and `database/users.txt`. Each record (contact or user) is represented by `key = value` pairs on separate lines, and records are separated by a double newline (`\n\n`).

Example `database/contacts.txt`:

user = alice\
entry = 1\
first_name = Bob\
last_name = Smith\
contact = 123-456-7890\
email = bob.smith@example.com

user = alice\
entry = 2\
first_name = Charlie\
last_name = Brown\
contact = 555-123-4567\
email = charlie.b@peanuts.com

user = bob\
entry = 1\
first_name = Alice\
last_name = Wonderland\
contact = 987-654-3210\
email = alice@example.com


Example `database/users.txt`:

username = alice\
password = plain_password_1

username = bob\
password = plain_password_2


**Note:** This format is easy to read and write for this simple application but is not robust for complex data, concurrent access, or large datasets. It's also highly insecure for storing passwords.

## Generating HTML Documentation

The code includes `@moduledoc` and `@doc` attributes. You can generate browsable HTML documentation from these comments using `ExDoc`:

1.  Make sure you have fetched dependencies (`mix deps.get`).
2.  Run the documentation task:
    ```bash
    mix docs
    ```
3.  Open the generated documentation in your web browser by opening the file `doc/index.html`.

**Alternatively, you can view the deployed documentation online:** [https://1bernard.github.io/address_book_elixir/readme.html](https://1bernard.github.io/address_book_elixir/readme.html)

## Areas for Improvement and Further Learning

This application can be extended and improved in many ways. Consider implementing some of these to further practice your Elixir skills:

* **Security:** **Implement secure password hashing** (e.g., using the `bcrypt_elixir` library) instead of plain text storage and comparison.
* **Data Validation:** Add validation to ensure contact details (like email format or phone number) are valid before saving.
* **Error Handling:** Make the error handling more sophisticated, perhaps providing more user-friendly messages for specific issues or logging errors to a file.
* **Data Storage:** Replace the simple file storage with a more robust solution like:
    * [ETS (Erlang Term Storage)](https://www.erlang.org/doc/man/ets.html) for faster in-memory storage (though data would not persist after the application stops unless explicitly saved/loaded).
    * A lightweight database like SQLite using an Elixir library (e.g., `sqlite_ecto2`).
    * A proper database like PostgreSQL or MySQL using Ecto, Elixir's database wrapper.
* **Concurrency:** How would you handle multiple processes or users accessing the data simultaneously without file locking issues? (This simple app is single-process).
* **More Features:** Add sorting contacts by name, filtering by other criteria, exporting contacts to a different format (like CSV), importing contacts.
* **Testing:** Write unit tests for your functions, especially the data loading, saving, and contact management logic.
* **Supervisors:** If evolving into a more complex application structure, introduce supervisors to manage and restart processes that might crash.

## Getting Started as a New Team Member

This project is your starting point for learning Elixir CLI development. Here's a suggested path:

1.  **Get it Running:** Follow the "How to Run" instructions above to ensure you can start and interact with the application. Register a user and add some contacts. Observe how the `database/` directory and files are created.
2.  **Explore the Code:** Read through `lib/address_book.ex` and `lib/mix/tasks/run_address_book.ex`. Use the inline `@moduledoc` and `@doc` comments directly in your editor, or generate the HTML documentation (`mix docs`) and browse it in your web browser.
3.  **Trace Execution:** As you interact with the running application, try to follow the code path in your editor. For example, choose "1" from the contact menu ("Add Contact") and trace how `handle_contact_action` calls `create`, which then calls `get_input` multiple times, and finally leads to `review_new_contact` and `save_new_contact`.
4.  **Identify Key Patterns:** Look for the recurring patterns like state passing in `main_loop`, `case` statements for handling different outcomes (input, file operations), and `Enum` functions for list manipulation.
5.  **Implement an Improvement:** Pick one item from the "Areas for Improvement" list (e.g., add basic validation to ensure the email address input contains "@" and ".") and try to implement it. This hands-on practice is invaluable.
6.  **Build Your Own:** Once you feel comfortable, try starting a new Mix project (`mix new my_cli_app`) and build something similar but different (e.g., a task tracker, a simple inventory), using this project as a reference and template for structure, state management, and file I/O.

## License

This project is open-source under the [MIT License](LICENSE).

## Contributing

(Optional section: If you want to accept contributions from team members for improving this example)
