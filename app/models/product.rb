class Product < ActiveRecord::Base

  after_commit :compress_image

  def compress_image
    ImageCompressWorker.perform_async(id)
  end

end
