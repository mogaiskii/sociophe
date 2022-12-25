defmodule SociopheWeb.HelloView do
  use SociopheWeb, :view
  @type data() :: Map.t()

  @spec render(data()) :: data()
  def render("index.json", %{data: data}) do
    %{secret_is: data}
  end
end
