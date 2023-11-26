# frozen_string_literal: true

module Bundle
  module WhalebrewInstaller
    module_function

    def reset!
      @installed_images = nil
    end

    def install(name)
      unless Bundle.whalebrew_installed?
        puts "Installing whalebrew. It is not currently installed." if Homebrew.args.verbose?
        Bundle.system "brew", "install", "whalebrew"
        raise "Unable to install #{name} app. Whalebrew installation failed." unless Bundle.whalebrew_installed?
      end

      return :skipped if image_installed?(name)

      puts "Installing #{name} image. It is not currently installed." if Homebrew.args.verbose?

      return :failed unless Bundle.system "whalebrew", "install", name

      installed_images << name
      :success
    end

    def image_installed?(image)
      installed_images.include? image
    end

    def installed_images
      @installed_images ||= Bundle::WhalebrewDumper.images
    end
  end
end
