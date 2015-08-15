defmodule ZServer.Routers.UserRouter do
  use Maru.Router

  namespace :user do
    desc "get user info by id"
    params do
      requires :id, type: String, desc: "user id"
      optional :age, type: Integer, values: 18..65, desc: "age [18-65]"
      optional :sex, type: Atom, values: [:male, :female], default: :male, desc: "male, female"
    end
    get do
      %{ uid: params[:id], age: params[:age], sex: params[:sex] }
    end
  end
end