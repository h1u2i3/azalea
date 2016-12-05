# Azalea

Azalea is aim to make upload file in Phoenix easy.
It is still in development.

## Installation

1. Add `azalea` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:azalea, github: "h1u2i3/azalea"]
  end
  ```

2. Ensure `azalea` is started before your application:

  ```elixir
  def application do
    [applications: [:azalea]]
  end
  ```

## The upload steps
1. Normally we can get a file from `Plug`,
it is a `Plug.Upload`([see the guide](http://www.phoenixframework.org/docs/file-uploads)).

    ```elixir
    %Plug.Upload{
      content_type: "image/jpg",
      filename: "demo.jpg",
      path: "/tmp/file/path"}
    }
    ```
first we should check the file with the checker you define to make sure we get
the file we want.

2. Do some work with the file or file data (background). You can define what you want.

3. Save to the target disk you supply, or save to cloud (background).

4. Generate the needed data (with the data we can read from the database and
   then we can get the file link) and save to database.
