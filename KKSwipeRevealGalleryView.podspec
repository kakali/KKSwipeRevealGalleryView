Pod::Spec.new do |spec|
  spec.name = "KKSwipeRevealGalleryView"
  spec.version = "1.0.0"
  spec.summary = "A gallery view with swipe-to-discard pages. Load your custom views and swipe them away with your finger!"
  spec.homepage = "https://github.com/kakali/KKSwipeRevealGalleryView"
  spec.license = { type: 'MIT', file: 'LICENSE.md' }
  spec.authors = { "Katarzyna Kalinowska-Górska" => 'kkalinowskagorska@gmail.com' }

  spec.platform = :ios, "9.2"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/kakali/KKSwipeRevealGalleryView.git", tag: "v#{spec.version}", submodules: false }
  spec.source_files = "KKSwipeRevealGalleryView/*.{swift}"

end