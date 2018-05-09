#!/usr/local/bin/ruby

# installation requirement:
# $ gem install nokogiri

require 'rubygems'
require 'nokogiri'
require 'open-uri'

# No arguments taken on the command line.
# Produces a csv file: companies.csv

class Scraper
  attr_reader :rows

  # urls must be ordered by their ranking in ascending order
  def initialize(urls)
    @urls = urls
    @current_rank = 0
    @rows = []

    # Hardcode the header row, assuming we know beforehand what the columns
    # will be. TODO(cs): don't harcode this!
    @rows << ["Rank", "URL", "Name", "Industry", "IncorporationYear",
              "RevenueRsCrore", "RevenueChange",
              "NetOperatingIncomeRsCrore", "NetOperatingIncomeChange",
              "ProfitRsCrore", "ProfitChange",
              "AssetsRsCrore", "AssetsChange",
              "NetWorthRsCrore", "NetWorthChange",
              "EquityDividendRsCrore", "EquityDividendChange",
              "EmployeeCostRsCrore", "EmployeeCostChange"]
  end

  def scrape_company(html, url)
    row = []
    row << @current_rank += 1
    row << url

    company_name = html.css(".company-header").first.attribute("data-company-name").value
    row << company_name

    # Select all elements of the following form:
    #  <div class="company-industry">
    industry_div = html.css(".company-industry")
    # <p class="industry">Industry : Oil &amp; Gas</p>
    # We lowercase the industry to normalize (they are annoyingly redundant)
    industry = industry_div.css(".industry").text.split(":")[1].strip.downcase
    row << industry
    # <p class="inc-year">Incorporation : 1987</p>
    incorporation = industry_div.css(".inc-year").text.split(":")[1].strip
    row << incorporation

    parameters_div = html.css(".company-parameters").first
    trs = parameters_div.search("tr")
    # Skip the first tr, which we know to be "Parameters, Rs. Crore, %Change"
    trs[1..-1].each do |tr|
      tds = tr.search("td")
      # Remove all non-numeric characters
      rs = tds[1].text.gsub(/[^\d^\.]/, '').to_f
      change = tds[2].text.gsub(/[^\d^\.]/, '').to_f
      row << rs
      row << change
    end

    @rows << row

    # sanity check assertion:
    if row.length != @rows[0].length
      raise AssertionError.new("Wrong # of columns: #{row}")
    end

    # TODO(cs): extract profit ratios?
  end

  def scrape_all_companies
    # First fetch all the companies
    @urls.each do |url|
      # TODO(cs): use a proper URI lib to parse this
      base_url = url.split("/")[0..-2].join("/")
      first_company = true
      while not url.nil?
        $stderr.puts "Fetching #{url}"
        html = Nokogiri::HTML(open(url))
        scrape_company(html, url)
        next_node = html.css(".company-navigation").search("a")
        # There may be both a previous button and a next button,
        # or just a next button (as in the first page),
        # or just a previous button (as in the last page):
        if first_company
          # Just a next button
          url = "#{base_url}/#{next_node[0].attribute("href")}"
          first_company = false
        else
          # If only a previous button, we're at the end
          # Else there are two buttons, a previous and a next, so we extract
          # the next button.
          url = (next_node.length == 1) ? nil :
            "#{base_url}/#{next_node[1].attribute("href")}"
        end
      end
    end
  end
end

if __FILE__ == $0
  # Fortune India has two lists: "Fortune 500", and "Fortune Next 500".
  # We start by downloading the rank 1 and rank 501 companies, and then iteratively flip
  # through the list items using the "next rank" button.
  # TODO(cs): don't require hardcoded urls here, programmatically infer the rank 1
  # company from the landing page.
  rank_1_url = "https://www.fortuneindia.com/fortune-500/company/indian-oil-corporation?year=2017"
  rank_501_url = "https://www.fortuneindia.com/next-500/company/parag-milk-foods?year=2017"

  scraper = Scraper.new([rank_1_url, rank_501_url])
  begin
    scraper.scrape_all_companies
  ensure
    require 'csv'
    # output to a csv file
    CSV.open("companies.csv", "wb") do |csv|
      scraper.rows.each do |row|
        csv << row
      end
    end
  end
end
