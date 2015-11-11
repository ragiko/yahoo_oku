require 'capybara'
require "selenium-webdriver"

Capybara.current_driver = :selenium
Capybara.register_driver :selenium do |app|
  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.timeout = 100
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :http_client => http_client)
end

include Capybara::DSL

# visit('https://login.yahoo.co.jp/config/login?.src=auc&.done=http%3A%2F%2Fpage21.auctions.yahoo.co.jp%2Fjp%2Fauction%2Fj360991951&.intl=jp')
visit('https://login.yahoo.co.jp/config/login')
sleep 3

### ここまでペースト yahooにログインする

WINSIZE = 10

windows = []
for i in 1..WINSIZE
  windows << open_new_window
end

### ここまでペースト

def bid(urls)
  _urls = urls
  if (urls.size > WINSIZE)
    _urls = urls[0..(WINSIZE-1)]
  end

  _urls.zip(windows).each do |url, w|
    switch_to_window w
    visit(url)

    now_price = find('.Price__title').text
    p "now_price = #{now_price}"

    if (!!now_price[/即決価格/])
      page.all(".ProductInformation__item.js-stickyNavigation-start a.Button.js-modal-show.rapidnofollow ").each do |dom|
        dom.click
        click_button("確認する")
        sleep 0.5
        click_button("ガイドラインに同意して、入札する")

        p "#{url}を落札しました"
      end
    else 
      p "#{url}は非即決です"
    end
  end
end


### ここまでペースト

require 'fileutils'

loop do
  a = `diff -u links.txt _links.txt`
  if (a.size > 0) 
    s = "#{Time.now}: " + "差分あり"
    `echo '#{s}' >> nyusatu_log.txt`
    p "#{Time.now}: " + "差分あり"
    
    fa = File.read('links.txt').split("\n")
    fb = File.read('_links.txt').split("\n")
    diff_urls = fa - fb

    if (diff_urls.size == 0)
      FileUtils.cp 'links.txt', '_links.txt'
      sleep 1
      next
    end

    p diff_urls

    begin
      bid(diff_urls)
    rescue => e
      p e.message
      `echo '#{e.message}' >> nyusatu_log.txt`
    end

    FileUtils.cp 'links.txt', '_links.txt'
    next
  end

  s = "#{Time.now}: " + "差分なし"
  `echo '#{s}' >> nyusatu_log.txt`
  p  "#{Time.now}: " +  "差分なし"

  sleep 1
end

