require 'thor'
require 'selenium-webdriver'
require_relative 'test_runner'

module QUnit
  module Selenium
    class Cli < Thor
      desc "open URL", %{Run qunit tests at the specified URL}
      option :timeout, type: :numeric, default: 10, desc: "Timeout in seconds to wait for the tests to complete"
      option :force_refresh, type: :boolean, default: false, desc: "Force a refresh of the page after it's loaded"
      option :screenshot, default: nil, desc: "Save a screenshot of the page to the specified file after the tests complete"

      def open(url)
        profile = ::Selenium::WebDriver::Firefox::Profile.new
        driver = ::Selenium::WebDriver.for :firefox, profile: profile

        test_result = TestRunner.new(driver).open(url, timeout: options[:timeout], force_refresh: options[:force_refresh])
        driver.save_screenshot options[:screenshot] if options[:screenshot]
        driver.quit

        print_report(test_result)

        exit(1) if test_result.assertions[:failed] > 0
      end

      private

      def print_report(result)
        puts "Total tests: #{result.tests[:total]}"
        puts "Passed:      #{result.tests[:passed]}"
        puts "Failed:      #{result.tests[:failed]}"
        puts "Total assertions: #{result.assertions[:total]}"
        puts "Passed:           #{result.assertions[:passed]}"
        puts "Failed:           #{result.assertions[:failed]}"
        puts "Tests duration:   #{result.duration} seconds"
      end
    end
  end
end