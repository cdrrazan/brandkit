# frozen_string_literal: true

require 'tty-table'
require 'colorize'

# DomainChecker handles checking domain availability using Namecheap API.
# Supports both exact domain check and suggestions with common TLDs.
module Clients
  class DomainChecker
  COMMON_TLDS = %w[.com .net .org .io .dev .app .co .xyz .tech .site .link .me .info .blog].freeze
  
  # Initialize with the domain string to check.
  #
  # domain - String domain or base name (e.g. "example" or "example.com")
  def initialize(domain)
    @domain = domain
    @client = Clients::NamecheapClient.new
  end
  
  # Perform the domain availability check.
  #
  # Returns a Hash with keys:
  # - :available (Boolean)
  # - :domain (String)
  # - :message (String, colorized)
  # - :link (String URL if available)
  # - :suggestions (Array of [domain, available] for common TLDs if no exact domain)
  def check
    if exact_domain?(@domain)
      check_exact_domain(@domain)
    else
      check_domain_suggestions(@domain)
    end
  end
  
  private
  
  # Determine if the domain includes a dot (TLD)
  #
  # domain - String
  #
  # Returns Boolean
  def exact_domain?(domain)
    domain.include?('.')
  end
  
  # Check availability for exact domain (with TLD)
  #
  # domain - String
  #
  # Returns Hash with availability info and message
  def check_exact_domain(domain)
    availability_results = @client.check_domains([domain])
    is_available = availability_results["Available"]
    
    {
      available: is_available,
      domain: availability_results["Domain"],
      message: is_available == "true" ? success_message(domain, "green") : failure_message(domain, "red"),
      link: is_available == "true" ? purchase_link(domain) : nil
    }
  end
  
  # Check availability for common TLD suggestions and display results
  #
  # base_domain - String domain base without TLD (e.g. "example")
  #
  # Returns Hash with message, suggestions, and availability false
  def check_domain_suggestions(base_domain)
    full_domains = COMMON_TLDS.map { |tld| "#{base_domain}#{tld}" }

    # Bulk check domain availability
    availability_results = @client.check_domains(full_domains)
    # => e.g., { "example.com" => true, "example.net" => false }

    # Return array of [domain, availability]
    suggestions = availability_results.map do |domain|
      [domain["Domain"], domain["Available"]]
    end
    
    print_suggestions_table(suggestions)
    
    available_count = suggestions.count { |_, available| available }
    
    {
      available: false,
      domain: base_domain,
      message: availability_summary_message(base_domain, available_count),
      suggestions: suggestions
    }
  end
  
  # Print a formatted table of domain suggestions and their availability
  #
  # suggestions - Array of [domain, Boolean availability]
  def print_suggestions_table(suggestions)
    rows = suggestions.map do |domain, available|
      [domain, available == "true" ? '✔ Available'.colorize(:green) : '✖ Taken'.colorize(:red)]
    end
    
    table = TTY::Table.new(%w[Domain Status], rows)
    puts "\nTop Domain Extensions:\n"
    puts table.render(:unicode, padding: [0, 2])
  end
  
  # Compose a colorized success message for available domain
  #
  # domain - String
  #
  # Returns String
  def success_message(domain, color)
    "✔ Domain #{domain} is available!".colorize(color.to_sym)
  end
  
  # Compose a colorized failure message for taken domain
  #
  # domain - String
  #
  # Returns String
  def failure_message(domain, color)
    "✘ Domain #{domain} is taken.".colorize(color.to_sym)
  end
  
  # Generate a purchase link URL for a domain
  #
  # domain - String
  #
  # Returns String URL
  def purchase_link(domain)
    "https://www.namecheap.com/domains/registration/results/?domain=#{domain}"
  end
  
  # Return a user-friendly message summarizing availability across TLDs
  #
  # base_domain    - String base domain (without TLD)
  # available_count - Integer count of available domains
  #
  # Returns String message
  def availability_summary_message(base_domain, available_count)
    case available_count
      when 0
        "😞 No common domain extensions are available for ‘#{base_domain}’. Try a different name."
      when 1..3
        "⚠️ Only a few options are available for ‘#{base_domain}’. Consider securing one quickly!"
      when 4..6
        "🙂 Some good domain extensions are still available for ‘#{base_domain}’."
      else
        "🎉 Great news! Many domain extensions are available for ‘#{base_domain}’."
    end
  end
  end
end
