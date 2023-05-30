require "monocypher"
require "base62"

struct Branca
  VERSION = UInt8.new 0xBA

  alias BigEndian = IO::ByteFormat::BigEndian
  alias Nonce = Crypto::Nonce
  alias Mac = Crypto::Header

  class ExpiredTokenError < Exception
    getter :delta

    def initialize(@delta : UInt32)
      super "token is expired by: #{@delta}s"
    end
  end

  def initialize(key : Bytes)
    raise "secret key has to be 32 bytes strong" unless key.size == 32
    @key = StaticArray(UInt8, 32).new { |i| key[i] }
  end

  def encode(payload : String | Bytes, timestamp : UInt32 = Time.utc.to_unix.to_u32) : String
    payload = payload.to_slice

    time = Bytes.new(4)
    BigEndian.encode(timestamp, time)

    nonce = Nonce.new.to_slice
    header = Slice(UInt8).new(1, VERSION) + time + nonce

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

  def decode(token : String, ttl : UInt32 = 0) : {Bytes, UInt32}
    bytes = Base62.decode(token).to_s(16).hexbytes
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
    if ttl > 0
      delta = Time.utc.to_unix - (timestamp + ttl)
      raise ExpiredTokenError.new delta.to_u32 if delta > 0
    end

    {payload, timestamp}
  end
end
