require "spec"
require "../src/branca"

# Branca Test Object
#
# This sets a user defined nonce for testing.
# Do not do this in production.
struct Branca
  @nonce = "beefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeefbeef".hexbytes
end
