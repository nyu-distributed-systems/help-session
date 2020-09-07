defmodule HelpSessionTest do
  use ExUnit.Case
  import Emulation, only: [spawn: 2, send: 2, timer: 1]

  import Kernel,
    except: [spawn: 3, spawn: 1, spawn_link: 1, spawn_link: 3, send: 2]

  doctest HelpSession

  test "Test flipping" do
    HelpSession.test_flip()
  end
end
