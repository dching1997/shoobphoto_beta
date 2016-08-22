class CorderExport
  include Sidekiq::Worker
  sidekiq_options queue: "package_import"
    def perform(id)
      export = Export.find(id)
      require 'csv'

      csv_file = ''

          csv_file << CSV.generate_line(Corder.all.first.attributes.keys[0..13].map{|column| column} + Corder.all.first.attributes.keys[14..21].map{|column| column} + ['Grade'] + ['School'] + ['District'] + ['Price'] + ['Items1to5'] + ['Items 6 to 10'] + ['Items 11 to 15'] + ['Items 16 to 20'] + ['Items 21 to 25']+ ['Processed'])
            Corder.all.each do |order|

              
              
              @string1 = ""
              @string2 = ""
              @string3 = ""
              @string4 = ""
              @string5 = ""
                
              order.cart.items[0..4].each do |item|
                citem = order.cart.cart_items.where(:item_id => item.id).last
                @string1 = @string1 + "#{item.number}, #{item.name}, #{citem.quantity}; "
              end

              if order.cart.items.count > 5

              order.cart.items[5..9].each do |item|
                citem = order.cart.cart_items.where(:item_id => item.id).last
                @string2 = @string2 + "#{item.number}, #{item.name}, #{citem.quantity}; "
              end
              end

              if order.cart.items.count > 10

              order.cart.items[10..14].each do |item|
                citem = order.cart.cart_items.where(:item_id => item.id).last
                @string3 = @string3 + "#{item.number}, #{item.name}, #{citem.quantity}; "
              end
              end

              if order.cart.items.count > 15

              order.cart.items[15..19].each do |item|
                citem = order.cart.cart_items.where(:item_id => item.id).last
                @string4 = @string4 + "#{item.number}, #{item.name}, #{citem.quantity}; "
              end
              end

              if order.cart.items.count > 20

              order.cart.items[20..24].each do |item|
                citem = order.cart.cart_items.where(:item_id => item.id).last
                @string5 = @string5 + "#{item.number}, #{item.name}, #{citem.quantity}; "
              end
              end
     
                csv_file << CSV.generate_line(order.attributes.values[0..13] + order.attributes.values[14..21] + [order.try(:grade)] + ["#{order.schools}"] +["#{order.district}"] + ["#{order.price.to_i}"] + [@string1] + [@string2] + [@string3] + [@string4] + [@string5] + ["#{order.processed}"]

              ) 
            
          end
          
          file_name = Rails.root.join('tmp', "order_#{Time.now.day}-#{Time.now.month}-#{Time.now.year}_#{Time.now.hour}_#{Time.now.min}.csv");

          File.open(file_name, 'wb') do |file|
          
            file.puts csv_file
          end

          s3 = AWS::S3.new

          key = File.basename(file_name)

          file = s3.buckets['shoobphoto'].objects["csvs/#{key}"].write(:file => file_name)
          file.acl = :public_read

          export.update(:file_path => key)
  end
end
