require "./spec_helper"

# Branca test vectors
#
# https://github.com/tuupola/branca-spec/blob/master/test_vectors.json
describe Branca do
  branca = Branca.new "73757065727365637265746b6579796f7573686f756c646e6f74636f6d6d6974".hexbytes

  it "throws with invalid key" do
    key = "746f6f73686f72746b6579".hexbytes
    expect_raises(Exception) do
      Branca.new key
    end
  end

  describe "#encode" do
    it "encodes hello world with zero timestamp" do
      payload = "48656c6c6f20776f726c6421".hexbytes
      token = branca.encode(payload, 0)
      token.should eq "870S4BYxgHw0KnP3W9fgVUHEhT5g86vJ17etaC5Kh5uIraWHCI1psNQGv298ZmjPwoYbjDQ9chy2z"
    end
    it "encodes hello world with max timestamp" do
      payload = "48656c6c6f20776f726c6421".hexbytes
      token = branca.encode(payload, 4294967295)
      token.should eq "89i7YCwu5tWAJNHUDdmIqhzOi5hVHOd4afjZcGMcVmM4enl4yeLiDyYv41eMkNmTX6IwYEFErCSqr"
    end
    it "encodes hello world with November 27 timestamp" do
      payload = "48656c6c6f20776f726c6421".hexbytes
      token = branca.encode(payload, 123206400)
      token.should eq "875GH23U0Dr6nHFA63DhOyd9LkYudBkX8RsCTOMz5xoYAMw9sMd5QwcEqLDRnTDHPenOX7nP2trlT"
    end
    it "encodes eight null bytes with zero timestamp" do
      payload = "0000000000000000".hexbytes
      token = branca.encode(payload, 0)
      token.should eq "1jIBheHbDdkCDFQmtgw4RUZeQoOJgGwTFJSpwOAk3XYpJJr52DEpILLmmwYl4tjdSbbNqcF1"
    end
    it "encodes eight null bytes with max timestamp" do
      payload = "0000000000000000".hexbytes
      token = branca.encode(payload, 4294967295)
      token.should eq "1jrx6DUu5q06oxykef2e2ZMyTcDRTQot9ZnwgifUtzAphGtjsxfbxXNhQyBEOGtpbkBgvIQx"
    end
    it "encodes eight null bytes with November 27th timestamp" do
      payload = "0000000000000000".hexbytes
      token = branca.encode(payload, 123206400)
      token.should eq "1jJDJOEjuwVb9Csz1Ypw1KBWSkr0YDpeBeJN6NzJWx1VgPLmcBhu2SbkpQ9JjZ3nfUf7Aytp"
    end
    it "encodes empty payload" do
      payload = "".hexbytes
      token = branca.encode(payload, 0)
      token.should eq "4sfD0vPFhIif8cy4nB3BQkHeJqkOkDvinI4zIhMjYX4YXZU5WIq9ycCVjGzB5"
    end
    it "encodes non-UTF8 payload" do
      payload = "80".hexbytes
      token = branca.encode(payload, 123206400)
      token.should eq "K9u6d0zjXp8RXNUGDyXAsB9AtPo60CD3xxQ2ulL8aQoTzXbvockRff0y1eXoHm"
    end
  end

  describe "#decode" do
    it "decodes hello world with zero timestamp" do
      token = "870S4BYxgHw0KnP3W9fgVUHEhT5g86vJ17etaC5Kh5uIraWHCI1psNQGv298ZmjPwoYbjDQ9chy2z"
      payload, timestamp = branca.decode(token)
      payload.hexstring.should eq "48656c6c6f20776f726c6421"
      timestamp.should eq 0
    end
    it "decodes hello world with max timestamp" do
      token = "89i7YCwu5tWAJNHUDdmIqhzOi5hVHOd4afjZcGMcVmM4enl4yeLiDyYv41eMkNmTX6IwYEFErCSqr"
      payload, timestamp = branca.decode(token)
      payload.hexstring.should eq "48656c6c6f20776f726c6421"
      timestamp.should eq 4294967295
    end
    it "decodes hello world with November 27 timestamp" do
      token = "875GH23U0Dr6nHFA63DhOyd9LkYudBkX8RsCTOMz5xoYAMw9sMd5QwcEqLDRnTDHPenOX7nP2trlT"
      payload, timestamp = branca.decode(token)
      payload.hexstring.should eq "48656c6c6f20776f726c6421"
      timestamp.should eq 123206400
    end
    it "decodes eight null bytes with zero timestamp" do
      token = "1jIBheHbDdkCDFQmtgw4RUZeQoOJgGwTFJSpwOAk3XYpJJr52DEpILLmmwYl4tjdSbbNqcF1"
      payload, timestamp = branca.decode(token)
      payload.hexstring.should eq "0000000000000000"
      timestamp.should eq 0
    end
    it "decodes eight null bytes with max timestamp" do
      token = "1jrx6DUu5q06oxykef2e2ZMyTcDRTQot9ZnwgifUtzAphGtjsxfbxXNhQyBEOGtpbkBgvIQx"
      payload, timestamp = branca.decode(token)
      payload.hexstring.should eq "0000000000000000"
      timestamp.should eq 4294967295
    end
    it "decodes eight null bytes with November 27th timestamp" do
      token = "1jJDJOEjuwVb9Csz1Ypw1KBWSkr0YDpeBeJN6NzJWx1VgPLmcBhu2SbkpQ9JjZ3nfUf7Aytp"
      payload, timestamp = branca.decode(token)
      payload.hexstring.should eq "0000000000000000"
      timestamp.should eq 123206400
    end
    it "decodes empty payload" do
      token = "4sfD0vPFhIif8cy4nB3BQkHeJqkOkDvinI4zIhMjYX4YXZU5WIq9ycCVjGzB5"
      payload, timestamp = branca.decode(token)
      payload.hexstring.should eq ""
      timestamp.should eq 0
    end
    it "decodes non-UTF8 payload" do
      token = "K9u6d0zjXp8RXNUGDyXAsB9AtPo60CD3xxQ2ulL8aQoTzXbvockRff0y1eXoHm"
      payload, timestamp = branca.decode(token)
      payload.hexstring.should eq "80"
      timestamp.should eq 123206400
    end
    it "throws with wrong version 0xBB" do
      token = "89mvl3RkwXjpEj5WMxK7GUDEHEeeeZtwjMIOogTthvr44qBfYtQSIZH5MHOTC0GzoutDIeoPVZk3w"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "throws with invalid base62 characters" do
      token = "875GH23U0Dr6nHFA63DhOyd9LkYudBkX8RsCTOMz5xoYAMw9sMd5QwcEqLDRnTDHPenOX7nP2trlT_"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "throws with modified version" do
      token = "89mvl3S0BE0UCMIY94xxIux4eg1w5oXrhvCEXrDAjusSbO0Yk7AU6FjjTnbTWTqogLfNPJLzecHVb"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "throws with modified first byte of the nonce" do
      token = "875GH233SUysT7fQ711EWd9BXpwOjB72ng3ZLnjWFrmOqVy49Bv93b78JU5331LbcY0EEzhLfpmSx"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "throws with modified timestamp" do
      token = "870g1RCk4lW1YInhaU3TP8u2hGtfol16ettLcTOSoA0JIpjCaQRW7tQeP6dQmTvFIB2s6wL5deMXr"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "throws with modified last byte of the ciphertext" do
      token = "875GH23U0Dr6nHFA63DhOyd9LkYudBkX8RsCTOMz5xoYAMw9sMd5Qw6Jpo96myliI3hHD7VbKZBYh"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "throws with modified last byte of the Poly1305 tag" do
      token = "875GH23U0Dr6nHFA63DhOyd9LkYudBkX8RsCTOMz5xoYAMw9sMd5QwcEqLDRnTDHPenOX7nP2trk0"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "throws with wrong key" do
      token = "870S4BYxgHw0KnP3W9fgVUHEhT5g86vJ17etaC5Kh5uIraWHCI1psNQGv298ZmjPwoYbjDQ9chy2z"
      key = "77726f6e677365637265746b6579796f7573686f756c646e6f74636f6d6d6974".hexbytes
      br = Branca.new key
      expect_raises(Exception) do
        br.decode(token)
      end
    end
  end
end
