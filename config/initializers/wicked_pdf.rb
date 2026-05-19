# Workaround para evitar el error de plataforma no soportada en versiones recientes de Ubuntu
begin
  gem_path = Gem.loaded_specs["wkhtmltopdf-binary"].full_gem_path
  gz_path = File.join(gem_path, "bin", "wkhtmltopdf_ubuntu_22.04_amd64.gz")
  bin_path = Rails.root.join("tmp", "wkhtmltopdf_custom")

  unless File.exist?(bin_path)
    require "zlib"
    require "fileutils"
    Zlib::GzipReader.open(gz_path) do |gz|
      File.binwrite(bin_path, gz.read)
    end
    FileUtils.chmod("+x", bin_path)
  end

  WickedPdf.configure do |config|
    config.exe_path = bin_path.to_s
    config.enable_local_file_access = true
  end
rescue StandardError => e
  Rails.logger.error "Error configurando wkhtmltopdf: #{e.message}"
end
