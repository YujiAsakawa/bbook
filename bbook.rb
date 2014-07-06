# coding: utf-8
require 'pry-byebug'
require 'tapp'
require 'mechanize'
require 'date'
require 'optparse'

INVALID_REX = /[\s\?\!"]/

def put_book(page)
	doc = Nokogiri(page.body)
	
	contents = doc.css('.center_book_box p')
	title = doc.css('.center_book_box h4').first.inner_text
	date = contents.shift.inner_text.gsub(/\//, '-')
	
	contents = doc.css('.center_book_box pre') if contents.size.zero?
	text = contents.tapp{ |c| c.size }.map { |c| c.inner_html.gsub(/<br>/i, "\n").gsub(/<[^>]+>/, '') }.join("\n")
	
	open("#{date}_#{title.encode('sjis', invalid: :replace).gsub(INVALID_REX, '')}.txt".tapp, 'w') do |f|
		f.puts "#{date} #{title}"
		f.puts
		f.puts text
	end
end

agent = Mechanize.new
#month = Date.new(2014, 6)
#no = 523
#month = Date.new(2012, 8)
#no = 445
#month = Date.new(2010, 2)
#no = 345
#month = Date.new(2009, 4)
#no = 308
month = Date.new(2000, 1)
no = 3

3.times do
	count = 0
	begin
		put_book agent.get(p "http://www.bbook.jp/backnumber/%4d/%02d/post_%d.html" % [month.year, month.month, no])
	rescue Mechanize::ResponseCodeError
		month = month.prev_month
		count += 1
		5 > count ? retry : break
	end
	no -= 1
end
