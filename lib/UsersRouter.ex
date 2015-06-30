defmodule UsersRouter do
  use Maru.Router

  # defmodule UserEntity do
  #   def serialize(payload, _opts) do
  #     %{name: payload[:id], age: payload[:age]}
  #   end
  # end

  namespace :user do
    route_param :id do
      params do
        requires :age, type: Integer, values: 18..65
      end
      get do
        #present %{ user: params[:id], age: params[:age] }, with: UserEntity
        %{ user: params[:id], age: params[:age] } |> json
      end
    end
  end
end