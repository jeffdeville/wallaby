defmodule Wallaby.Element do
  @moduledoc """
  Defines an Element Struct and interactions with Elements.

  Typically these functions are used in conjunction with a `find`:

  ```
  page
  |> find(Query.css(".some-element"), fn(element) -> Element.click(element) end)
  ```

  These functions can be used to create new actions specific to your application:

  ```
  def create_todo(todo_field, todo_text) do
    todo_field
    |> Element.click()
    |> Element.fill_in(with: todo_text)
    |> Element.send_keys([:enter])
  end
  ```

  ## Retrying

  Unlike `Browser` the actions in `Element` do not retry if the element becomes stale. Instead an exception will be raised.
  """

  defstruct [:url, :session_url, :parent, :id, :driver, screenshots: []]

  @opaque value :: String.t | number()

  @type attr :: String.t
  @type keys_to_send :: String.t | list(atom | String.t)
  @type t :: %__MODULE__{
    session_url: String.t,
    url: String.t,
    id: String.t,
    screenshots: list,
    driver: module,
  }

  @doc """
  Clears any value set in the element.
  """
  @spec clear(t) :: t

  def clear(%__MODULE__{driver: driver} = element) do
    case driver.clear(element) do
      {:ok, _} ->
        element
      {:error, :stale_reference} ->
        raise Wallaby.StaleReferenceException
      {:error, :invalid_selector} ->
        raise Wallaby.InvalidSelector
    end
  end

  @doc """
  Fills in the element with the specified value.
  """
  @spec fill_in(t, with: String.t | number()) :: t

  def fill_in(element, with: value) when is_number(value) do
    fill_in(element, with: to_string(value))
  end
  def fill_in(element, with: value) when is_binary(value) do
    element
    |> clear
    |> set_value(value)
  end

  @doc """
  Clicks the element.
  """
  @spec click(t) :: t

  def click(%__MODULE__{driver: driver} = element) do
    case driver.click(element) do
      {:ok, _} ->
        element
      {:error, :stale_reference} ->
        raise Wallaby.StaleReferenceException
    end
  end

  @doc """
  Returns the text from the element.
  """
  @spec text(t) :: String.t

  def text(%__MODULE__{driver: driver} = element) do
    case driver.text(element) do
      {:ok, text} ->
        text
      {:error, :stale_reference} ->
        raise Wallaby.StaleReferenceException
    end
  end

  @doc """
  Gets the value of the element's attribute.
  """
  @spec attr(t, attr()) :: String.t | nil

  def attr(%__MODULE__{driver: driver} = element, name) do
    case driver.attribute(element, name) do
      {:ok, attribute} ->
        attribute
      {:error, :stale_reference} ->
        raise Wallaby.StaleReferenceException
    end
  end

  @doc """
  Returns a boolean based on whether or not the element is selected.

  ## Note
  This only really makes sense for options, checkboxes, and radio buttons.
  Everything else will simply return false because they have no notion of
  "selected".
  """
  @spec selected?(t) :: boolean()

  def selected?(%__MODULE__{driver: driver} = element) do
    case driver.selected(element) do
      {:ok, value} ->
        value
      {:error, _} ->
        false
    end
  end

  @doc """
  Returns a boolean based on whether or not the element is visible.
  """
  @spec visible?(t) :: boolean()

  def visible?(%__MODULE__{driver: driver} = element) do
    case driver.displayed(element) do
      {:ok, value} ->
        value
      {:error, _} ->
        false
    end
  end

  @doc """
  Sets the value of the element.
  """
  @spec set_value(t, value()) :: t

  def set_value(%__MODULE__{driver: driver} = element, value) do
    case driver.set_value(element, value) do
      {:ok, _} ->
        element
      {:error, :stale_reference} ->
        raise Wallaby.StaleReferenceException
      e -> e
    end
  end

  @doc """
  Sends keys to the element.
  """
  @spec send_keys(t, keys_to_send) :: t

  def send_keys(element, text) when is_binary(text) do
    send_keys(element, [text])
  end
  def send_keys(%__MODULE{driver: driver} = element, keys) when is_list(keys) do
    case driver.send_keys(element, keys) do
      {:ok, _} ->
        element
      {:error, :stale_reference} ->
        raise Wallaby.StaleReferenceException
      e -> e
    end
  end

  @doc """
  Matches the Element's value with the provided value.
  """
  @spec value(t) :: String.t

  def value(element) do
    attr(element, "value")
  end
end
