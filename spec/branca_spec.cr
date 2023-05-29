require "./spec_helper"

describe Branca do
  # https://github.com/tuupola/branca-spec/blob/master/test_vectors.json
  # test vectors taken from
  # https://github.com/tuupola/branca-php/blob/2.x/tests/BrancaTest.php
  it "should throw on invalid key" do
    expect_raises(Exception, "secret key has to be 32 bytes strong") do
      Branca.new "notsosecretkey".to_slice
    end
  end

  branca = Branca.new "supersecretkeyyoushouldnotcommit".to_slice

  describe "#decode" do
    it "should decode Hello world! with zero timestamp" do
      token = "870S4BYxgHw0KnP3W9fgVUHEhT5g86vJ17etaC5Kh5uIraWHCI1psNQGv298ZmjPwoYbjDQ9chy2z"
      payload, timestamp = branca.decode(token)
      str = String.new(payload)
      str.should eq "Hello world!"
      timestamp.should eq 0
    end
    it "should decode Hello world! with max timestamp" do
      token = "89i7YCwu5tWAJNHUDdmIqhzOi5hVHOd4afjZcGMcVmM4enl4yeLiDyYv41eMkNmTX6IwYEFErCSqr"
      payload, timestamp = branca.decode(token)
      str = String.new(payload)
      str.should eq "Hello world!"
      timestamp.should eq 4294967295
    end
    it "should decode Hello world! with nov 27 timestamp" do
      token = "875GH23U0Dr6nHFA63DhOyd9LkYudBkX8RsCTOMz5xoYAMw9sMd5QwcEqLDRnTDHPenOX7nP2trlT"
      payload, timestamp = branca.decode(token)
      str = String.new(payload)
      str.should eq "Hello world!"
      timestamp.should eq 123206400
    end
    it "should decode eight null bytes with zero timestamp" do
      token = "1jIBheHbDdkCDFQmtgw4RUZeQoOJgGwTFJSpwOAk3XYpJJr52DEpILLmmwYl4tjdSbbNqcF1"
      payload, timestamp = branca.decode(token)
      hex = payload.hexstring
      hex.should eq "0000000000000000"
      timestamp.should eq 0
    end
    it "should decode eight null bytes with max timestamp" do
      token = "1jrx6DUu5q06oxykef2e2ZMyTcDRTQot9ZnwgifUtzAphGtjsxfbxXNhQyBEOGtpbkBgvIQx"
      payload, timestamp = branca.decode(token)
      hex = payload.hexstring
      hex.should eq "0000000000000000"
      timestamp.should eq 4294967295
    end
    it "should decode eight null bytes with nov 27 timestamp" do
      token = "1jJDJOEjuwVb9Csz1Ypw1KBWSkr0YDpeBeJN6NzJWx1VgPLmcBhu2SbkpQ9JjZ3nfUf7Aytp"
      payload, timestamp = branca.decode(token)
      hex = payload.hexstring
      hex.should eq "0000000000000000"
      timestamp.should eq 123206400
    end
    it "should decode empty payload with zero timestamp" do
      token = "4sfD0vPFhIif8cy4nB3BQkHeJqkOkDvinI4zIhMjYX4YXZU5WIq9ycCVjGzB5"
      payload, timestamp = branca.decode(token)
      str = String.new(payload)
      str.should eq ""
      timestamp.should eq 0
    end
    it "should decode non utf-8 chars with nov 27 timestamp" do
      token = "K9u6d0zjXp8RXNUGDyXAsB9AtPo60CD3xxQ2ulL8aQoTzXbvockRff0y1eXoHm"
      payload, timestamp = branca.decode(token)
      hex = payload.hexstring
      hex.should eq "80"
      timestamp.should eq 123206400
    end
    it "should throw with wrong token version" do
      token = "89mvl3RkwXjpEj5WMxK7GUDEHEeeeZtwjMIOogTthvr44qBfYtQSIZH5MHOTC0GzoutDIeoPVZk3w"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "should throw with modified token nonce" do
      token = "875GH233SUysT7fQ711EWd9BXpwOjB72ng3ZLnjWFrmOqVy49Bv93b78JU5331LbcY0EEzhLfpmSx"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "should throw with modified chiphertext" do
      token = "875GH23U0Dr6nHFA63DhOyd9LkYudBkX8RsCTOMz5xoYAMw9sMd5Qw6Jpo96myliI3hHD7VbKZBYh"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "should throw with modified poly1305 tag" do
      token = "875GH23U0Dr6nHFA63DhOyd9LkYudBkX8RsCTOMz5xoYAMw9sMd5QwcEqLDRnTDHPenOX7nP2trk0"
      expect_raises(Exception) do
        branca.decode(token)
      end
    end
    it "should throw with wrong secret key" do
      token = "870S4BYxgHw0KnP3W9fgVUHEhT5g86vJ17etaC5Kh5uIraWHCI1psNQGv298ZmjPwoYbjDQ9chy2z"
      br = Branca.new "wrongsecretkeyyoushouldnotcommit".to_slice
      expect_raises(Exception) do
        br.decode(token)
      end
    end
  end
end
