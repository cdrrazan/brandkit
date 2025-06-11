# frozen_string_literal: true

require 'httparty'

module Clients
  # A client for interacting with the Namecheap XML API.
  # Currently supports checking domain availability.
  class NamecheapClient
    include HTTParty
    base_uri 'https://api.namecheap.com/xml.response'
    
    attr_reader :api_user, :api_key, :username, :client_ip
    
    def initialize
      @api_user = ENV.fetch('NAMECHEAP_API_USER')
      @api_key = ENV.fetch('NAMECHEAP_API_KEY')
      @username = ENV.fetch('NAMECHEAP_USERNAME')
      @client_ip = ENV.fetch('CLIENT_IP')
    end
    
    # Public: Check if a domain is available for registration.
    #
    # domain - A String domain name to check (e.g., "example.com").
    #
    # Returns true if the domain is available, false otherwise.
    def check_domains(domains)
      response = make_request(
        command: 'namecheap.domains.check',
        params: { DomainList: domains.join(",") }
      )
      
      response.dig('ApiResponse', 'CommandResponse', 'DomainCheckResult')
    rescue StandardError => e
      warn "Error checking domain '#{domain}': #{e.message}"
      false
    end
    
    private
    
    # Private: Build the query parameters for the API call.
    #
    # command - Namecheap API command string.
    # params  - Additional parameters for the specific command.
    #
    # Returns a Hash with all query parameters merged.
    def build_query(command:, params: {})
      {
        ApiUser: api_user,
        ApiKey: api_key,
        UserName: username,
        ClientIp: client_ip,
        Command: command
      }.merge(params)
    end
    
    # Private: Perform the HTTP GET request to the Namecheap API.
    #
    # command - The API command to call (e.g., "namecheap.domains.check").
    # params  - Additional parameters for the command.
    #
    # Returns a parsed Hash of the XML response.
    def make_request(command:, params: {})
      query = build_query(command: command, params: params)
      response = self.class.get('/', query: query)
      
      raise "API call failed with HTTP #{response.code}" unless response.success?
      
      parsed = response.parsed_response
      raise 'Invalid API response structure' unless parsed.is_a?(Hash)
      
      parsed
    end
  end
end
