defmodule PlayerTest do
defmodule PlayerTest do
  use ExUnit.Case
  alias Servus.Serverutils
  #alias Servus.Message

  require Logger

  #setup_all do
  
  #end

  test "unitest"#, context
   do
    # Alice joins the game by sending the 'join'
    # message
    assert :ok == Serverutils.call("player", "reg_with_facebook", %{facebook_name: "Test", facebook_token: "12345542", facebook_id: "XYZTT", facebook_mail: "Test@test.de"})
    assert :ok == Serverutils.call("player", "select_facebook", %{facebook_id: "XYZTT"})
    # Make sure that Bob's message will be second
    #:timer.sleep(100)

    # Bob joins the game by sending a `join`message
    #assert :ok == Serverutils.send(context.bob, "join", "bob")

    #assert(
    #  %Message{type: "start", value: "bob", target: nil} == 
    #  Serverutils.recv(context.alice, parse: true, timeout: 100)
    #)
  end
end
