defmodule ServusTest do
  use ExUnit.Case
  alias Servus.Serverutils
  alias Servus.Message

  setup_all do
    connect_opts = [
      :binary,
      packet: 4,
      active: false,
      reuseaddr: true
    ]

    {:ok, socket_alice} = :gen_tcp.connect('localhost', 3334, connect_opts)
    {:ok, socket_bob} = :gen_tcp.connect('localhost', 3334, connect_opts)
    {:ok, [
      alice: %{raw: socket_alice, type: :tcp},
      bob: %{raw: socket_bob, type: :tcp}
    ]}
  end

  test "integration test (gameplay simulation with two players)", context do
    # Alice joins the game by sending the 'join'
    # message
    assert :ok == Serverutils.send(context.alice, "join", "alice")

    # Make sure that Bob's message will be second
    :timer.sleep(100)

    # Bob joins the game by sending a `join`message
    assert :ok == Serverutils.send(context.bob, "join", "bob")

    assert(
      %Message{type: "start", value: "bob", target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "start", value: "alice", target: nil} == 
      Serverutils.recv(context.bob, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true, timeout: 100)
    )

    # Bob turn
    assert :ok == Serverutils.send(context.bob, "put", 2)

    assert(
      %Message{type: "set", value: 2, target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )

    # Alice turn
    assert :ok == Serverutils.send(context.alice, "put", 4)

    assert(
      %Message{type: "set", value: 4, target: nil} == 
      Serverutils.recv(context.bob, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true, timeout: 100)
    )

    # Bob turn
    assert :ok == Serverutils.send(context.bob, "put", 3)

    assert(
      %Message{type: "set", value: 3, target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )
    
    # Alice turn
    assert :ok == Serverutils.send(context.alice, "put", 4)

    assert(
      %Message{type: "set", value: 4, target: nil} == 
      Serverutils.recv(context.bob, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true, timeout: 100)
    )

    # Bob turn
    assert :ok == Serverutils.send(context.bob, "put", 3)

    assert(
      %Message{type: "set", value: 3, target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )

    # Alice turn
    assert :ok == Serverutils.send(context.alice, "put", 4)

    assert(
      %Message{type: "set", value: 4, target: nil} == 
      Serverutils.recv(context.bob, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true, timeout: 100)
    )

    # Bob turn
    assert :ok == Serverutils.send(context.bob, "put", 3)

    assert(
      %Message{type: "set", value: 3, target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "turn", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )

    # Alice turn
    assert :ok == Serverutils.send(context.alice, "put", 4)

    assert(
      %Message{type: "win", value: nil, target: nil} == 
      Serverutils.recv(context.alice, parse: true, timeout: 100)
    )

    assert(
      %Message{type: "loose", value: nil, target: nil} == 
      Serverutils.recv(context.bob, parse: true, timeout: 100)
    )
  end
end
