# Copyright 2019, Google LLC
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Google LLC nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# 'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require "test_helper"
require "google/gax/grpc"

class GrpcStubTest < Minitest::Spec
  FakeCallCredentials = Class.new GRPC::Core::CallCredentials do
    attr_reader :updater_proc

    def initialize updater_proc
      @updater_proc = updater_proc
    end
  end

  FakeChannel = Class.new GRPC::Core::Channel do
    def initialize
    end
  end

  FakeChannelCredentials = Class.new GRPC::Core::ChannelCredentials do
    attr_reader :call_creds

    def compose call_creds
      @call_creds = call_creds
    end
  end

  FakeCredentials = Class.new Google::Auth::Credentials do
    def initialize
    end

    def updater_proc
      ->{}
    end
  end

  def test_with_channel
    fake_channel = FakeChannel.new

    mock = Minitest::Mock.new
    mock.expect :nil?, false
    mock.expect :new, nil, ["service:port", nil, channel_override: fake_channel, interceptors: []]

    Google::Gax::Grpc::Stub.new mock, host: "service", port: "port", credentials: fake_channel

    mock.verify
  end

  def test_with_channel_credentials
    fake_channel_creds = FakeChannelCredentials.new

    mock = Minitest::Mock.new
    mock.expect :nil?, false
    mock.expect :new, nil, ["service:port", fake_channel_creds, interceptors: []]

    Google::Gax::Grpc::Stub.new mock, host: "service", port: "port", credentials: fake_channel_creds

    mock.verify
  end

  def test_with_credentials
    GRPC::Core::CallCredentials.stub :new, FakeCallCredentials.method(:new) do
      GRPC::Core::ChannelCredentials.stub :new, FakeChannelCredentials.method(:new) do
        mock = Minitest::Mock.new
        mock.expect :nil?, false
        mock.expect :new, nil, ["service:port", FakeCallCredentials, interceptors: []]

        Google::Gax::Grpc::Stub.new mock, host: "service", port: "port", credentials: FakeCredentials.new

        mock.verify
      end
    end
  end

  def test_with_proc
    GRPC::Core::CallCredentials.stub :new, FakeCallCredentials.method(:new) do
      GRPC::Core::ChannelCredentials.stub :new, FakeChannelCredentials.method(:new) do
        mock = Minitest::Mock.new
        mock.expect :nil?, false
        mock.expect :new, nil, ["service:port", FakeCallCredentials, interceptors: []]

        credentials_proc = ->{}

        Google::Gax::Grpc::Stub.new mock, host: "service", port: "port", credentials: credentials_proc

        mock.verify
      end
    end
  end
end
