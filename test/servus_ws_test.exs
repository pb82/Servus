defmodule ServusWSTest do
  use ExUnit.Case
  alias Servus.Serverutils
  alias Servus.Message
  alias Socket.Web

  setup_all do
    socket_alice = Web.connect! "localhost", 3335
    socket_bob = Web.connect! "localhost", 3335

    {:ok, [
      alice: %{raw: socket_alice, type: :web},
      bob: %{raw: socket_bob, type: :web}
    ]}
  end

  test "integration test (WebSocket)", context do
    # Alice joins the game by sending the 'join'
    # message
    assert :ok == Serverutils.send(context.alice, "join", "alice")

    # Make sure that Bob's message will be second
    :timer.sleep(100)

    # Bob joins the game by sending a `join`message
    assert :ok == Serverutils.send(context.bob, "join", "bob")

    assert(
      %Message{type: "start", value: "bob", target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )

    assert(
      %Message{type: "start", value: "alice", target: nil} == 
      Serverutils.recv(context.bob, parse: true)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true)
    )

    # Bob turn
    assert :ok == Serverutils.send(context.bob, "put", 2)

    assert(
      %Message{type: "set", value: 2, target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )

    # Alice turn
    assert :ok == Serverutils.send(context.alice, "put", 4)

    assert(
      %Message{type: "set", value: 4, target: nil} == 
      Serverutils.recv(context.bob, parse: true)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true)
    )

    # Bob turn
    assert :ok == Serverutils.send(context.bob, "put", 3)

    assert(
      %Message{type: "set", value: 3, target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )
    
    # Alice turn
    assert :ok == Serverutils.send(context.alice, "put", 4)

    assert(
      %Message{type: "set", value: 4, target: nil} == 
      Serverutils.recv(context.bob, parse: true)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true)
    )

    # Bob turn
    assert :ok == Serverutils.send(context.bob, "put", 3)

    assert(
      %Message{type: "set", value: 3, target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )

    # Alice turn
    assert :ok == Serverutils.send(context.alice, "put", 4)

    assert(
      %Message{type: "set", value: 4, target: nil} == 
      Serverutils.recv(context.bob, parse: true)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true)
    )

    # Bob turn
    assert :ok == Serverutils.send(context.bob, "put", 3)

    assert(
      %Message{type: "set", value: 3, target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )

    # Alice turn
    assert :ok == Serverutils.send(context.alice, "put", 4)

    assert(
      %Message{type: "win", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true)
    )

    assert(
      %Message{type: "loose", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true)
    )
  end
end
