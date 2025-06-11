# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'colorize'

module Clients
# SocialUsernameChecker checks username availability across multiple social platforms.
  class SocialUsernameChecker
  # Supported platforms and their URL patterns for usernames
  PLATFORMS = {
    github: 'https://github.com/%<username>s',
    twitter: 'https://twitter.com/%<username>s',
    instagram: 'https://www.instagram.com/%<username>s',
    facebook: 'https://www.facebook.com/%<username>s',
    youtube: 'https://www.youtube.com/@%<username>s',
    tiktok: 'https://www.tiktok.com/@%<username>s',
    pinterest: 'https://www.pinterest.com/%<username>s',
    linkedin: 'https://www.linkedin.com/in/%<username>s',
    reddit: 'https://www.reddit.com/user/%<username>s',
    threads: 'https://www.threads.net/@%<username>s'
  }.freeze
  
  # Returns an array of supported platform names as strings
  #
  # Returns Array<String>
  def supported_platforms
    PLATFORMS.keys.map(&:to_s)
  end
  
  # Check if a username is available on a given platform.
  #
  # username - String username to check
  # platform - Symbol or String platform key (e.g., :github or "github")
  #
  # Returns Boolean true if available, false if taken or on error.
  def username_available?(username, platform)
    platform_key = platform.to_sym
    
    unless PLATFORMS.key?(platform_key)
      warn "Unsupported platform: #{platform}"
      return false
    end
    
    url = format(PLATFORMS[platform_key], username: username)
    uri = URI.parse(url)
    
    response = fetch_response(uri)
    
    # If HTTP status is not 200, assume username is available (profile not found)
    return true unless response.code == '200'
    
    # Check response body for username presence (basic heuristic)
    body = response.body.force_encoding('UTF-8')
    
    # If the username appears in the page content, it's likely taken
    !body.include?(username)
  rescue StandardError => e
    warn "⚠️ Error checking #{platform}: #{e.message}".colorize(:yellow)
    false
  end
  
  private
  
  # Perform a GET request and return the HTTP response
  #
  # uri - URI object
  #
  # Returns Net::HTTPResponse
  def fetch_response(uri)
    Net::HTTP.get_response(uri)
  end
  
  # Remove TLD extension from a domain to get a clean username base
  #
  # domain - String domain name (e.g. "example.com")
  #
  # Returns String username base (e.g. "example")
  def strip_extension(domain)
    domain.split('.').first
  end
end
end
