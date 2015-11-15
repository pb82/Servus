defmodule ServusTest do
  use ExUnit.Case

  setup_all do
    {:ok, socket_alice} = :gen_tcp.connect('localhost', 3334, active: false)
    {:ok, socket_bob} = :gen_tcp.connect('localhost', 3334, active: false)
    {:ok, [
      alice: socket_alice,
      bob: socket_bob
    ]}
  end

  test "integration test (gameplay simulation with two players)", context do
    # Alice joins the game by sending the 'join'
    # message
    assert :ok == :gen_tcp.send(context.alice, """
    {"type": "join", "value": "alice"}
    """)
   
    # Make sure that bob's message will be second
    :timer.sleep(100)

    # Bob joins the game by sending the 'join' message    
    assert :ok == :gen_tcp.send(context.bob, """
    {"type": "join", "value": "bob"}
    """)

    # Since bob is second to join he will have the first
    # turn. He should receive a 'turn' message.
    turn = :gen_tcp.recv(context.bob, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"turn"}\r\n'}

    # After that bob puts a coin in a slot by sending a
    # 'put' message
    assert :ok == :gen_tcp.send(context.bob, """
    {"type": "put", "value": 2}
    """)
    
    # Alice will be informed about bob's put through
    # a 'set' message
    set = :gen_tcp.recv(context.alice, 26, 1000)
    assert set == {:ok, '{"value":2,"type":"set"}\r\n'}

    # Now it's alice's turn. She receives her 'turn'
    # message...
    turn = :gen_tcp.recv(context.alice, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"turn"}\r\n'}

    # ...and  throws in another coid
    assert :ok == :gen_tcp.send(context.alice, """
    {"type": "put", "value": 4}
    """)

    set = :gen_tcp.recv(context.bob, 26, 1000)
    assert set == {:ok, '{"value":4,"type":"set"}\r\n'}

    turn = :gen_tcp.recv(context.bob, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"turn"}\r\n'}

    # Bob's turn
    assert :ok == :gen_tcp.send(context.bob, """
    {"type": "put", "value": 3}
    """)

    set = :gen_tcp.recv(context.alice, 26, 1000)
    assert set == {:ok, '{"value":3,"type":"set"}\r\n'}

    turn = :gen_tcp.recv(context.alice, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"turn"}\r\n'}

    # Alice's turn
    assert :ok == :gen_tcp.send(context.alice, """
    {"type": "put", "value": 4}
    """)

    set = :gen_tcp.recv(context.bob, 26, 1000)
    assert set == {:ok, '{"value":4,"type":"set"}\r\n'}

    turn = :gen_tcp.recv(context.bob, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"turn"}\r\n'}

    # Bob's turn
    assert :ok == :gen_tcp.send(context.bob, """
    {"type": "put", "value": 7}
    """)

    set = :gen_tcp.recv(context.alice, 26, 1000)
    assert set == {:ok, '{"value":7,"type":"set"}\r\n'}

    turn = :gen_tcp.recv(context.alice, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"turn"}\r\n'}

    # Alice's turn
    assert :ok == :gen_tcp.send(context.alice, """
    {"type": "put", "value": 4}
    """)

    set = :gen_tcp.recv(context.bob, 26, 1000)
    assert set == {:ok, '{"value":4,"type":"set"}\r\n'}

    turn = :gen_tcp.recv(context.bob, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"turn"}\r\n'}

    # Bob's turn
    assert :ok == :gen_tcp.send(context.bob, """
    {"type": "put", "value": 3}
    """)

    set = :gen_tcp.recv(context.alice, 26, 1000)
    assert set == {:ok, '{"value":3,"type":"set"}\r\n'}

    turn = :gen_tcp.recv(context.alice, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"turn"}\r\n'}

    # Alice's turn
    assert :ok == :gen_tcp.send(context.alice, """
    {"type": "put", "value": 4}
    """)

    # Alice wins this game
    turn = :gen_tcp.recv(context.alice, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"win"}\r\n'}

    # Bob looses this game
    turn = :gen_tcp.recv(context.bob, 0, 1000)
    assert turn == {:ok, '{"value":null,"type":"loose"}\r\n'}
  end
end
