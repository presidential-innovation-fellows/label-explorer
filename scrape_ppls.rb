require 'rubygems'
require 'selenium-webdriver'
require 'pry'
require 'nokogiri'
#require 'curb'
require 'open-uri'
require 'base64'
require 'elasticsearch'

#1. download from PPLS, extract label variables from XML
#2. Index PDFs in elastic along with additional fields. 

#1. load XML file of 6K registrations from PPLS into Nokogiri
baseurl = "http://iaspub.epa.gov/apex/pesticides/"
#driver = Selenium::WebDriver.for :firefox

doc =  Nokogiri::XML(File.open("registrations_1.xml"))

x_registrations = doc.css("tbody tr td a")

x_registrations.each_with_index do |reg,index| #iterate over links to label detail pages 

			if index > 20 and index < 1000

				puts "*********** REGISTRATION index: " + index.to_s + ": " + baseurl + reg.attribute('href')

				registration_detail = Nokogiri::HTML(open(baseurl + reg.attribute('href')))
				
				if registration_detail.css('table tr td a')[6] && registration_detail.css('table tr td a')[6].attribute('href').to_s.strip! != ""
					pdf_url = registration_detail.css('table tr td a')[6].attribute('href')

					puts "pdf_url is: " + pdf_url
					just_file_name = pdf_url.to_s.split('/')[-1]
					#1. Download the PDF
					`wget -N --directory-prefix='/home/ben/pif/PPLS scrape/registrations/' #{pdf_url}`

					#2. Populate fields
					label_name = registration_detail.css('.rc-title h3')
					puts "label_name is: " + label_name.to_s
					#have elasticsearch index the pdf
					sleep(7)
					

					local_path = "/home/ben/pif/PPLS scrape/registrations/" + just_file_name

					#puts "local_path is: " + local_path
					encoded_string = Base64.encode64(File.open(local_path).read)
					client = Elasticsearch::Client.new log: true
					client.index index: 'labels', type: 'label', body: { 'registration_id' => just_file_name,'pdf_content' => encoded_string }

				end
		end
	end 


