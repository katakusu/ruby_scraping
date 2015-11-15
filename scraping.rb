# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
# Nokogiriライブラリの読み込み
require 'nokogiri'

require 'kconv'
# 関数宣言

### リンク中の画像をダウンロードする ###
def getMaxPage(doc)
  maxpage = 1
  doc.xpath('//div[@class="MdPagination04"]/a').each do |pagenumber|
    if maxpage < pagenumber.text.to_i
      maxpage = pagenumber.text.to_i
    end
  end
  puts maxpage
end

def getScrapeMaxPage(doc)
  maxpage = 1
  doc.xpath('//div[@class="MdPagination03"]').each do |pagenumber|
    if pagenumber.text.scan(/[0-9]+/).size > maxpage
      maxpage = pagenumber.text.scan(/[0-9]+/).size
    end
  end
  return maxpage
end

def imagePage(imagelink)
  puts ' >'+imagelink
  charset = nil
  html = open(imagelink) do |f|
    charset = f.charset
    f.read
  end

  doc = Nokogiri::HTML.parse(html, nil, charset)

  doc.xpath('//div[@class="mdMTMEnd01Item01"]'+
    '/p[@class="mdMTMEnd01Img01"]/a/@href').each do |imgpath|
      puts ' ->'+imgpath.text
  end
end

### 各ページへのリンクを渡す ###
def scrapePage(pagelink)
  puts '>'+pagelink
  charset = nil
  html = open(pagelink) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end

  doc = Nokogiri::HTML.parse(html, nil, charset)

  doc.xpath('//div[@class="MdMTMWidgetList01"]'+
    '/div[@class="MdMTMWidget01 mdMTMWidget01TypeImg"]'+
    '/div[@class="mdMTMWidget01Content01 MdCF"]').each do |subtitle|
      # 画像部分抽出
      subtitle.xpath('./div[@class="mdMTMWidget01Content01Thumb"]'+
        '//a/@href').each do |imagePageUrl|
          imagePage(imagePageUrl)
      end

      # テキスト部分抽出
      subtitle.xpath('./div[@class="mdMTMWidget01Content01Txt"]').each do |txtPage|
        /\s+(\S+)\s+(\S+)/ =~ txtPage.text.toutf8
        puts ' >'+$1
        puts ' >'+$2
        puts ''
      end
  end
end

def countScrapePage(url)
  if 'http://matome.naver.jp/odai/2140161890279207501' != url && 'http://matome.naver.jp/odai/2140150767408311301' != url
    scrapePage(url)

    charset = nil
    html = open(url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    scrapeNo = 1

    if(getScrapeMaxPage(doc) > scrapeNo)
      scrapeNo = scrapeNo + 1
      scrapePage(url+'?page='+scrapeNo.to_s)
    end
  end
end


### ユーザーページ1,2,3,///処理 ###
def userPage(url)
  charset = nil
  html = open(url) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end

  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)

  #====== 最大何ページあるか確認 ======
  puts getMaxPage(doc)

  #====== 1ページ内の各ページへのリンク =======
  doc.xpath('//li[@class="mdMTMTtlList01Item"]'+
      '/div[@class="mdMTMTtlList01Txt"]'+
      '/h3[@class="mdMTMTtlList01Ttl"]'+
      '/a/@href').each do |pagelinks|
        countScrapePage(pagelinks.text)
  end
end



# スクレイピング先のURL
=begin
for i in 1..3 do
  puts i
end
=end
userPage('http://matome.naver.jp/mymatome/a-r?page=1&order=U&type=C')
userPage('http://matome.naver.jp/mymatome/a-r?page=2&order=U&type=C')
userPage('http://matome.naver.jp/mymatome/a-r?page=3&order=U&type=C')



# タイトルを表示
# p doc.title
