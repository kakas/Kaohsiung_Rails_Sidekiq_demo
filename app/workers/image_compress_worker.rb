class ImageCompressWorker
  include Sidekiq::Worker

  def perform(product_id)
    @product = Product.find(product_id)

    puts "執行#{@product.title}的圖片壓縮工作"
    puts "#{@product.title}的圖片壓縮工作已經完成"
  end
end
