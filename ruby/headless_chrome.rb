#!/usr/bin/ruby
require 'selenium-webdriver'

def setup

    # path to Chrome driver
    Selenium::WebDriver::Chrome.driver_path = "./chromedriver"

    # options
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    #options.add_argument('--remote-debugging-port=9222')

    # capabilities
    caps = Selenium::WebDriver::Remote::Capabilities.chrome
    caps["screen_resolution"] = "600x768"
    caps["record_network"] = "true"

    # create driver using options and capabilities
    @driver = Selenium::WebDriver.for :chrome, options: options, desired_capabilities: caps

end

def teardown
    @driver.quit
end

def run
    setup
    yield
    teardown
end


############ MAIN ###################

run do

    # go to google search page
    @driver.get 'http://www.google.com'

    # do search
    element = @driver.find_element(:name, 'q')
    element.send_keys "ruby selenium webdriver"
    element.submit

    # create screenshot of search results
    print "RESULTS TITLE: #{@driver.title}\n"
    @driver.save_screenshot('headless.png')
end
