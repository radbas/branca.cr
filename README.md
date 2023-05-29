# Branca.cr

Branca Token implementation for Crystal.

## What?

[Branca](https://github.com/tuupola/branca-spec) is a secure easy to use token format which makes it hard to shoot yourself in the foot. It uses IETF XChaCha20-Poly1305 AEAD symmetric encryption to create encrypted and tamperproof tokens. Payload itself is an arbitrary sequence of bytes. You can use for example a JSON object, plain text string or even binary data serialized by [MessagePack](http://msgpack.org/) or [Protocol Buffers](https://developers.google.com/protocol-buffers/).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     branca:
       github: radbas/branca.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "branca"

key = Bytes.new(32)
Random::Secure.random_bytes(key)
branca = Branca.new key

token = branca.encode("Hello world!".to_slice, 1234)
payload, timestamp = branca.decode(token)

p String.new(payload) == "Hello world!" # true
p timestamp == 1234 # true
```

Make sure you use a secure encryption key generated by `Random::Secure.random_bytes`

```crystal
key = Bytes.new(32)
Random::Secure.random_bytes(key)

# store the key somewhere as a hex string
hex = key.hexstring

# convert hex string back to bytes
key = hex.hexbytes
```

## Contributing

1. Fork it (<https://github.com/radbas/branca.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Johannes Rabausch](https://github.com/jrabausch) - creator and maintainer
