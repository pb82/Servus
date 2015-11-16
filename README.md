## Servus

A simple, modular backend for multiplayer games. Simple, because it just handles the (socket) communication between a number
of players and provides hooks for the game logic. Modular, because game logic is written as a state machine and loaded into
the server at runtime. The server can host multiple game logic modules simultaneously (on different ports)..

This is the result of a two day game-jam with two colleagues and should definitely not be used in production!

### Installation

1. Clone this repository
2. Get all dependencies with `mix deps.get`
3. Run the tests with `mix test`
4. Start a server session with `iex -S mix`
5. Or create a release with `MIX_ENV=prod mix release`

### Usage

Servus sends and receives messages over socket connections. Messages must be encoded in JSON format. The format of
a message is

```javascript
{
    "type":     <REQUIRED>,
    "value":    <REQUIRED>,
    "target":   <OPTIONAL>>
}
```

The `type` of a message can be used in the game logic to implement different commands. The type `join` is special and is used
to join the waiting queue for a game. The `value` can be any kind of data and will be passed to the receiver of the message
(a game logic or server plugin). If a `target` is given, the message will be routed to the server plugin that that is 
registered under that name.

When players connect to the server by sending a `join` message, the player is first put into a waiting queue. Every game logic has
to specify the number of players. When that number is reached a new game session is started and all the players in the queue are in
game mode now. This approach is a bit unflexible since it only allows a fixed number of players per game. There is also no matching
algorithm at all. Only the order in which the players join determines the opponents in a game.

### Configuration

The config file is `config/config.exs`. There are two sections: basic configuration and game specific configuration. In the base config
you define which game modules and server plugins to start.

#### Base configuration (using the included examples)

```elixir
config :servus, 
  # Start the `connect_four` backend
  backends: [:connect_four],

  # Start the Echo module (accessible to all backends)
  modules: [Echo]
```

#### Game specific configuration

```elixir
config :servus,
  # Configuration for the `connect_four` backend
  connect_four: %{
    port: 3334,
    players_per_game: 2,
    implementation: ConnectFour
  }
```

The `implementation` is expected to be a `gen_fsm` statemachine that uses `Servus.Game`. You should override the `init/1` function and return
the initial state and the data that will be passed to the fsm actions. For further information you can have a look at the example game under
lib/connect_four

### Server plugins (or modules)

You can write your own server plugins for various porupses, like for example, saving hiscores. A server plugin is an elixir module that uses `Servus.Module`.
Every plugin will be started as a `gen_server` internally. A module has to be registered by calling the `register` macro as soon as possible in the module
definition. There are two overridables: `startup/0` and `shutdown/1`. `startup/0` allows you to return the plugin state.

To handle messages to the plugin you use the `handle` macros. In it's simplest form it looks like

```elixir
handle "echo", args, state do
  Logger.debug "Echo module called"
  args
end
```

There's also a `handlep` macro. Use this if you don't want the module to be callable via network. `handlep` handlers can only be called from within
the server (usually from a game backend).

This will simply echo all input. Have a look at the example plugin under lib/echo_module.
