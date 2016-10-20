Pod::Spec.new do |s|
    s.name         = 'LSBLEManager'
    s.version      = '1.0.1'
    s.summary      = 'An easy way to use bluetooth'
    s.homepage     = 'https://github.com/StephenCMZ/LSBLEManager'
    s.license      = 'MIT'
    s.authors      = {'StephenChen' => 'StephenCMZ@live.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/StephenCMZ/LSBLEManager.git', :tag => s.version}
    s.source_files = 'LSBLEManager/*.{h,m}'
    s.requires_arc = true
end
