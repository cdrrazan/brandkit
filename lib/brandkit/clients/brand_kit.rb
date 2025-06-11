# frozen_string_literal: true

require 'byebug'
require 'tty-prompt'
require 'tty-table'
require 'colorize'
require 'artii'
require 'dotenv/load'  # this auto-loads .env

require_relative 'domain_checker'
require_relative 'social_username_checker'
require_relative 'namecheap_client'

# BrandKit CLI app for checking domain and social media username availability
module Clients
  class BrandKit
  # Initialize the CLI with prompt, ASCII art generator, and JSON output flag
  def initialize
    @prompt = TTY::Prompt.new
    @artii = Artii::Base.new
    @json_output = ARGV.include?('--json')
  end
  
  # Main entry point to run the app flow:
  # 1. Show intro banner
  # 2. Get domain input from args or prompt
  # 3. Check domain availability
  # 4. Show domain result with purchase link if available
  # 5. Optionally check social username availability
  # 6. Show farewell banner
  def run
    intro_banner
    
    domain = extract_domain_from_argv || prompt_for_domain
    domain_result = DomainChecker.new(domain).check
    
    show_result_box(domain_result[:message])
    
    print_purchase_link(domain_result) if domain_result[:link]
    
    ask_social_check(domain_result[:domain])
    farewell_banner
  end
  
  private
  
  # Extract domain argument from ARGV (e.g. --domain=example.com)
  #
  # Returns domain string or nil if not present
  def extract_domain_from_argv
    domain_arg = ARGV.find { |arg| arg.start_with?('--domain=') }
    domain_arg&.split('=', 2)&.last
  end
  
  # Prompt the user for a domain input with colored prompt message
  #
  # Returns the user-entered domain string
  def prompt_for_domain
    colored_prompt('🌐 Enter domain (e.g. example or example.com):')
  end
  
  # Show ASCII art intro banner with app title and tagline
  def intro_banner
    ascii = @artii.asciify('BrandKit').colorize(:cyan)
    puts ascii
    
    width = 60
    title = '🚀 Welcome to BrandKit'
    top_border = " #{title.ljust(width - 2)}"
    bottom_border = '─' * width
    
    body = [
      '',
      'The fastest way to check domain and',
      'social media username availability!',
      ''
    ].map { |line| line.colorize(:light_white).center(width) }
    
    puts top_border
    body.each { |line| puts line }
    puts bottom_border
  end
  
  # Show farewell banner with thanks message
  def farewell_banner
    width = 60
    title = '👋'
    top_border = " #{title.ljust(width - 2)}"
    bottom_border = '─' * width
    
    body = [
      '',
      'Thanks for using BrandKit!',
      'Start building your brand today. ✨',
      ''
    ].map { |line| line.colorize(:light_magenta).center(width) }
    
    puts top_border
    body.each { |line| puts line }
    puts bottom_border
  end
  
  # Display a formatted box with a status message in specified color
  #
  # message - String message to display
  # color   - Symbol colorize color (default :green)
  def show_result_box(message, color = :light_white)
    return if message.to_s.strip.empty?
    
    width = 60
    label = '✦ Domain Status'
    top_border = " #{label.ljust(width - 2)}"
    bottom_border = '─' * width
    
    body = ['', message.center(width), '']
    
    puts "\n"
    puts top_border.colorize(color)
    body.each { |line| puts line }
    puts bottom_border.colorize(color)
  end
  
  # Prompt with colorized question and return the answer
  #
  # question - String question to ask user
  #
  # Returns user input string
  def colored_prompt(question)
    @prompt.ask(question.colorize(:light_blue))
  end
  
  # Print domain purchase link if domain is available
  #
  # domain_result - Hash containing domain info (expects :domain key)
  def print_purchase_link(domain_result)
    purchase_url = "https://www.namecheap.com/domains/registration/results/?domain=#{domain_result[:domain]}"
    puts "\n🔗 #{'Purchase here:'.colorize(:light_green)} #{purchase_url.underline}"
    puts "\n"
  end
  
  # Prompt user whether to check social username availability,
  # allow selection of platforms, check availability, and print results in a table
  #
  # domain - String domain name to check usernames for
  def ask_social_check(domain)
    return unless @prompt.yes?('📱 Check if the username is available on social platforms?'.colorize(:light_cyan))
    
    all_choice = '🌍 All supported platforms'
    choices = [all_choice] + SocialUsernameChecker::PLATFORMS.keys.map(&:to_s)
    
    selected = prompt_platform_selection(choices, all_choice)
    
    platforms_to_check = if selected.include?(all_choice)
      SocialUsernameChecker::PLATFORMS.keys
    else
      selected.map(&:to_sym)
    end
    
    checker = SocialUsernameChecker.new
    username = checker.send(:strip_extension, domain)
    
    results = platforms_to_check.map do |platform|
      available = checker.username_available?(username, platform)
      status = available ? '✔ Available'.colorize(:green) : '✘ Taken'.colorize(:red)
      [platform.to_s.capitalize, status]
    end
    
    table = TTY::Table.new(['📡 Platform', '🔍 Status'], results)
    puts "\n#{table.render(:unicode, padding: [0, 3], alignment: [:center])}"
  end
  
  # Loop prompting user to select platforms, enforcing selection rules
  #
  # choices    - Array of choice strings including 'All supported platforms'
  # all_choice - String representing 'all platforms' option
  #
  # Returns array of selected platform strings
  def prompt_platform_selection(choices, all_choice)
    selected = []
    
    loop do
      puts "\n"
      selected = @prompt.multi_select('✔ Select platforms to check (space to select):'.colorize(:cyan), choices, per_page: 12)
      
      if selected.empty?
        puts '⚠️  You must select at least one platform.'.colorize(:yellow)
      elsif selected.include?(all_choice) && selected.length > 1
        puts "⚠️  Please select either '#{all_choice}' or specific platforms, not both.".colorize(:yellow)
      else
        break
      end
    end
    
    selected
  end
  end
end
