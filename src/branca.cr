require "monocypher"
require "multibase/base_62"

class Branca
  VERSION = 0xBA

  alias BigEndian = IO::ByteFormat::BigEndian
  alias Base62 = Multibase::Base62
  alias Nonce = Crypto::Nonce
  alias Mac = Crypto::Header

  struct Token
    property :payload, :timestamp

    def initialize(
      @payload : Bytes = Bytes.empty,
      @timestamp : UInt32 = Time.utc.to_unix.to_u32
    )
    end
  end

  class ExpiredTokenError < Exception
    getter :token

    def initialize(@token : Token)
      super "token is expired"
    end
  end

  # Creates a new Branca instance.
  #
  # Make sure you use a secure encryption key:
  # ```
  # key = Bytes.new(32)
  # Random::Secure.random_bytes(key)
  # branca = Branca.new key
  # ```
  def initialize(key : Bytes)
    raise "secret key has to be 32 bytes strong" unless key.size == 32
    @key = StaticArray(UInt8, 32).new { |i| key[i] }
  end

  # Creates a XChaCha20-Poly1305 AEAD encrypted Branca Token.
  #
  # Returns a Base62 encoded String.
  def encode(payload : String | Bytes, timestamp : UInt32 = Time.utc.to_unix.to_u32) : String
    payload = payload.to_slice

    time = Bytes.new(4)
    BigEndian.encode(timestamp, time)

    # Use custom nonce if set (only for testing).
    nonce = @nonce || Nonce.new.to_slice
    header = Bytes.new(1, VERSION.to_u8) + time + nonce

    ciphertext = Bytes.new(payload.size + Mac.size)
    LibMonocypher.aead_lock(
      ciphertext[0, payload.size],
      ciphertext[payload.size, Mac.size],
      @key,
      nonce,
      header,
      header.size,
      payload,
      payload.size
    )
    token = header + ciphertext
    Base62.encode(token)
  end

  def encode(token : Token) : String
    encode(token.payload, token.timestamp)
  end

  # Decodes a Base62 encoded Branca Token.
  #
  # If *ttl* is greater than 0 and the token is expired, an `ExpiredTokenError` is raised.
  def decode(str : String, ttl : UInt32 = 0) : Token
    bytes = Base62.decode(str)
    header_size = 5 + Nonce.size
    raise "invalid token header size: got #{bytes.size}, expected #{header_size}" if bytes.size < header_size

    header = bytes[0, header_size]
    version = header[0]
    raise "wrong token version detected: got #{version}, expected #{VERSION}" unless version == VERSION

    nonce = header[5..-1]
    ciphertext = bytes[header.size..-1]

    payload = Bytes.new(ciphertext.size - Mac.size)
    res = LibMonocypher.aead_unlock(
      payload,
      ciphertext[payload.size, Mac.size],
      @key,
      nonce,
      header,
      header.size,
      ciphertext[0, payload.size],
      payload.size
    )
    raise "decryption error occurred: #{res}" unless res == 0

    timestamp = BigEndian.decode(UInt32, header[1..4])
    token = Token.new(payload, timestamp)

    raise ExpiredTokenError.new(token) if ttl > 0 && (timestamp + ttl) < Time.utc.to_unix
    token
  end
end
