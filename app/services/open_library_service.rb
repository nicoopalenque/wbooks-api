require 'httparty'
require 'json'

class OpenLibraryService
  include HTTParty
  include Concurrent::Async
  def initialize(isbn)
    @isbn = isbn
    @base_uri = Rails.application.credentials.development[:open_library][:base_uri]
  end

  def book_info
    response = book
    if response.code == 200
      hash = JSON.parse(response.body).with_indifferent_access
      build_response(hash)
    else
      {
        code: response.code,
        message: response.message
      }
    end
  end

  private

  def book
    options = {
      bibkeys: type_isbn,
      format: 'json',
      jscmd: 'data'
    }
    HTTParty.get(@base_uri, { query: options })
  end

  def build_response(data)
    book_data = data[type_isbn]
    {
      ISBN: @isbn,
      title: book_data[:title],
      subtitle: book_data[:subtitle],
      number_of_pages: book_data[:number_of_pages],
      authors: book_data[:authors]
    }
  end

  def type_isbn
    "ISBN:#{@isbn}".to_s
  end
end
