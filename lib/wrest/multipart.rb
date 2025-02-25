# Copyright 2009 - 2010 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

begin
  gem 'multipart-post', '~> 2.0'
rescue Gem::LoadError => e
  Wrest.logger.debug "Multipart Post ~> 2.0 not found. Multipart Post is necessary to be able to post multipart. To install Multipart Post run 'sudo gem install multipart-post'"
  raise e
end

require "wrest/native/post_multipart"
require "wrest/native/put_multipart"

module Wrest
  # To enable Multipart support, use
  #  require 'wrest/multipart'
  #
  # Multipart support is currently only available on Net::Http and not when using libcurl.
  # It depends on the multipart-post gem being available. To install multipart-post
  #   (sudo) gem install multipart-post
  #
  # The methods in this module are mixed into Wrest::Uri.
  module Multipart
    # Makes a multipart/form-data encoded POST request to this URI. This is a convenience API
    # that mimics a multipart form being posted; some allegedly RESTful APIs like FCBK require 
    # this for file uploads.
    #
    #   File.open('/path/to/image.jpg') do |file|
    #     'http://localhost:3000/uploads'.to_uri.post_multipart('file' => UploadIO.new(file, "image/jpg", '/path/to/image.jpg'))
    #   end
    def post_multipart(parameters = {}, headers = {}, &block)
      Http::PostMultipart.new(self, parameters, headers, block ? @options.merge(:callback_block => block) : @options).invoke
    end

    # Makes a multipart/form-data encoded POST request to this URI. This is a convenience API
    # that mimics a multipart form being posted; some allegedly RESTful APIs like FCBK require 
    # this for file uploads.
    #
    #   File.open('/path/to/image.jpg') do |file|
    #     'http://localhost:3000/uploads'.to_uri.post_multipart_async('file' => UploadIO.new(file, "image/jpg", '/path/to/image.jpg'))
    #   end
    #
    # Note: post_multipart_async does not return a response and the response should be accessed through callbacks.
    # This implementation of asynchronous post_multipart is currently in alpha. Hence, it should not be used in production.
    def post_multipart_async(parameters = {}, headers = {}, &block)
      (@options[:asynchronous_backend] || Wrest::AsyncRequest.default_backend).execute(Http::PostMultipart.new(self, parameters, headers, block ? @options.merge(:callback_block => block) : @options))
    end
    
    # Makes a multipart/form-data encoded PUT request to this URI. This is a convenience API
    # that mimics a multipart form being put. I sincerely hope you never need to use this.
    def put_multipart(parameters = {}, headers = {}, &block)
      Http::PutMultipart.new(self, parameters, headers, block ? @options.merge(:callback_block => block) : @options).invoke
    end

    # Makes a multipart/form-data encoded PUT request to this URI. This is a convenience API
    # that mimics a multipart form being put. I sincerely hope you never need to use this.
    #
    # Note: put_multipart_async does not return a response and the response should be accessed through callbacks
    # This implementation of asynchronous put_multipart is currently in alpha. Hence, it should not be used in production.
    def put_multipart_async(parameters = {}, headers = {}, &block)
      (@options[:asynchronous_backend] || Wrest::AsyncRequest.default_backend).execute(Http::PutMultipart.new(self, parameters, headers, block ? @options.merge(:callback_block => block) : @options))
    end
  end
  
  class Uri
    include Multipart
  end
end

