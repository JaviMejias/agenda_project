class GeneratePropertyImagesJob < ApplicationJob
  queue_as :default

  def perform(property_id)
    property = Property.find_by(id: property_id)
    return unless property

    property.images.each do |image|
      # Trigger generation of all variants used in the app
      property.carousel_variant(image).processed
      property.gallery_variant(image).processed
      property.thumbnail(image).processed
    end
  end
end
