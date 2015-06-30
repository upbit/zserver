defmodule UserRouter do
  use Maru.Router

  # defmodule UserEntity do
  #   def serialize(user, _opts) do
  #     user
  #   end
  # end

  namespace :user do
    params do
      requires :id, type: String
      requires :age, type: Integer, values: 18..65
      requires :sex, type: Atom, values: [:male, :female], default: :male
    end
    get do
      user = %{ uid: params[:id], age: params[:age], sex: params[:sex] }
      #present user, with: UserEntity
    end
  end
end