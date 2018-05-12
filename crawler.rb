require 'mechanize'

BASE_URL = "https://www.phongcachxanh.vn"
KEYBOARD_PAGE = "/shop/category/ban-phim-co-2"
KEYCAP_PAGE = "/shop/category/keycap-7"

def start_crawling(endpoint, category)
    agent = Mechanize.new { |a| a.user_agent_alias = 'Mac Safari' }

    products_page = agent.get("#{BASE_URL}#{endpoint}")

    pagination = products_page.search('ul.pagination')[0]

    paginate_length = pagination.search('li').length

    page_links = pagination.search('li>a')[1, paginate_length - 2].map do |e|
        e.attributes['href'].value
    end

    products = []

    page_links.each do |link|
        page = agent.get(link)
        itemscopes = page.search('[itemscope=itemscope]')
        itemscopes.each do |item|
            if (item.search('.oe_product_image img')[0] != nil)
                image_relativelink = item.search('.oe_product_image img')[0].attributes['src'].value
                image_link = "#{BASE_URL}#{image_relativelink}"

                product_name = item.search('section h5 a').text

                product_price = item.search('section [itemprop=price]').text.to_i

                products << {
                    name: product_name,
                    price: product_price,
                    image: image_link,
                    category: category
                }
            end
        end
    end

    File.open("products.csv", "a:utf-8") do |f|
        f.puts "product,price,image,category"
        products.each do |product|
            f.puts "#{product[:name]},#{product[:price]},#{product[:image]},#{product[:category]}"
        end
    end
end



start_crawling(KEYBOARD_PAGE, 'Bàn Phím')
start_crawling(KEYCAP_PAGE, 'Keycap')

puts 'Crawl completed!'

